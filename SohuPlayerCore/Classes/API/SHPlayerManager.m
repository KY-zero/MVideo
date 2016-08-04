//
//  SHPlayerController.m
//  SohuVideoSDK
//
//  Created by wangzy on 13-9-17.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//

#import "SHPlayerManager.h"
#import "SHMoviePlayer.h"
#import "SHMedia.h"
#import "VideoItem.h"
#import "SHPlayerSDKUtil.h"
#import "SHReachability+.h"
#import "VideoItem.h"

#define CustomErrorCode 0

@interface SHPlayerManager ()  {
    
    SHMoviePlayer *_moviePlayer;
    
    BOOL _playerDidPrepared; // 用于跟踪播放状态
    BOOL _playerDidPlay;     // 用于统计real vv
    
    BOOL _playerDidAvailable; // 视频地址有效
    
    SHMovieLoadState _cusLoadState; //自定义播放load state，用于统计卡顿
    
    SHMoviePlaybackState _cusPlaybackState;    //自定义播放状态
    SHMoviePlaybackState _recordPlaybackState; //记录上一次播放状态
    
    BOOL _isBeingRecordPlaybackStatePause;
    BOOL _isDidEnterForeground;

    NSTimeInterval _recordPlaybackTime;
    NSTimeInterval _recordDuration;
    
    NSDate *_trackerRecordDate;
    NSTimeInterval _videoPreloadTime;
}

@property (nonatomic, strong) SHMoviePlayer *moviePlayer;
@property (nonatomic, strong) SHMedia *mediaObject;
@property (nonatomic, strong) VideoItem *videoItem;

@property (nonatomic, assign) SHMoviePlaybackState cusPlaybackState;
@end


@implementation SHPlayerManager

@synthesize moviePlayer = _moviePlayer;
@synthesize allowsAirPlay;
@synthesize movieScaleMode;
@synthesize cusPlaybackState = _cusPlaybackState;
@synthesize muted = _muted;

- (void)dealloc {
    [self.moviePlayer stop];
    self.moviePlayer.delegate = nil;
    self.moviePlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        _moviePlayer = [[SHMoviePlayer alloc] init];
        _moviePlayer.delegate = self;
        
        _cusPlaybackState  = SHMoviePlaybackStateUnknown;
        self.openPreloadModel = NO;

        [self registerMovieNotificationObservers];
    }
    return self;
}

- (void)registerMovieNotificationObservers {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(appsWillEnterBackground:)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    [notificationCenter addObserver:self selector:@selector(appsDidEnterForeground:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    [notificationCenter addObserver:self selector:@selector(appsWillTerminal:)
                               name:UIApplicationWillTerminateNotification
                             object:nil];
}

#pragma mark -- 内部播放控制函数
- (void)playerURL:(NSURL *)url initialPlaybackTime:(NSTimeInterval)initialTime {
    _recordPlaybackTime = 0;
    _recordDuration = 0;
    self.conentUrl = nil;
    self.conentUrl = url;
    _initialPlaybackTime = initialTime;
    
    DebugLog(@"开始播放正片, url :: %@", self.conentUrl);
    //推出当前播放器
    [self exitCurrentMoviePlayer];
    
    //播放前准备
    BOOL isPrepared = [self preparePlayWithURL:url];
    if (self.moviePlayer && isPrepared) {
        _playerDidPrepared = NO;
        _playerDidPlay = NO;
        _cusLoadState = SHMovieLoadStatePlayable;
        _cusPlaybackState = SHMoviePlaybackStatePlaying;
        _recordPlaybackState = SHMoviePlaybackStatePlaying;
        _isDidEnterForeground = NO;
        
        //添加统计装点
        _trackerRecordDate = [NSDate date];

        MDebugLog(@"设置正片URL :: %@", self.conentUrl);
        [_moviePlayer play];
    }
}

- (BOOL)preparePlayWithURL:(NSURL *)url {
    BOOL isPrepared = NO;
    if (nil != url && _moviePlayer) {
        if ([url.absoluteString hasPrefix:@"file://"]) {
            [_moviePlayer setMovieSourceType:SHPrivateMovieSourceTypeFile];
        } else {
            [_moviePlayer setMovieSourceType:SHPrivateMovieSourceTypeStreaming];
        }
        [_moviePlayer setContentURL:url];
        isPrepared = YES;
    } else {
        DebugLog(@"播放器初始化失败, url is nil");
    }
    return isPrepared;
}

#pragma mark -- 外部调用-播放控制函数
- (void)playerPlayWithURL:(NSURL *)contentURL initialPlaybackTime:(NSTimeInterval)initialTime {
    [self playerURL:contentURL initialPlaybackTime:initialTime];
}

- (void)playerPreloadWithMedia:(SHMedia *)media {
    // 开启预加载
    self.openPreloadModel = YES;

    _mediaSourceType = media.sourceType;
    self.mediaObject = nil;
    self.videoItem = nil;
    self.mediaObject = media;
    _movieQualityType = SHMovieQualityNormal;
    [self playerPlayWithURL:[SHPlayerSDKUtil urlWithString:media.url] initialPlaybackTime:0];
}

- (void)playerPreloadWithVideoItem:(VideoItem *)videoItem {
    // 开启预加载
    self.openPreloadModel = YES;

    _mediaSourceType = SHSohuMedia;
    self.videoItem = nil;
    self.mediaObject = nil;
    self.videoItem = videoItem;
    NSURL *playURL = [SHPlayerSDKUtil getDefaultPlayURLOfVideoItem:videoItem];
    _movieQualityType = [SHPlayerSDKUtil getDefaultPlayQualityOfVideoItem:videoItem];
    [self playerPlayWithURL:playURL initialPlaybackTime:0];
}

- (void)playerPlayWithMedia:(SHMedia *)media {
    if ([self checkIsPreloadedCurrentVideo]) {
        self.openPreloadModel = NO;
        return;
    }
    
    _mediaSourceType = media.sourceType;
    self.mediaObject = nil;
    self.videoItem = nil;
    self.mediaObject = media;
    _movieQualityType = SHMovieQualityNormal;
    [self playerPlayWithURL:[SHPlayerSDKUtil urlWithString:media.url] initialPlaybackTime:0];
}

- (void)playerPlayWithVideoItem:(VideoItem *)videoItem {
    if ([self checkIsPreloadedCurrentVideo]) {
        self.openPreloadModel = NO;
        return;
    }
    
    _mediaSourceType = SHSohuMedia;
    self.videoItem = nil;
    self.mediaObject = nil;
    self.videoItem = videoItem;

    NSURL *playURL = [SHPlayerSDKUtil getDefaultPlayURLOfVideoItem:videoItem];
    _movieQualityType = [SHPlayerSDKUtil getDefaultPlayQualityOfVideoItem:videoItem];
    [self playerPlayWithURL:playURL initialPlaybackTime:0];
}

- (void)playerPlay {
    if (self.moviePlayer.playbackState != SHMoviePlaybackStatePlaying && _playerDidPrepared) {
        [self.moviePlayer play];
        _recordPlaybackState = SHMoviePlaybackStatePlaying;
        _isBeingRecordPlaybackStatePause = NO;
 
        _isDidEnterForeground = NO;
    }
}

- (void)playerRePlay {
    if (self.conentUrl) {
        NSURL *currentUrl = [self.conentUrl copy];
        [self playerURL:currentUrl initialPlaybackTime:self.initialPlaybackTime];
    }
}

- (void)playerStop {
    MDebugLog(@"点击停止播放 :::");
    [self.moviePlayer stop];
    self.moviePlayer.contentURL = nil;
    _cusPlaybackState = SHMoviePlaybackStateStopped;
    _recordPlaybackState = SHMoviePlaybackStateStopped;
    _isBeingRecordPlaybackStatePause = NO;
    self.openPreloadModel = NO;
}

- (void)playerPause {
    if (self.moviePlayer.playbackState != SHMoviePlaybackStatePaused) {
        [self.moviePlayer pause];
        MDebugLog(@"点击暂定播放 :::");
        _recordPlaybackState = self.playbackState;
        _isBeingRecordPlaybackStatePause = YES;
        
    } else {
        MDebugLog(@"当前已经是暂停状态 :::");
    }
}

- (void)playerSeekTo:(NSTimeInterval)newPos {
    [_moviePlayer setCurrentPlaybackTime:newPos];
}

- (void)playerBufferingHandle {
    if ([self.delegate respondsToSelector:@selector(playbackStalling:)]) {
        [self.delegate playbackStalling:self];
    }
}

- (void)playerResumeHandle {
    if (self.playbackState == SHMoviePlaybackStatePaused) {
        return;
    }
    DebugLog(@"将要恢复播放 ::: ");
    MDebugLog(@"将要恢复播放 :::");
    if ([self.delegate respondsToSelector:@selector(playbackPrepared:)]) {
        [self.delegate playbackPrepared:self];
    }
}

- (void)playerPlayStartHandle {
    if (self.playbackState == SHMoviePlaybackStatePaused) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(playbackStart:)]) {
        [self.delegate playbackStart:self];
    }
}

#pragma mark -- 私有函数

- (BOOL)checkIsPreloadedCurrentVideo {
    if (self.openPreloadModel) {
        // 添加统计装点
        [self staticRealVV];
        
        [self playerPlay];
    }
    return self.openPreloadModel;
}

- (void)stop {
    [self.moviePlayer stop];
    self.moviePlayer.contentURL = nil;
}

#pragma mark -- 统计函数
- (void)staticRealVV {
    if (!_playerDidPlay && !self.isInAdvertMode) {
        _playerDidPlay = YES;
    }
}

#pragma mark -- PlayerManager 代理函数
- (void)playbackPreparing:(SHMoviePlayer *)player {
    if (![self isLocalPlay]) {
        if ([self.delegate respondsToSelector:@selector(playbackPreparing:)]) {
            [self.delegate playbackPreparing:self];
        }
    }
}

- (void)playbackPrepared:(SHMoviePlayer *)player {
    // 计算第一针加载时长
    NSDate *nowDate = [NSDate date];
    _videoPreloadTime = [nowDate timeIntervalSinceDate:_trackerRecordDate];
    // 回调函数
    if ([self.delegate respondsToSelector:@selector(playbackPrepared:)]) {
        [self.delegate playbackPrepared:self];
    }
    if ([self.delegate respondsToSelector:@selector(playbackLoadDuration:success:)]) {
        [self.delegate playbackLoadDuration:_videoPreloadTime * 1000 success:YES];
    }

    _playerDidPrepared = YES;
    
    // 添加统计装点
    [self staticRealVV];
}

- (void)playbackDurationAvailable:(SHMoviePlayer *)player {
    DebugLog(@"playerDurationAvailable :::: %f", player.duration);
    MDebugLog(@"正片url有效，可以播放 :::: %f", player.duration);
    
    if (_recordPlaybackTime > 0) {
        self.moviePlayer.currentPlaybackTime = _recordPlaybackTime;
    }
    
    if ([self.delegate respondsToSelector:@selector(playbackDurationAvailable:)]) {
        [self.delegate playbackDurationAvailable:self];
    }
    
    // 如果为广告播放预加载，时间加载第一帧后暂停视频，等待广告播放结束，回复播放
    if (self.openPreloadModel) {
        MDebugLog(@"预加载完成，暂停播放，等待广告播放完成 ::: ");
        [self.moviePlayer pause];
    }
    
    _playerDidAvailable = YES;
    _recordPlaybackTime = 0;
    _recordDuration = 0;
}

- (void)playerLoadStateDidChange:(SHMoviePlayer *)player {
    switch ([self getPlayerLoadState]) {
        case SHMovieLoadStatePlayable: {
            if (_playerDidPrepared && _cusLoadState == SHMovieLoadStateStalled) {
                [self playerResumeHandle];
            }
            [self playerPlayStartHandle];
            _cusLoadState = SHMovieLoadStatePlayable;
        }
            break;
        case SHMovieLoadStateStalled: {
            if (_cusLoadState != SHMovieLoadStateStalled && _playerDidPrepared) {
                _cusLoadState = SHMovieLoadStateStalled;
                if (![self isLocalPlay] && self.moviePlayer.loadState == SHMovieLoadStatePlayable) {
                    if (player.playbackState != SHMoviePlaybackStateSeekingBackward &&  player.playbackState != SHMoviePlaybackStateSeekingForward) {
                        if (!isnan(player.currentPlaybackTime) && player.currentPlaybackTime > 0) {
                            if (abs(player.duration - player.currentPlaybackTime) >= 5) {
                                DebugLog(@"发生卡顿 ::: ");
                                [self playerBufferingHandle];
                            }
                        } else if ([self isLivePlay]) {
                            DebugLog(@"直播发生卡顿 ::: ");
                            [self playerBufferingHandle];
                        }
                    } else if (player.playbackState == SHMoviePlaybackStateSeekingBackward ||  player.playbackState == SHMoviePlaybackStateSeekingForward) {
                        DebugLog(@"发生拖动事件 ::: ");
                    }
                }
            }
        }
        case SHMovieLoadStateUnknown:
            break;
        default:
            break;
    }
}

- (void)playerPlaybackStateDidChange:(SHMoviePlayer *)player {
    if ([self.delegate respondsToSelector:@selector(playerPlaybackStateDidChange:)]) {
        [self.delegate playerPlaybackStateDidChange:self];
    }
}

- (void)playerPlaybackDidFinish:(SHMoviePlayer *)player {
    DebugLog(@"播放结束 ::: %@ playback state : %d, finish reason : %d  %f  %f", self.conentUrl, player.playbackState, player.finishReason, player.duration, player.currentPlaybackTime);
    MDebugLog(@"正片播放结束 ::: %@ ", self.conentUrl);
    SHPlayerPlaybackStopReason movieFinishedReason = SHPlayerPlaybackStopReasonUnknow;
    BOOL playbackNormalFinished = YES;
    switch (player.finishReason) {
        case SHMovieFinishReasonPlaybackEnded: {
            _recordPlaybackTime = 0;
            _recordDuration = 0;
            movieFinishedReason = SHPlayerPlaybackStopReasonEnd;
        }
            break;
        case SHMovieFinishReasonUserExited:
        case SHMovieFinishReasonURLChanged: {
            playbackNormalFinished = NO;
            movieFinishedReason = SHPlayerPlaybackStopReasonExit;
        }
            break;
        case SHMovieFinishReasonPlaybackError: {
            _recordPlaybackTime = 0;
            _recordDuration = 0;
            movieFinishedReason = SHPlayerPlaybackStopReasonFail;
        }
            break;
        default:
            break;
    }
    
    // 搜狐新闻需求，视频请求失败，返回加载时间
    if (player.finishReason == SHMovieFinishReasonPlaybackError) {
        NSDate *nowDate = [NSDate date];
        NSTimeInterval failTime = [nowDate timeIntervalSinceDate:_trackerRecordDate];
        if ([self.delegate respondsToSelector:@selector(playbackLoadDuration:success:)]) {
            [self.delegate playbackLoadDuration:failTime * 1000 success:NO];
        }
    }
    
    if (_playerDidPrepared) {
        // reset
        _playerDidPrepared = NO;
        _playerDidAvailable = NO;
        _cusPlaybackState = SHMoviePlaybackStateStopped;
        self.moviePlayer.currentPlaybackTime = -1;
        self.openPreloadModel = NO;

        if (playbackNormalFinished && [self.delegate respondsToSelector:@selector(playerPlaybackDidFinish:reason:)]) {
            [self.delegate playerPlaybackDidFinish:self reason:player.finishReason];
        }
    } else {
        if (player.finishReason == SHMovieFinishReasonPlaybackError) {
            if (playbackNormalFinished && [self.delegate respondsToSelector:@selector(playerPlaybackDidFinish:reason:)]) {
                [self.delegate playerPlaybackDidFinish:self reason:SHMovieFinishReasonPlaybackError];
            }
        }
    }
}

- (void)playerIsAirPlayVideoActiveDidChange:(SHMoviePlayer *)player {
    if ([self.delegate respondsToSelector:@selector(playerIsAirPlayVideoActiveDidChange:)]) {
        [self.delegate playerIsAirPlayVideoActiveDidChange:self];
    }
}

- (void)playerPlaybackDidFinishHandle:(SHPlayerPlaybackStopReason)stopReason {
    
}

#pragma mark -- 系统播放器property
- (BOOL)isPlayerActiviting {
    BOOL isActiviting = NO;
    if (self.moviePlayer) {
        DebugLog(@"isPlayerActiviting playbackState ::: %d", self.moviePlayer.playbackState);
        isActiviting = (self.moviePlayer.playbackState == SHMoviePlaybackStatePlaying ||
                        self.moviePlayer.playbackState == SHMoviePlaybackStateSeekingForward ||
                        self.moviePlayer.playbackState == SHMoviePlaybackStateSeekingBackward);
    }
    return isActiviting;
}

- (BOOL)isPlayerStop {
    BOOL isStop = NO;
    if (self.moviePlayer) {
        isStop = (self.moviePlayer.playbackState == SHMoviePlaybackStateStopped);
    }
    return isStop;
}

- (BOOL)isLocalPlay {
    BOOL isLocal = NO;
    if ([self.conentUrl.absoluteString hasPrefix:@"file://"]) {
        isLocal = YES;
    }
    return isLocal;
}

- (BOOL)isSupportBackgroundAudio {
    BOOL support = NO;
    NSDictionary* bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSArray* supportBackgroundModes = [bundleInfo valueForKey:@"UIBackgroundModes"];
    if (supportBackgroundModes && [supportBackgroundModes count] > 0) {
        for (NSString* mode in supportBackgroundModes) {
            if ([[mode lowercaseString] isEqualToString:@"audio"]) {
                support = YES;
                break;
            }
        }
    }
    return support;
}

- (BOOL)isLivePlay {
    if (self.mediaObject && self.mediaObject.sourceType == SHLiveMedia) {
        return YES;
    }
    return NO;
}

- (void)setAllowsAirPlay:(BOOL)aAllowsAirPlay {
    if (self.moviePlayer) {
        [self.moviePlayer setAllowsAirPlay:aAllowsAirPlay];
    }
}

- (BOOL)isAirPlayActive {
    return _moviePlayer.airPlayVideoActive;
}

- (BOOL)isAirPlaying {
    return NO;
}

- (UIView *)view {
    return _moviePlayer.view;
}

- (void)setMuted:(BOOL)muted{
    _muted = muted;
    [self.moviePlayer setMuted:muted];
}

- (BOOL)muted{
    return _muted;
}

- (BOOL)isFullscreen {
    return NO;
//    return _moviePlayer.isFullscreen;
}

- (void)setFullscreen:(BOOL)aFullscreen {
//    _moviePlayer.fullscreen = aFullscreen;
}

- (void)setFullscreen:(BOOL)aFullscreen animated:(BOOL)animated {
//    [_moviePlayer setFullscreen:aFullscreen animated:animated];
}

- (NSTimeInterval)duration {
    if (_recordPlaybackTime > 0) {
        return _recordDuration;
    }
    return [_moviePlayer duration];
}

- (NSTimeInterval)playableDuration{
    NSTimeInterval progress = [_moviePlayer playableDuration];
    if (progress > self.duration) {
        progress = self.duration;
    }
    return progress;
}

- (NSTimeInterval)currentPlaybackTime {
    return _moviePlayer.currentPlaybackTime;
}

- (float)currentPlaybackRate {
    return _moviePlayer.currentPlaybackRate;
}

- (BOOL)shouldAutoplay {
    return [_moviePlayer shouldAutoplay];
}

- (void)setShouldAutoplay:(BOOL)aShouldAutoplay {
    [_moviePlayer setShouldAutoplay:aShouldAutoplay];
}

- (SHMovieScalingMode)movieScaleMode {
    return _moviePlayer.scalingMode;
}

- (void)setMovieScaleMode:(SHMovieScalingMode)aMovieScaleMode {
    [_moviePlayer setScalingMode:aMovieScaleMode];
}

- (void)setMovieQualityType:(SHMovieQualityType)aMovieQualityType {
    _movieQualityType = aMovieQualityType;
}

- (SHMoviePlaybackState)getPlayerPlaybackState {
    SHMoviePlaybackState curState = SHInvalid;
    switch (self.moviePlayer.playbackState) {
        case SHMoviePlaybackStatePlaying:
            curState = SHMoviePlaybackStatePlaying;
            break;
        case SHMoviePlaybackStateStopped:
            curState = SHMoviePlaybackStateStopped;
            break;
        case SHMoviePlaybackStatePaused:
        case SHMoviePlaybackStateInterrupted:
            curState = SHMoviePlaybackStatePaused;
            break;
        case SHMoviePlaybackStateSeekingForward:
        case SHMoviePlaybackStateSeekingBackward:
            curState = SHMoviePlaybackStatePlaying;
            break;
        default:
            break;
    }
    return curState;
}

- (SHMoviePlaybackState)playbackState {
    return self.moviePlayer.playbackState;
}

- (SHMovieLoadState)loadState {
    return self.moviePlayer.loadState;
}

- (SHMovieLoadState)getPlayerLoadState {
    SHMovieLoadState curState;
    
    switch (self.moviePlayer.loadState) {
        case SHMovieLoadStatePlaythroughOK: //2
        case (SHMovieLoadStatePlayable | SHMovieLoadStatePlaythroughOK): {
            curState = SHMovieLoadStatePlayable;
        }
            break;
        case SHMovieLoadStateUnknown:
        case SHMovieLoadStatePlayable://1
        case SHMovieLoadStateStalled: //4
        case (SHMovieLoadStateStalled | SHMovieLoadStatePlayable):    //tobe play
        default:
            curState = SHMovieLoadStateStalled;
            break;
    }
    return curState;
}

- (void)exitCurrentMoviePlayer {
    if (_playerDidPrepared) {
    }
}

- (void)playerWillDestroy {
    if (_playerDidPrepared) {
    }
    self.conentUrl = nil;
    [self.moviePlayer exitPlay];
}

#pragma mark -- app 生命周期处理函数通知，处理播放器相应状态
- (void)appsWillEnterBackground:(NSNotification *)notification {
    if (self.isInAdvertMode) {
        return;
    }
    
    if (self.moviePlayer.isAirPlayVideoActive && [self isSupportBackgroundAudio]) {
        //airPlay 激活且程序允许audio后台运行，不作暂停操作。
    } else {
        [self.moviePlayer pause];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        _recordDuration = self.duration;
        _recordPlaybackTime = self.currentPlaybackTime;
    }
}

- (void)appsDidEnterForeground:(NSNotification *)notification {
    if (self.isInAdvertMode) {
        return;
    }
    
    if (!_isBeingRecordPlaybackStatePause) {
        _isBeingRecordPlaybackStatePause = NO;
        _isDidEnterForeground = YES;
        
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            [self playerPlay];
            [self.moviePlayer resetPlayer];
            if (_playerDidAvailable && isnan(self.currentPlaybackTime) && self.moviePlayer) {
                [self.moviePlayer setContentURL:self.conentUrl];
                [self.moviePlayer play];
            }
        } else {
            if (_playerDidAvailable && !isnan(self.currentPlaybackTime) && self.moviePlayer && self.conentUrl) {
                // 注释里的如果存在，则会闪一下才会刷新后播放
//                [self.moviePlayer exitPlay];
//                [self.moviePlayer setContentURL:self.conentUrl];
                [self.moviePlayer play];
            }
        }
    }
}

- (void)appsWillTerminal:(NSNotification *)notification {
    //统计需求
    [self playerStop];
}

#pragma mark -- 统计 datasource
- (BOOL)isVideoPlayerFullScreen {
    return self.fullscreen;
}

- (NSDictionary *)currentVideoItem {
    if (_mediaSourceType == SHSohuMedia) {
        if (_videoItem) {
            return [self videoItemToStatisticDictionary:_videoItem];
        } else {
            DebugLog(@"播放类型为搜狐内部视频(SHSohuMedia), VideoItem怎么能为空呢？");
        }
    } else if (_mediaSourceType == SHCommonMedia) {
        if (_mediaObject) {
            return [self shmediaToStaticDictionary:_mediaObject];
        } else {
            DebugLog(@"第三方视频播放，_mediaObject == nil");
        }
    } else if (_mediaSourceType == SHLiveMedia) {
        if (_mediaObject) {
            return [self shmediaToStaticDictionary:_mediaObject];
        } else {
            DebugLog(@"搜狐直播信播放，_mediaObject == nil");
        }
    } else if (_mediaSourceType == SHLocalDownload) {
        if (_mediaObject) {
            return [self sohuLoacakMediaToStaticDictionary:_mediaObject];
        } else {
            DebugLog(@"搜狐离线视频播放，_mediaObject == nil");
        }
    }
    return nil;
}

- (NSDictionary *)localServiceTSFileStatusInfo {
    return nil;
}

#pragma mark -- 统计NSDictionary封装
- (NSDictionary *)videoItemToStatisticDictionary:(VideoItem *)videoItem {
    NSMutableDictionary *staticDic = [NSMutableDictionary dictionary];
    [staticDic setObjectOrNil:videoItem.timeLength forKey:@"duration"];
    [staticDic setObjectOrNil:self.conentUrl.absoluteString forKey:@"url"];
    switch (self.movieQualityType) {
        case SHMovieQualityNormal: {
            [staticDic setObject:[NSString stringWithFormat:@"%d", kVideoQualityLow] forKey:@"definitionType"];
        }
            break;
        case SHMovieQualityHigh: {
            [staticDic setObject:[NSString stringWithFormat:@"%d", kVideoQualityHigh] forKey:@"definitionType"];
        }
            break;
        case SHMovieQualityUlitra: {
            [staticDic setObject:[NSString stringWithFormat:@"%d", kVideoQualityUltra] forKey:@"definitionType"];
        }
            break;
        default:
            break;
    }
    [staticDic setObjectOrNil:[NSString stringWithFormat:@"%lld", videoItem.vid] forKey:@"vid"];
    [staticDic setObjectOrNil:[NSString stringWithFormat:@"%lld", videoItem.aid] forKey:@"aid"];
    [staticDic setObjectOrNil:[NSString stringWithFormat:@"%d", videoItem.cid] forKey:@"cateid"];

    [staticDic setObject:[NSString stringWithFormat:@"%d", kDMTypeSohu] forKey:@"type"];
    if (videoItem.cid == kVideoType_Live) {
        [staticDic setObject:[NSString stringWithFormat:@"%d", kDMLtypeLiveVideo] forKey:@"ltype"];
    } else if (videoItem.cid == kVideoType_HomePageLive) {
        [staticDic setObject:[NSString stringWithFormat:@"%d", kDMLtypeSingalLiveVideo] forKey:@"ltype"];
    } else {
        [staticDic setObject:[NSString stringWithFormat:@"%d", kDMLtypeSignalVideo] forKey:@"ltype"];
    }
    [staticDic setObject:[NSString stringWithFormat:@"%d", kDMWtypeOnline] forKey:@"wtype"];
    
    NSMutableDictionary* albumDic = [NSMutableDictionary dictionary];
    [albumDic setValue:videoItem.cateCode forKey:@"cateCode"];
    [albumDic setValue:videoItem.languageID forKey:@"languageID"];
    [albumDic setValue:videoItem.areaID forKey:@"areaID"];
    [albumDic setValue:videoItem.companyID forKey:@"companyID"];
    [staticDic setObject:albumDic forKey:@"albumInfo"];
    
    NSString *channeled = @"";
    if (self.isFirstPlayVideo) {
        channeled = @"1300020001";
    } else {
        channeled = @"1300010001";
    }
    NSDictionary *userInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:channeled, @"sourceID", nil];
    [staticDic setObject:userInfoDic forKey:@"userInfo"];
    
    return staticDic;
}

- (NSDictionary *)shmediaToStaticDictionary:(SHMedia *)media {
    NSMutableDictionary *staticDic = [NSMutableDictionary dictionary];
    [staticDic setObjectOrNil:SHFloatString(_moviePlayer.duration) forKey:@"duration"];
    [staticDic setObjectOrNil:self.conentUrl.absoluteString forKey:@"url"];
    
    if (_mediaSourceType == SHCommonMedia) {
        [staticDic setObject:@"-2" forKey:@"vid"];
        [staticDic setObject:@"-2" forKey:@"aid"];
        [staticDic setObject:@"-2" forKey:@"cateid"];
    } else if (_mediaSourceType == SHLiveMedia) {
        [staticDic setObjectOrNil:media.aid forKey:@"aid"];
        [staticDic setObject:@"0" forKey:@"duration"];
    }
    
    if (_mediaSourceType == SHCommonMedia) {
        [staticDic setObject:SHIntString(kDMTypeThird) forKey:@"type"];
    } else if (_mediaSourceType == SHLiveMedia) {
        [staticDic setObject:SHIntString(kDMTypeThird) forKey:@"type"];
    }
    
    if (_mediaSourceType == SHCommonMedia) {
        [staticDic setObject:SHIntString(kDMLtypeSignalVideo) forKey:@"ltype"];
    } else if (_mediaSourceType == SHLiveMedia) {
        [staticDic setObject:SHIntString(kDMLtypeSingalLiveVideo) forKey:@"ltype"];
    }
    
    [staticDic setObject:SHIntString(kDMWtypeOnline) forKey:@"wtype"];
    
    NSDictionary *ablumDic;
    if (_mediaSourceType == SHCommonMedia) {
        ablumDic = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"-2", @"cateCode",
                    @"-2", @"languageID",
                    @"-2", @"areaID",
                    @"-2", @"companyID", nil];
    } else {
        ablumDic = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"", @"cateCode",
                    @"", @"languageID",
                    @"", @"areaID",
                    @"", @"companyID", nil];
    }
    [staticDic setObject:ablumDic forKey:@"albumInfo"];
    
    NSString *channeled = @"";
    if (self.isFirstPlayVideo || media.sourceType == SHLiveMedia) {
        channeled = @"1300020001";
    } else {
        channeled = @"1300010001";
    }
    NSDictionary *userInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:channeled, @"sourceID", nil];
    [staticDic setObject:userInfoDic forKey:@"userInfo"];
    
    return staticDic;
}

- (NSDictionary *)sohuLoacakMediaToStaticDictionary:(SHMedia *)media {
    NSMutableDictionary *staticDic = [NSMutableDictionary dictionary];
    [staticDic setObjectOrNil:[NSString stringWithFormat:@"%f", media.duration] forKey:@"timeLength"];
    [staticDic setObjectOrNil:[NSString stringWithFormat:@"file://%@", media.url] forKey:@"url"];

    [staticDic setObject:[NSString stringWithFormat:@"%d", kDMLtypeSignalVideo] forKey:@"ltype"];
    [staticDic setObject:[NSString stringWithFormat:@"%d", kDMWtypeLocal] forKey:@"wtype"];

    NSString *channeled = @"";
    if (self.isFirstPlayVideo) {
        channeled = @"1300020001";
    } else {
        channeled = @"1300010001";
    }
    NSDictionary *userInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:channeled, @"sourceID", nil];
    [staticDic setObject:userInfoDic forKey:@"userInfo"];
    
    return staticDic;
}
@end
