//
//  PKVideoPlayer.m
//  PKTestProj
//
//  Created by zhongsheng on 14-1-21.
//  Copyright (c) 2014年 zhongsheng. All rights reserved.
//

#import "PKVideoPlayer.h"
#import "PKVideoPlayerKit.h"

@interface PKVideoPlayer ()
@property (nonatomic, strong) id<PKVideoPlayerItem> currentPlayerItem;
@property (nonatomic, assign) BOOL isSeeking;
@property (nonatomic, assign) BOOL playerVideoPlayable;
@property (nonatomic, assign) PKVideoPlayerPlayStatus lastPlayStatus;
@property (nonatomic, assign) NSInteger retryTimes;
@end

@implementation PKVideoPlayer
{
    BOOL _handlePlayStatus; // 为了修复拔耳机导致暂停的问题
}
@synthesize
playerCurrentTime = _playerCurrentTime,
playerDuration = _playerDuration;


- (void)dealloc
{
    [self clearCurrentPlaying];
    [self removeObserver:self forKeyPath:@"rate" context:NULL];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        _playerShouldAutoPlay = YES;
        _handlePlayStatus = NO;
        _loadStatus = PKVideoPlayerLoadStatus_Unload;
        _playStatus = self.lastPlayStatus = PKVideoPlayerPlayStatus_Unknow;
        self.isSeeking = NO;
        self.playerVideoPlayable = NO;
        _playerCurrentTime = 0.0f;
        _playerDuration = 0.0f;
        self.retryTimes = 0;
        // 为了修复拔耳机导致暂停的问题
        [self addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

#pragma mark - Public

- (void)setVideoPlayerItem:(id<PKVideoPlayerItem>)playerItem
{
    if (_currentPlayerItem == playerItem
        && [((AVURLAsset *)self.currentItem.asset).URL.absoluteString isEqualToString:playerItem.URL.absoluteString])
    {
        return;
    }
    _currentPlayerItem = playerItem;
    if (self.playerShouldAutoPlay) {
        [self playWithVideoPlayerItem:playerItem];
    }    
}

- (void)playerPlay
{
    if (PKVideoPlayerLoadStatus_Unload == self.loadStatus
        || PKVideoPlayerLoadStatus_LoadFailed == self.loadStatus)
    {
        if (nil == self.currentPlayerItem)
        { // Unknow
            return;
        }
        else
        { // Stop | ReachEnd | Over | Failed
            [self playWithVideoPlayerItem:self.currentPlayerItem];
        }
    }
    _handlePlayStatus = YES;
    if (0.0f == self.rate) { // Pause
        [self play];
    }
    [self updatePlayStatus:PKVideoPlayerPlayStatus_Play error:nil];
    _handlePlayStatus = NO;
}

- (void)playerPause
{
    if (PKVideoPlayerLoadStatus_Unload == self.loadStatus
        || PKVideoPlayerLoadStatus_LoadFailed == self.loadStatus) {
        return;
    }
    _handlePlayStatus = YES;
    if (0.0f != self.rate){
        [self pause];
    }
    [self updatePlayStatus:PKVideoPlayerPlayStatus_Pause error:nil];
    _handlePlayStatus = NO;
}

- (void)playerStop
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(retryLoadCurrentPlayerItem) object:nil];
    _handlePlayStatus = YES;
    if (0.0f != self.rate){
        [self pause];
    }
    [self updatePlayStatus:PKVideoPlayerPlayStatus_Stop error:nil];
    _handlePlayStatus = NO;
}

- (void)playerSeekToTime:(CGFloat)time
{
    [self playerSeekToTime:time completionHandler:nil];
}

- (void)playerSeekToTime:(CGFloat)time completionHandler:(void (^)(BOOL finished))completionHandler
{
    if (time >= self.playerDuration)
    {
        [self updatePlayStatus:PKVideoPlayerPlayStatus_ReachEnd error:nil];
    }
    else if(PKVideoPlayerLoadStatus_Unload != self.loadStatus
            || PKVideoPlayerLoadStatus_LoadFailed == self.loadStatus)
    {
        self.isSeeking = YES;
        
        CGFloat lastTime = self.playerCurrentTime;
        
        PKVideoPlayerPlayStatus lastPlayStatus = self.playStatus;
        
        _playerCurrentTime = time; // 由于seekTime不会及时更新self.currentItem.currentTime,所以手动记录
        
        
        if (time >= 0 && time > lastTime) {
            [self updatePlayStatus:PKVideoPlayerPlayStatus_Forward error:nil];
        } else if (time >= 0 && time < lastTime){
            [self updatePlayStatus:PKVideoPlayerPlayStatus_Backward error:nil];
        }
        
        if (lastPlayStatus != self.playStatus) {
            if (lastPlayStatus == PKVideoPlayerPlayStatus_Pause) {
                [self updatePlayStatus:PKVideoPlayerPlayStatus_Pause error:nil];
            } else {
                _playStatus = lastPlayStatus;
            }
        }
        
        [self updateLoadStatus:PKVideoPlayerLoadStatus_Loading error:nil]; // 系统触发loading状态比较慢，先手动触发。
        
        [self seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:completionHandler];
    }
}

#pragma mark - Private

- (void)clearCurrentPlaying
{
    @synchronized(self) {
        [self unregisterNotifications];
        
        [self removeObserversFromVideoPlayerItem];
        
        [self replaceCurrentItemWithPlayerItem:nil];
        
        self.playerVideoPlayable = NO;
        
        self.lastPlayStatus = PKVideoPlayerPlayStatus_Unknow;
    }
}

- (void)replaceCurrentPlayerItem:(id<PKVideoPlayerItem>)playerItem
{
    if (playerItem.URL) {
        
        VDLog(@"will setURL :%@",playerItem.URL);
        
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:playerItem.URL];
        
        if (playerItem.beginTime > 0.0f) {
            [item seekToTime:CMTimeMakeWithSeconds(playerItem.beginTime, NSEC_PER_SEC)];
        }
        
        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        [item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        
        [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        
        [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        
        [self replaceCurrentItemWithPlayerItem:item];
        
        VDLog(@"#### addObserversFromVideoPlayerItem :%@",self.currentItem);
        
        [self registerNotifications];
    }
}

- (void)playWithVideoPlayerItem:(id<PKVideoPlayerItem>)playerItem
{
    [self clearCurrentPlaying];
    if (nil != playerItem && nil != playerItem.URL)
    {
        [self updateLoadStatus:PKVideoPlayerLoadStatus_Loading error:nil];
        
        if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(videoPlayer:willLoadVideoPlayerItem:)]) {
            [self.playerDelegate videoPlayer:self willLoadVideoPlayerItem:playerItem];
        }
        [self replaceCurrentPlayerItem:playerItem];
    } else {
        // TODO: error do not set item
        [self updateLoadStatus:PKVideoPlayerLoadStatus_Unload error:nil];
    }
}

- (void)retryLoadCurrentPlayerItem
{
    PKVideoPlayerPlayStatus lastStatus = self.playStatus;
    [self clearCurrentPlaying];
    _playStatus = lastStatus;
    [self replaceCurrentPlayerItem:self.currentPlayerItem];
}

- (void)updatePlayStatus:(PKVideoPlayerPlayStatus)status error:(PKVideoPlayerError *)error
{
    if (self.lastPlayStatus != status
        || PKVideoPlayerPlayStatus_Stop == status)
    {
        PKVideoPlayerLoadStatus theLoadStatus = self.loadStatus;
        PKVideoPlayerPlayStatus lastStatus = self.lastPlayStatus;
        self.lastPlayStatus = status;
        switch (status) {
            case PKVideoPlayerPlayStatus_ReachEnd:
                // reachEnd前，系统还可能回调一次 loading 状态
                //[self updateLoadStatus:PKVideoPlayerLoadStatus_LoadSuccessed error:nil];
            case PKVideoPlayerPlayStatus_Unknow:
            case PKVideoPlayerPlayStatus_Stop:
            case PKVideoPlayerPlayStatus_Failed:
            {
                [self clearCurrentPlaying];
                theLoadStatus = PKVideoPlayerLoadStatus_Unload;
            }
                break;
            default:
                break;
        }

        BOOL shouldUpdatePlayStatus = YES;
        // 以下情况不需要回调，只需处理数据。
        if (PKVideoPlayerPlayStatus_Unknow == lastStatus
            && PKVideoPlayerPlayStatus_Pause == lastStatus) { // 第一次载入，可以回调暂停
            shouldUpdatePlayStatus = NO;
        } else if (PKVideoPlayerPlayStatus_Stop == lastStatus
                  && PKVideoPlayerPlayStatus_Stop == status){ // 如果上次是stop，这次也是stop，则不回调
            shouldUpdatePlayStatus = NO;
        } else if (PKVideoPlayerPlayStatus_Unknow == status){  // 本次unknow状态，不回调
            shouldUpdatePlayStatus = NO;
        }
        
        if (shouldUpdatePlayStatus)
        {
            _playStatus = self.lastPlayStatus;
            if (self.playerDelegate
                && [self.playerDelegate respondsToSelector:@selector(videoPlayer:updatePlayStatus:error:)])
            {
                [self.playerDelegate videoPlayer:self updatePlayStatus:status error:error];
            }
        }
        if (theLoadStatus != self.loadStatus) { // 如果loadStatus有所变化,则在PlayStatus状态回调后更新。
            [self updateLoadStatus:theLoadStatus error:nil];
        }
    }
}

- (void)updateLoadStatus:(PKVideoPlayerLoadStatus)status error:(PKVideoPlayerError *)error
{
    if (self.loadStatus != status)
    {
        _loadStatus = status;
        switch (status) {
            case PKVideoPlayerLoadStatus_Unload:
                [self clearCurrentPlaying];
                self.isSeeking = NO;
                _playerCurrentTime = 0.0f;
                self.retryTimes = 0;
                break;
            case PKVideoPlayerLoadStatus_LoadFailed:
                [self updateLoadStatus:PKVideoPlayerLoadStatus_Unload error:nil];
                break;
            case PKVideoPlayerLoadStatus_LoadSuccessed:
                self.isSeeking = NO;
            default:
                break;
        }        
        if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(videoPlayer:updateLoadStatus:error:)]){
            [self.playerDelegate videoPlayer:self updateLoadStatus:status error:error];
        }
    }
}

#pragma mark - KVO

- (void)removeObserversFromVideoPlayerItem
{
    if (self.currentItem) {
        VDLog(@"#### removeObserversFromVideoPlayerItem :%@",self.currentItem);
        [self.currentItem removeObserver:self forKeyPath:@"status"];
        [self.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self) {
        if ([keyPath isEqualToString:@"rate"]) {
            if (!_handlePlayStatus
                && self.rate == 0
                && self.playStatus == PKVideoPlayerPlayStatus_Play)
            {// 为了修复拔耳机导致暂停的问题
                [self playerPlay];
            }
        }
    } else if (object == self.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status) {
                case AVPlayerStatusReadyToPlay:
                    VDLog(@"kvo: status AVPlayerStatusReadyToPlay");
                    [self updateLoadStatus:PKVideoPlayerLoadStatus_LoadSuccessed error:nil];
                    // play状态控制
                    [self playerWillPlay];
                    break;
                case AVPlayerStatusFailed:
                    VDLog(@"kvo: status AVPlayerStatusFailed error ：%@",self.currentItem.error);
                    if (PKVideoLoadRetryMaxTimes > self.retryTimes ++ && self.currentPlayerItem) {
                        VDLog(@"load failed retry times :%d",self.retryTimes);
                        [self clearCurrentPlaying];
                        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(retryLoadCurrentPlayerItem) object:nil];
                        [self performSelector:@selector(retryLoadCurrentPlayerItem) withObject:self afterDelay:PKVideoLoadRetryDelay];
                    } else {
                        // 如果预加载时长大于当前播放时长，则播放预加载
                        if (self.playerCurrentTime >= self.playerAvailableDuration) {
                            [self updateLoadStatus:PKVideoPlayerLoadStatus_LoadFailed error:[PKVideoPlayerError errorWithNSError:self.currentItem.error]];
                        }
//                        [self updateLoadStatus:PKVideoPlayerLoadStatus_LoadFailed error:[PKVideoPlayerError errorWithNSError:self.currentItem.error]];
                    }
                    break;
            }
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"] && self.currentItem.playbackBufferEmpty) {
            VDLog(@"kvo: playbackBufferEmpty startAnimating");
            [self updateLoadStatus:PKVideoPlayerLoadStatus_Loading error:nil];
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"] && self.currentItem.playbackLikelyToKeepUp) {
            VDLog(@"kvo: playbackLikelyToKeepUp stopAnimating rate:%.1f",self.rate);
            // load状态控制
            if (PKVideoPlayerLoadStatus_LoadSuccessed == self.loadStatus)
            {
                // play状态控制
                [self playerWillPlay];
            } else {
                // 卡顿情况，手动设置loadSuccessed,不需要再调用play方法,还可以添加卡顿统计。
                VDLog(@"kvo: playbackLikelyToKeepUp 卡顿恢复");
                [self updateLoadStatus:PKVideoPlayerLoadStatus_LoadSuccessed error:nil];
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            CGFloat bufferTime = self.playerAvailableDuration;
            VDLog(@"kvo: bufferTime:%.1f",bufferTime);
            if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(videoPlayer:updateBufferTime:)])
            {
                [self.playerDelegate videoPlayer:self updateBufferTime:bufferTime];
            }
        }
    }
}

- (void)playerWillPlay
{
    @synchronized(self) {
        // 第一次载入成功
        if (!self.playerVideoPlayable){
            self.playerVideoPlayable = YES;
            if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(videoPlayer:didLoadVideoPlayerItem:)]) {
                [self.playerDelegate videoPlayer:self didLoadVideoPlayerItem:self.currentPlayerItem];
            }
        }
        // play状态控制
        if (PKVideoPlayerPlayStatus_Pause != self.playStatus
            && (self.playerShouldAutoPlay
                || PKVideoPlayerPlayStatus_Play == self.playStatus)) // 手动操作播放了
        {
            [self playerPlay];
        } else {
            [self playerPause];
        }
    }
}

#pragma mark - Notifications

- (void)playerItemDidPlayToEndTimeNotification:(NSNotification *)notification
{
    VDLog(@"AVPlayerItemDidPlayToEndTimeNotification :%@",notification.userInfo);
    [self updatePlayStatus:PKVideoPlayerPlayStatus_ReachEnd error:nil];
}

- (void)playerItemFailedToPlayToEndTimeNotification:(NSNotification *)notification
{
    VDLog(@"AVPlayerItemFailedToPlayToEndTimeNotification :%@",notification.userInfo);
    PKVideoPlayerError *error = [PKVideoPlayerError errorWithDomain:PKVideoPlayerErrorDomain
                                                               code:PKVideoPlayerErrorPlayerItemFailedToPlayToEndTime
                                                           userInfo:notification.userInfo];
    [self updatePlayStatus:PKVideoPlayerPlayStatus_Failed error:error];
}

- (void)registerNotifications
{
    if (self.currentItem == nil) {
        return;
    }
    VDLog(@"#### registerNotifications :%@",self.currentItem);
    // notification userInfo key
    // AVPlayerItemFailedToPlayToEndTimeErrorKey     NS_AVAILABLE(10_7, 4_3);   // NSError
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // item has played to its end time
    [notificationCenter addObserver:self
                           selector:@selector(playerItemDidPlayToEndTimeNotification:)
                               name:AVPlayerItemDidPlayToEndTimeNotification
                             object:self.currentItem];
    
    // item has failed to play to its end time
    [notificationCenter addObserver:self
                           selector:@selector(playerItemFailedToPlayToEndTimeNotification:)
                               name:AVPlayerItemFailedToPlayToEndTimeNotification
                             object:self.currentItem];
}

- (void)unregisterNotifications
{
    if (self.currentItem == nil) {
        return;
    }
    VDLog(@"#### unregisterNotifications :%@",self.currentItem);
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:AVPlayerItemDidPlayToEndTimeNotification
                                object:self.currentItem];
    [notificationCenter removeObserver:self
                                  name:AVPlayerItemFailedToPlayToEndTimeNotification
                                object:self.currentItem];
}

#pragma mark - Propertys

- (CGFloat)playerCurrentTime
{
    if (self.currentItem && self.playerVideoPlayable) {
        if (!self.isSeeking) {
            CMTime time = [[self currentItem] currentTime];
            if (CMTIME_IS_INVALID(time)) {
                _playerCurrentTime = 0.0f;
            } else if (CMTIME_IS_INDEFINITE(time)) { // Live
                _playerCurrentTime = 0.0f;
            } else {
                _playerCurrentTime = CMTimeGetSeconds(time);
            }
        }// 如果是seeking情况，直接返回_playerCurrentTime
    } else {
        _playerCurrentTime = 0.0f;
    }
    return _playerCurrentTime;
}

- (CGFloat)playerDuration
{
    if (self.currentItem && self.playerVideoPlayable) {
        CMTime time = [[self currentItem] duration];
        if (CMTIME_IS_INVALID(time)) {
            _playerDuration = 0.0f;
        } else if (CMTIME_IS_INDEFINITE(time)) { // Live
            _playerDuration = CGFLOAT_MAX;
        } else {
            _playerDuration = CMTimeGetSeconds(time);
        }
    } else {
        _playerDuration = 0.0f;
    }
    return _playerDuration;
}

- (CGFloat)playerAvailableDuration
{
    CGFloat ret = 0.0f;
    if (self.playerVideoPlayable) {
        NSArray *loadedTimeRanges = [[self currentItem] loadedTimeRanges];
        if ([loadedTimeRanges count] > 0)
        {
            CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
            float startSeconds = CMTimeGetSeconds(timeRange.start);
            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
            ret = (startSeconds + durationSeconds);
        }
    }
    // 避免预加载时间长大于总时长
    return MIN(ret, self.playerDuration);
}

- (void)setPlayerShouldAutoPlay:(BOOL)playerShouldAutoPlay
{
    if (_playerShouldAutoPlay != playerShouldAutoPlay)
    {
        _playerShouldAutoPlay = playerShouldAutoPlay;
        // 未载入前，手动更改状态
        if (PKVideoPlayerPlayStatus_Unknow == self.playStatus) {
            if (playerShouldAutoPlay) {
                [self updatePlayStatus:PKVideoPlayerPlayStatus_Play error:nil];
                //_playStatus = PKVideoPlayerPlayStatus_Play;
            } else {
                [self updatePlayStatus:PKVideoPlayerPlayStatus_Pause error:nil];
                //_playStatus = PKVideoPlayerPlayStatus_Pause;
            }
        }
    }
}

@end
