//
//  SHMoviePlayerController.m
//  SohuVideoSDK
//
//  Created by wangzy on 13-9-16.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//

#import "SHMoviePlayerController.h"
#import "SHPlayerSDKUtil.h"
#import "SHPlayerManager.h"
#import "SHMediaSourceManager.h"
#import "SHVideoSourceManager.h"
#import "SHMedia.h"
#import "VideoItem.h"

NSString * const SHAdvertisementServerHost_Test    = @"http://60.28.168.195/m";
NSString * const SHAdvertisementServerHost_Release = @"http://m.aty.sohu.com/m";

typedef enum {
    PlayerInnerStateReady = 0,
    PlayerInnerStateVideoDetailLoading,
    PlayerInnerStateVideoDetailLoaded,
    PlayerInnerStateAdvertLoading,
    PlayerInnerStateAdvertLoaded,
    PlayerInnerStateAdvertPlaying,
    PlayerInnerStateAdvertPlayEnd,
    
    PlayerInnerStateVideoStarPlay
} SHPlayerInnerState;

@interface SHMoviePlayerController () <PlayerManagerDelegate> {
    SHPlayerManager *_playerManager;
    SHVideoSourceManager *_mediaSourceManager;
}

@property (nonatomic, strong) SHMedia *currentPlayMedia;
@property (nonatomic, strong) VideoItem *currentPlayVideoItem;

@property (nonatomic, assign) SHPlayerInnerState playerInnerState;

@property (nonatomic, assign) BOOL isFirstPlayVideo;        // 是否是第一个播放视频, 用于统计连播还是手动点击播放

//// 全屏控制, 由上层实现
//@property (nonatomic, getter=isFullscreen) BOOL fullscreen;
@end

@implementation SHMoviePlayerController

@synthesize fullscreen;
@synthesize allowsAirPlay;
@synthesize movieScaleMode;
@synthesize muted = _muted;

- (void)dealloc {
    [_mediaSourceManager resetData];
    _playerManager.delegate = nil;
    
    self.currentPlayMedia = nil;
    self.currentPlayVideoItem = nil;
    
    [self removeObserver:self forKeyPath:@"view.frame"];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(didPlayCurrentMedia) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        _mediaSourceManager = [[SHVideoSourceManager alloc] init];
        
        self.isLoadAdvert        = YES;
        self.isFirstPlayVideo    = YES;
        self.isAutoPlayNextVideo = YES;
        self.playerInnerState    = PlayerInnerStateReady;

        _view = [[UIView alloc] initWithFrame:CGRectZero];
        _view.backgroundColor = [UIColor blackColor];
        [self addObserver:self forKeyPath:@"view.frame" options:0 context:nil];
        
        [self addMoviePlayerView];
        [self registerNotification];
    }
    return self;
}

- (void)addMoviePlayerView {
    _playerManager = [[SHPlayerManager alloc] init];
    _playerManager.delegate = self;
    _playerManager.muted = self.muted;
    _playerManager.view.frame = _view.bounds;
    [_view addSubview:_playerManager.view];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadVideoItemDetailSuccess:) name:LoadVideoItemDetailSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadVideoItemDetailFailed:) name:LoadVideoItemDetailFailedNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"view.frame"] && object == self) {
        if (_playerManager.view != nil) {
            _playerManager.view.frame = self.view.bounds;
        }
    }
}

#pragma mark -- API 播放函数
- (void)playWithMedia:(SHMedia *)aMedia {
    if (nil == aMedia) {
        DebugLog(@"播放失败，media is nil");
    }
    
    //重置播放资源
    [self destroyPlayer];
    [self resetPlayerSource];
    
    [_mediaSourceManager appendMedia:aMedia];
    
    SHMedia *media = [_mediaSourceManager currentPlayMedia];
    [self startPlayWithMedia:media];
}

- (void)playWithMediaArray:(NSArray *)mediaArray index:(int)index {
    if (nil == mediaArray || mediaArray.count == 0) {
        DebugLog(@"播放失败，mediaArray is nil or mediaArray count 0");
        return;
    }
    
    //重置播放资源
    [self destroyPlayer];
    [self resetPlayerSource];
    
    [_mediaSourceManager appendMediasArray:mediaArray];
    [self playMediaWithIndex:index];
}

- (void)appendMedia:(SHMedia *)aMedia {
    if (nil == aMedia) {
        return;
    }
    [_mediaSourceManager appendMedia:aMedia];
}

- (void)appendMediaArray:(NSArray *)aMediaArray {
    if (nil == aMediaArray || aMediaArray.count == 0) {
        return;
    }
    [_mediaSourceManager appendMediasArray:aMediaArray];
}

- (BOOL)playPreviousMedia {
    //重置播放器
    [self destroyPlayer];
    if ([_mediaSourceManager hasPrePlayMedia]) {
        [self startPlayWithMedia:[_mediaSourceManager prePlayMedia]];
        return YES;
    }
    return NO;
}

- (BOOL)playNextMedia {
    //重置播放器
    [self destroyPlayer];
    if ([_mediaSourceManager hasNextPlayMedia]) {
        [self startPlayWithMedia:[_mediaSourceManager nextPlayMedia]];
        return YES;
    }
    return NO;
}

- (BOOL)playMediaWithIndex:(NSInteger)index {
    //重置播放器
    [self destroyPlayer];
    SHMedia *media = [_mediaSourceManager playIndex:index];
    if (media) {
        [self startPlayWithMedia:media];
        return YES;
    }
    return NO;
}

#pragma mark -- 私有函数

- (BOOL)hasAdvertOfMedia:(SHMedia *)media {
    return NO;
}

- (BOOL)isLiveMedia:(SHMedia *)media {
    if (nil != media.lid && media.lid.length > 0 && [media.lid intValue] > 0) {
        media.sourceType = SHLiveMedia;
        return YES;
    }
    return NO;
}

- (void)startPlayWithMedia:(SHMedia *)media {
    self.currentPlayVideoItem = nil;
    self.currentPlayMedia = nil;
    self.currentPlayMedia = media;
    self.playerInnerState = PlayerInnerStateReady;
    
//    if (![[ConfigurationCenter sharedCenter] appUseAuthor]) {
//        [self playerSDKError:SHMoviePlayErrorNoAuthority];
//        return;
//    }
    
    [self isLiveMedia:media];
    switch (media.sourceType) {
        case SHLocalDownload: // 本地播放跳过广告
            [self willPlayCurrentMedia:NO];
            break;
        case SHSohuMedia:  { // 搜狐视频源首先加载视频详情
            if (media.vid) {
                self.playerInnerState = PlayerInnerStateVideoDetailLoading;
                [_mediaSourceManager loadVideoItemWidthMedia:media];
            } else {
                [self playerSDKError:SHMoviePlayErrorSHVideoVidIsNull];
            }
        }
            break;
        case SHLiveMedia: {
            if (media.url) {
                [self willPlayCurrentMedia:NO];
            } else {
                if (media.lid) { // 尝试通过直播视频详情接口加载
                    [_mediaSourceManager loadVideoItemWidthMedia:media];
                }else {
                    [self playerSDKError:SHMoviePlayErrorUrlNull];
                }
            }
        }
            break;
        default: { // 普通视频源播放播放逻辑
            if (media.url) {
                [self willPlayCurrentMedia:NO];
            } else {
                [self playerSDKError:SHMoviePlayErrorUrlNull];
            }
        }
            break;
    }
}

- (void)willPlayCurrentMedia:(BOOL)isPlayedAdvert {
    if (self.isInAdvertMode && isPlayedAdvert && [_delegate respondsToSelector:@selector(playerExitAdvertMode)]) {
        MDebugLog(@"推出广告模式，将要开始播放正片..");
        [_delegate playerExitAdvertMode];
    }
    _isInAdvertMode = NO;
    [self performSelector:@selector(didPlayCurrentMedia) withObject:nil afterDelay:.2f];
}

- (void)didPlayCurrentMedia {
    // cancel之前delay开启的播放
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(didPlayCurrentMedia) object:nil];
    
    // 用于统计连播或是点击播放
    _playerManager.isFirstPlayVideo = self.isFirstPlayVideo;
    
    if (self.currentPlayVideoItem) {
        [self playCurrentVideoItem];
    } else {
        [self playCurrentMedia];
    }
    
    self.isFirstPlayVideo = NO;
    self.playerInnerState = PlayerInnerStateVideoStarPlay;
}

- (void)playCurrentMedia {
    [_playerManager playerPlayWithMedia:self.currentPlayMedia];
}

- (void)playCurrentVideoItem {
    [_playerManager playerPlayWithVideoItem:self.currentPlayVideoItem];
}

#pragma mark - 预加载处理

- (void)preloadVideoWhenPlayAdvert {
    if (self.isPreloadMovieWhenPlayAdvert) {
        if (self.currentPlayVideoItem) {
            [self playPreloadCurrentVideoItem];
        } else {
            [self playPreloadCurrentMedia];
        }
    }
}

- (void)playPreloadCurrentMedia {
    [_playerManager playerPreloadWithMedia:self.currentPlayMedia];
}

- (void)playPreloadCurrentVideoItem {
    [_playerManager playerPreloadWithVideoItem:self.currentPlayVideoItem];
}

#pragma mark - 加载视频详情 NSNotification
- (void)loadVideoItemDetailSuccess:(NSNotification *)noti {
    if (noti.object != _mediaSourceManager) {
        return;
    }
    
    VideoItem *videoItem = [noti.userInfo objectForKey:kVideoItemKey];
    self.currentPlayVideoItem = nil;
    self.playerInnerState = PlayerInnerStateVideoDetailLoaded;
    if (videoItem) {
        self.currentPlayVideoItem = videoItem;
    } else {
        DebugLog(@"视频详情请求失败 :: ");
        [self playerSDKError:SHMoviePlayErrorSHVideoLoadFailed];
    }
}

- (void)loadVideoItemDetailFailed:(NSNotification *)noti {
    if (noti.object != _mediaSourceManager) {
        return;
    }
    DebugLog(@"视频详情请求失败 :: ");
    self.playerInnerState = PlayerInnerStateVideoDetailLoaded;
    self.currentPlayVideoItem = nil;
    [self playerSDKError:SHMoviePlayErrorSHVideoLoadFailed];
}


#pragma mark -- PlayerManager 代理回调函数
- (void)playbackLoadDuration:(NSTimeInterval)loadDuration success:(BOOL)success {
    if ([self.delegate respondsToSelector:@selector(playerLoadDuration:success:)]) {
        [self.delegate playerLoadDuration:loadDuration success:success];
    }
}

- (void)playbackDurationAvailable:(SHPlayerManager *)player {
    if ([self.delegate respondsToSelector:@selector(playbackDurationAvailable)]) {
        [self.delegate playbackDurationAvailable];
    }
}

- (void)playbackPreparing:(SHPlayerManager *)playerManager {
    if (!self.isInAdvertMode && [self.delegate respondsToSelector:@selector(playbackPreparing)]) {
        [self.delegate playbackPreparing];
    }
}

- (void)playbackStalling:(SHPlayerManager *)playerManager {
    if (!self.isInAdvertMode && [self.delegate respondsToSelector:@selector(playbackStalling)]) {
        [self.delegate playbackStalling];
    }
}

- (void)playbackPrepared:(SHPlayerManager *)playerManager {
    if (!self.isInAdvertMode && [self.delegate respondsToSelector:@selector(playbackPrepared)]) {
        [self.delegate playbackPrepared];
    }
}

- (void)playbackStart:(SHPlayerManager *)playerManager {
    if (!self.isInAdvertMode && [self.delegate respondsToSelector:@selector(playbackStart)]) {
        [self.delegate playbackStart];
    }
}

- (void)playerPlaybackStateDidChange:(SHPlayerManager *)playerManager {
    switch (playerManager.playbackState) {
        case SHMoviePlaybackStatePlaying: {
            if (playerManager.loadState == (SHPrivateMovieLoadStatePlayable|SHPrivateMovieLoadStatePlaythroughOK)) {
                if (!self.isInAdvertMode && [self.delegate respondsToSelector:@selector(playbackStart)]) {
                    [self.delegate playbackStart];
                }
            }
        }
            break;
        case SHMoviePlaybackStatePaused: {
            if (!self.isInAdvertMode && playerManager.loadState != SHPrivateMovieLoadStateUnknown && [self.delegate respondsToSelector:@selector(playbackPause)]) {
                [self.delegate playbackPause];
            }
        }
            break;
        case SHMoviePlaybackStateStopped: {
            if ([self.delegate respondsToSelector:@selector(playbackStop)]) {
                [self.delegate playbackStop];
            }
        }
            break;
        case SHMoviePlaybackStateInterrupted: {
            if (playerManager.loadState != SHPrivateMovieLoadStateUnknown && [self.delegate respondsToSelector:@selector(playbackInterrupted)]) {
                [self.delegate playbackInterrupted];
            }
        }
            break;
        case SHMoviePlaybackStateSeekingForward: {
            if (playerManager.loadState != SHPrivateMovieLoadStateUnknown && [self.delegate respondsToSelector:@selector(playbackSeekingForward)]) {
                [self.delegate playbackSeekingForward];
            }
        }
            break;
        case SHMoviePlaybackStateSeekingBackward: {
            if (playerManager.loadState != SHPrivateMovieLoadStateUnknown && [self.delegate respondsToSelector:@selector(playbackSeekingBackward)]) {
                [self.delegate playbackSeekingBackward];
            }
        }
            break;
        default:
            break;
    }
}

- (void)playerPlaybackDidFinish:(SHPlayerManager *)playerManager reason:(SHMovieFinishReason)aFinishedReason {
    switch (aFinishedReason) {
        case SHMovieFinishReasonSkipToTail:
        case SHMovieFinishReasonPlaybackEnded: {
            [self playerPlaybackFinish];
        }
            break;
        case SHMovieFinishReasonUserExited: {
            if ([self.delegate respondsToSelector:@selector(playerPlaybackFinishByUserExited)]) {
                [self.delegate playerPlaybackFinishByUserExited];
            }
        }
        case SHMovieFinishReasonPlaybackError: {
            [self playerSDKError:SHMoviePlayErrorSystem];
        }
            break;
        default:
            break;
    }
}

- (void)playerIsAirPlayVideoActiveDidChange:(SHPlayerManager *)playerManager {
}


#pragma mark -- 播放器单个视频播放结束 处理函数（正常播放结束，切换视频，播放错误）

- (void)playerPlaybackFinish {
    if (_mediaSourceManager.playMediaCount > 1) {
        if ([self.delegate respondsToSelector:@selector(playerPlaybackFinish:)]) {
            [self.delegate playerPlaybackFinish:_mediaSourceManager.currentPlayindex];
        }
    }
    if (![_mediaSourceManager hasNextPlayMedia]) {
        if ([self.delegate respondsToSelector:@selector(playerPlaybackComplete)]) {
            [self.delegate playerPlaybackComplete];
        }
    }
    
    // 处理联播逻辑
    if ([_mediaSourceManager hasNextPlayMedia] && self.isAutoPlayNextVideo) {
        [self playNextMedia];
    }
}

#pragma mark -- 播放控制函数

- (void)play {
    [_playerManager playerPlay];
}

- (void)stop {
    [_mediaSourceManager cancelRequest];
    // cancel之前delay开启的播放
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(didPlayCurrentMedia) object:nil];
    [_playerManager playerStop];
}

- (void)pause {
    if (self.playerInnerState < PlayerInnerStateAdvertPlaying) {
        [self playerExit];
        return;
    }
    [_playerManager playerPause];
}

- (void)seekForward:(NSTimeInterval)second {
    int posTime = _playerManager.currentPlaybackTime + second;
    if (posTime > _playerManager.duration) {
        posTime = _playerManager.duration;
    }
    [self seekTo:posTime];
}

- (void)seekBackward:(NSTimeInterval)second {
    NSTimeInterval posTime = _playerManager.currentPlaybackTime - second;
    if (posTime < 0) {
        posTime = 0;
    }
    [self seekTo:posTime];
}

- (void)seekTo:(NSTimeInterval)posTime {
    [_playerManager playerSeekTo:posTime];
}

- (BOOL)isFullscreen {
    return _playerManager.isFullscreen;
}

- (void)setFullscreen:(BOOL)aFullscreen animated:(BOOL)animated {
    [_playerManager setFullscreen:aFullscreen animated:animated];
}

- (BOOL)isAirPlayVideoActive {
    if (_playerManager) {
        return _playerManager.isAirPlayActive;
    }
    return NO;
}

- (void)setAllowsAirPlay:(BOOL)aAllowsAirPlay {
    if (_playerManager) {
        [_playerManager setAllowsAirPlay:aAllowsAirPlay];
    }
}

- (BOOL)shouldAutoplay {
    return _playerManager.shouldAutoplay;
}

- (void)setShouldAutoplay:(BOOL)aShouldAutoplay {
    _playerManager.shouldAutoplay = YES;
}

- (SHMovieScaleMode)movieScaleMode {
    return _playerManager.movieScaleMode;
}

- (void)setMovieScaleMode:(SHMovieScaleMode)aMovieScaleMode {
    _playerManager.movieScaleMode = aMovieScaleMode;
}


- (SHMovieQualityType)movieQualityType {
    if (_playerManager) {
        return _playerManager.movieQualityType;
    }
    return SHMovieQualityNormal;
}

- (void)setMovieQualityType:(SHMovieQualityType)aMovieQualityType {
    _playerManager.movieQualityType = aMovieQualityType;
}
#pragma mark -- 播放器状态函数

- (void)setMuted:(BOOL)muted{
    _muted = muted;
    [_playerManager setMuted:muted];
}

- (BOOL)muted{
    return _muted;
}

- (SHMoviePlayState)playbackState {
    return _playerManager.playbackState;
}

- (SHMovieLoadState)loadState {
    return _playerManager.loadState;
}

- (NSTimeInterval)duration {
    return _playerManager.duration;
}

- (NSTimeInterval)currentPlaybackTime {
    return _playerManager.currentPlaybackTime;
}

- (float)currentPlaybackRate {
    return _playerManager.currentPlaybackRate;
}

- (NSTimeInterval)playableDuration {
    return _playerManager.playableDuration;
}

- (NSURL *)contentURL {
    return [_playerManager conentUrl];
}

- (SHMedia *)currentPlayMedia {
    return _mediaSourceManager.currentPlayMedia;
}

#pragma mark -- 播放器清空销毁

- (void)playerExit {
    [self destroyPlayer];
    [self resetPlayerSource];
}

- (void)resetPlayerSource {
    _isInAdvertMode = NO;
    self.isFirstPlayVideo = YES;
    [_mediaSourceManager resetData];
}

- (void)destroyPlayer {
    if (_playerManager) {
        [_playerManager playerWillDestroy];
    }
}

#pragma mark - 播放器发生错误

- (void)playerSDKError:(SHMoviePlayErrorType)errorType {
    MDebugLog(@"正片播放失败 , error type : %d", errorType);
    self.playerInnerState = PlayerInnerStateReady;
    if ([self.delegate respondsToSelector:@selector(playerPlayError:)]) {
        [self.delegate playerPlayError:errorType];
    }
}

@end;
