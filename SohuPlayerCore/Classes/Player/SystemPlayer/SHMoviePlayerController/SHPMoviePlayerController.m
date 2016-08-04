//
//  SHMoviePlayerController.m
//  PKTestProj
//
//  Created by zhongsheng on 14-3-5.
//  Copyright (c) 2014年 zhongsheng. All rights reserved.
//

#import "SHPMoviePlayerController.h"
#import "SHPMoviePlayerController+PKVideoPlayerDelegate.h"
#import <objc/runtime.h>
#import "PKVideoPlayer.h"

@interface SHMoviePlayerItem : NSObject <PKVideoPlayerItem>
@property (nonatomic, strong) NSURL *URL;           //<PKVideoPlayerItem>
@property (nonatomic, assign) CGFloat beginTime;    //<PKVideoPlayerItem>
@end
@implementation SHMoviePlayerItem
@end

@interface SHMovieView : UIView
@property (nonatomic, readonly) AVPlayer *player;
- (void)setPlayer:(AVPlayer *)player;
@end

@implementation SHMovieView
- (AVPlayer *)player{
    return [(AVPlayerLayer *)[self layer] player];
}
+ (Class)layerClass{
    return [AVPlayerLayer class];
}
- (void)setPlayer:(AVPlayer *)player{
    [(AVPlayerLayer *)self.layer setPlayer:player];
}
@end

@interface SHPMoviePlayerController ()
@property(nonatomic, strong) PKVideoPlayer *videoPlayer;
// Public Propertys
@property(nonatomic, readwrite, strong) UIView *view;
@property(nonatomic, readwrite, strong) UIView *backgroundView;
@property(nonatomic, readwrite, assign) SHMoviePlaybackState playbackState;
@property(nonatomic, readwrite, assign) SHPMovieLoadState loadState;
@property(nonatomic, readwrite, assign) BOOL readyForDisplay;
@end

@implementation SHPMoviePlayerController
@synthesize isPreparedToPlay = _isPreparedToPlay,loadState = _loadState;

#pragma mark - Public

- (void)dealloc
{
    [self clearPlayerLayerKVO];
    [self clearVideoPlayerKVO];
}

- (id)initWithContentURL:(NSURL *)url
{
    self = [self init];
    if (self) {
        self.contentURL = url;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.shouldAutoplay = YES;
        self.retryTimes = 0;
        _scalingMode = SHMovieScalingModeNone;
    }
    return self;
}

- (void)resetPlayer
{
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) { // iOS8+ 系统修复了黑屏问题
        if ([(SHMovieView*)_view player]) {
            [self clearPlayerLayerKVO];
            [(SHMovieView*)_view setPlayer:nil];
            [(SHMovieView*)_view setPlayer:self.videoPlayer];
            [self setupPlayerLayerKVO];
        }
    }
}

- (void)forceRetryPlayCurrentVideo
{
    if ([(SHMovieView*)_view player]) {
        [self clearVideoPlayerKVO];
        self.videoPlayer = nil;    // 销毁重建
        [self clearPlayerLayerKVO];
        [(SHMovieView*)self.view setPlayer:self.videoPlayer];
        [self setupPlayerLayerKVO];
        
        SHMoviePlayerItem *item = [[SHMoviePlayerItem alloc] init];
        item.URL = self.contentURL;
        [_videoPlayer setVideoPlayerItem:item];
    }
}

#pragma mark - KVO

- (void)setupVideoPlayerKVO
{
    double systemVersion = [[UIDevice currentDevice].systemVersion doubleValue];
    if (systemVersion < 6.0f) {
        [_videoPlayer addObserver:self forKeyPath:@"airPlayVideoActive" options:NSKeyValueObservingOptionNew context:NULL];
    } else {
        [_videoPlayer addObserver:self forKeyPath:@"externalPlaybackActive" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)clearVideoPlayerKVO
{
    double systemVersion = [[UIDevice currentDevice].systemVersion doubleValue];
    if (systemVersion < 6.0f) {
        [_videoPlayer removeObserver:self forKeyPath:@"airPlayVideoActive" context:NULL];
    } else {
        [_videoPlayer removeObserver:self forKeyPath:@"externalPlaybackActive" context:NULL];
    }
}

- (void)setupPlayerLayerKVO
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)_view.layer;
    [playerLayer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)clearPlayerLayerKVO
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)_view.layer;
    [playerLayer removeObserver:self forKeyPath:@"readyForDisplay" context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _videoPlayer) {
        if ([keyPath isEqualToString:@"airPlayVideoActive"]
            || [keyPath isEqualToString:@"externalPlaybackActive"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SHMoviePlayerIsAirPlayVideoActiveDidChangeNotification object:self];
        }
    }else if (object == _view.layer) {
        if ([keyPath isEqualToString:@"readyForDisplay"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SHMoviePlayerReadyForDisplayDidChangeNotification object:self];
        }
    }
}

#pragma mark - SHMoviePlayback

- (void)prepareToPlay{
    if (_videoPlayer
        && self.contentURL
        && !self.isPreparedToPlay
        && ![_videoPlayer.currentPlayerItem.URL.absoluteString isEqualToString:self.contentURL.absoluteString])
    {
        SHMoviePlayerItem *item = [[SHMoviePlayerItem alloc] init];
        item.URL = self.contentURL;
        [_videoPlayer setVideoPlayerItem:item];
    }
}

- (void)play
{
    self.prepareLoadAndPlay = YES;
    if (!self.isPreparedToPlay) {
        [self prepareToPlay];
    }else{
        [_videoPlayer playerPlay];
    }
}

- (void)pause
{
    [_videoPlayer playerPause];
}

- (void)stop
{
    [_videoPlayer playerStop];
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime
{
    [_videoPlayer playerSeekToTime:currentPlaybackTime];
}

- (NSTimeInterval)currentPlaybackTime
{
    return _videoPlayer.playerCurrentTime;
}

#pragma mark - Propertys

- (void)setMuted:(BOOL)muted{
    _muted = muted;
    [self.videoPlayer setMuted:muted];
}

- (void)setContentURL:(NSURL *)contentURL
{
    if (![contentURL.absoluteString isEqualToString:_contentURL.absoluteString]) {
        _contentURL = [contentURL copy];
        _isPreparedToPlay = self.prepareLoadAndPlay = NO;
        if (_videoPlayer && nil == _contentURL) {
            [_videoPlayer setVideoPlayerItem:nil];
        }
    }
}

- (UIView *)view
{
    if (!_view) {
        _view = [[SHMovieView alloc] initWithFrame:CGRectZero];
        [_view sizeToFit];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth|
        UIViewAutoresizingFlexibleHeight;
        _view.backgroundColor = [UIColor blackColor];
    }
    if (![(SHMovieView*)_view player]) {
        [(SHMovieView*)_view setPlayer:self.videoPlayer];
        [self setupPlayerLayerKVO];
        [self setScalingMode:self.scalingMode];
    }
    return _view;
}

- (UIView *)backgroundView
{
    if (!_backgroundView && _view) {
        _backgroundView = [[UIView alloc] initWithFrame:_view.bounds];
        [_backgroundView sizeToFit];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|
        UIViewAutoresizingFlexibleHeight;
        _backgroundView.backgroundColor = [UIColor blackColor];
    }
    return _backgroundView;
}

- (SHMoviePlaybackState)playbackState
{
    SHMoviePlaybackState playbackState = _playbackState;
    if (!_videoPlayer) {
        playbackState = SHMoviePlaybackStateStopped;
    }else{
        if(PKVideoPlayerPlayStatus_Stop == _videoPlayer.playStatus
           || PKVideoPlayerPlayStatus_Unknow == _videoPlayer.playStatus
           || PKVideoPlayerPlayStatus_ReachEnd == _videoPlayer.playStatus
           || PKVideoPlayerPlayStatus_Failed == _videoPlayer.playStatus)
        {
            playbackState = SHMoviePlaybackStateStopped;
        }else if (PKVideoPlayerPlayStatus_Play == _videoPlayer.playStatus){
            playbackState = SHMoviePlaybackStatePlaying;
        }else if (PKVideoPlayerPlayStatus_Pause == _videoPlayer.playStatus){
            playbackState = SHMoviePlaybackStatePaused;
        }else if (PKVideoPlayerPlayStatus_Forward == _videoPlayer.playStatus) {
            playbackState = SHMoviePlaybackStateSeekingForward;
        }else if (PKVideoPlayerPlayStatus_Backward == _videoPlayer.playStatus) {
            playbackState = SHMoviePlaybackStateSeekingBackward;
        }
    }
    if (playbackState != _playbackState) {
        _playbackState = playbackState;
    }
    return _playbackState;
}

- (SHPMovieLoadState)loadState
{
    SHPMovieLoadState loadState = _loadState;
    if (!_videoPlayer) {
        loadState = SHPMovieLoadStateUnknown;
    }else{
        if (_videoPlayer.playerVideoPlayable) {
            loadState = SHPMovieLoadStatePlayable;
            if (PKVideoPlayerLoadStatus_LoadSuccessed == _videoPlayer.loadStatus){
                loadState |= SHPMovieLoadStatePlaythroughOK;
            }else{
                loadState |= SHPMovieLoadStateStalled;
            }
        } else if (_videoPlayer.currentPlayerItem) {
            loadState = SHPMovieLoadStateStalled;
        } else {
            loadState = SHPMovieLoadStateUnknown;
        }
    }
    if (loadState != _loadState) {
        _loadState = loadState;
    }
    return _loadState;
}

- (void)setShouldAutoplay:(BOOL)shouldAutoplay
{
    if (shouldAutoplay != _shouldAutoplay) {
        _shouldAutoplay = shouldAutoplay;
        _videoPlayer.playerShouldAutoPlay = shouldAutoplay;
    }
}

- (void)setScalingMode:(SHMovieScalingMode)scalingMode
{
    if (_view) {
        AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.view.layer;
        if (SHMovieScalingModeAspectFit == scalingMode) {
            [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        }else if (SHMovieScalingModeAspectFill == scalingMode) {
            [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        }else if (SHMovieScalingModeFill == scalingMode) {
            [playerLayer setVideoGravity:AVLayerVideoGravityResize];
        }
    }
    if (scalingMode != _scalingMode) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHMoviePlayerScalingModeDidChangeNotification object:self];
    }
    _scalingMode = scalingMode;
}

- (BOOL)readyForDisplay
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.view.layer;
    return playerLayer.readyForDisplay;
}

- (PKVideoPlayer *)videoPlayer
{
    if (!_videoPlayer) {
        _videoPlayer = [[PKVideoPlayer alloc] init];
        _videoPlayer.playerDelegate = self;
        _videoPlayer.muted = self.muted;
        _videoPlayer.playerShouldAutoPlay = self.shouldAutoplay;
        [self setupVideoPlayerKVO];
    }
    return _videoPlayer;
}

@end

static void *const _kSHMoviePlayerControllerAssociatedSourceTypeKey = (void *)&_kSHMoviePlayerControllerAssociatedSourceTypeKey;

@implementation SHPMoviePlayerController (SHMovieProperties)

- (BOOL)allowsAirPlay
{
    double systemVersion = [[UIDevice currentDevice].systemVersion doubleValue];
    if (systemVersion < 6.0f){
        return _videoPlayer.allowsAirPlayVideo;
    }
    return _videoPlayer.allowsExternalPlayback;
}

- (void)setAllowsAirPlay:(BOOL)allowsAirPlay
{
    double systemVersion = [[UIDevice currentDevice].systemVersion doubleValue];
    if (systemVersion < 6.0f){
        _videoPlayer.allowsAirPlayVideo = allowsAirPlay;
    }else{
        _videoPlayer.allowsExternalPlayback = allowsAirPlay;
    }
}

- (BOOL)isAirPlayVideoActive
{
    double systemVersion = [[UIDevice currentDevice].systemVersion doubleValue];
    if (systemVersion < 6.0f){
        return _videoPlayer.isAirPlayVideoActive;
    }
    return _videoPlayer.externalPlaybackActive;
}

- (void)setMovieSourceType:(SHMovieSourceType)movieSourceType
{// 简单处理:切换类型,则直接重建Player。为了解决本地流和网络流无法连播问题。
    if (self.movieSourceType != movieSourceType) {
        [self willChangeValueForKey:@"movieSourceType"];
        if ([(SHMovieView*)self.view player]) {
            [self clearVideoPlayerKVO];
            self.videoPlayer = nil; // 销毁重建
            [self view];
            [self clearPlayerLayerKVO];
            [(SHMovieView*)self.view setPlayer:self.videoPlayer];
            [self setupPlayerLayerKVO];
        }
        objc_setAssociatedObject(self, _kSHMoviePlayerControllerAssociatedSourceTypeKey, [NSNumber numberWithInt:movieSourceType], OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"movieSourceType"];
    }
}

- (SHMovieSourceType)movieSourceType
{
    SHMovieSourceType ret = (SHMovieSourceType)[objc_getAssociatedObject(self, _kSHMoviePlayerControllerAssociatedSourceTypeKey) intValue];
    return ret;
}

- (NSTimeInterval)duration
{
    return (NSTimeInterval)_videoPlayer.playerDuration;
}

- (NSTimeInterval)playableDuration
{
    return _videoPlayer.playerAvailableDuration;
}

- (float)currentPlaybackRate {
    return _videoPlayer.rate;
}

@end

NSString *const SHMoviePlayerScalingModeDidChangeNotification = @"SHMoviePlayerScalingModeDidChangeNotification";
NSString* const SHMoviePlayerPlaybackDidFinishNotification = @"SHMoviePlayerPlaybackDidFinishNotification";
NSString* const SHMoviePlayerPlaybackStateDidChangeNotification = @"SHMoviePlayerPlaybackStateDidChangeNotification";
NSString* const SHMoviePlayerLoadStateDidChangeNotification = @"SHMoviePlayerLoadStateDidChangeNotification";
NSString* const SHMoviePlayerNowPlayingMovieDidChangeNotification = @"SHMoviePlayerNowPlayingMovieDidChangeNotification";
NSString* const SHMoviePlayerIsAirPlayVideoActiveDidChangeNotification = @"SHMoviePlayerIsAirPlayVideoActiveDidChangeNotification";
NSString* const SHMovieDurationAvailableNotification = @"SHMovieDurationAvailableNotification";
NSString *const SHMoviePlayerReadyForDisplayDidChangeNotification = @"SHMoviePlayerReadyForDisplayDidChangeNotification";

NSString* const SHMediaPlaybackIsPreparedToPlayDidChangeNotification = @"SHMediaPlaybackIsPreparedToPlayDidChangeNotification";
// Key
NSString* const SHMoviePlayerPlaybackDidFinishReasonUserInfoKey = @"SHMoviePlayerPlaybackDidFinishReasonUserInfoKey";