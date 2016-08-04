//
//  SHMoviePlayerController+PKVideoPlayerDelegate.m
//  PKTestProj
//
//  Created by zhongsheng on 14-3-6.
//  Copyright (c) 2014年 zhongsheng. All rights reserved.
//

#import "SHPMoviePlayerController+PKVideoPlayerDelegate.h"
#import <objc/runtime.h>

static void *const _kSHMoviePlayerControllerAssociatedPrepareLoadAndPlayKey = (void *)&_kSHMoviePlayerControllerAssociatedPrepareLoadAndPlayKey;

static void *const _kSHMoviePlayerControllerAssociatedRetryTimesKey = (void *)&_kSHMoviePlayerControllerAssociatedRetryTimesKey;


@implementation SHPMoviePlayerController (PKVideoPlayerDelegate)

- (void)videoPlayer:(PKVideoPlayer *)player updateLoadStatus:(PKVideoPlayerLoadStatus)status error:(PKVideoPlayerError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SHMoviePlayerLoadStateDidChangeNotification object:self];
    switch (status) {
        case PKVideoPlayerLoadStatus_LoadFailed:
            if (self.retryTimes < kSHMoviePlayerMaxRertyTimes)
            {
                ++self.retryTimes;
                [self forceRetryPlayCurrentVideo];
            }else{
                self.retryTimes = 0;
                _isPreparedToPlay = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:SHMoviePlayerPlaybackDidFinishNotification object:self userInfo:@{SHMoviePlayerPlaybackDidFinishReasonUserInfoKey:@(SHMovieFinishReasonPlaybackError)}];
            }
            break;
        case PKVideoPlayerLoadStatus_Unload:
            if (_isPreparedToPlay && (self.retryTimes >= kSHMoviePlayerMaxRertyTimes || self.retryTimes == 0)) {
                self.retryTimes = 0;
                _isPreparedToPlay = NO;
            }
            break;
        default:
            break;
    }
    NSString *loadStatus = nil;
    switch (status) {
        case PKVideoPlayerLoadStatus_Unload:
            loadStatus = @"Unload";
            break;
        case PKVideoPlayerLoadStatus_Loading:
            loadStatus = @"Loading";
            break;
        case PKVideoPlayerLoadStatus_LoadSuccessed:
            loadStatus = @"LoadSuccessed";
            break;
        case PKVideoPlayerLoadStatus_LoadFailed:
            loadStatus = @"LoadFailed";
            break;
        default:
            loadStatus = [NSString stringWithFormat:@"%d",status];
            break;
    }
    VDLog(@"update Status [Load] ===> %@   withError:%@ retryTimes:%d",loadStatus,error,self.retryTimes);
}

- (void)videoPlayer:(PKVideoPlayer *)player updatePlayStatus:(PKVideoPlayerPlayStatus)status error:(PKVideoPlayerError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SHMoviePlayerPlaybackStateDidChangeNotification object:self];
    switch (status) {
        case PKVideoPlayerPlayStatus_ReachEnd:
            [[NSNotificationCenter defaultCenter] postNotificationName:SHMoviePlayerPlaybackDidFinishNotification object:self userInfo:@{SHMoviePlayerPlaybackDidFinishReasonUserInfoKey:@(SHMovieFinishReasonPlaybackEnded)}];
            break;
        case PKVideoPlayerPlayStatus_Failed:
            [[NSNotificationCenter defaultCenter] postNotificationName:SHMoviePlayerPlaybackDidFinishNotification object:self userInfo:@{SHMoviePlayerPlaybackDidFinishReasonUserInfoKey:@(SHMovieFinishReasonPlaybackError)}];
            break;
        case PKVideoPlayerPlayStatus_Stop:
            [[NSNotificationCenter defaultCenter] postNotificationName:SHMoviePlayerPlaybackDidFinishNotification object:self userInfo:@{SHMoviePlayerPlaybackDidFinishReasonUserInfoKey:@(SHMovieFinishReasonUserExited)}];
            break;
        default:
            break;
    }
    NSString *playStatus = nil;
    switch (status) {
        case PKVideoPlayerPlayStatus_Unknow:
            playStatus = @"Unknow";
            break;
        case PKVideoPlayerPlayStatus_Stop:
            playStatus = @"Stop";
            break;
        case PKVideoPlayerPlayStatus_Play:
            playStatus = @"Play";
            break;
        case PKVideoPlayerPlayStatus_Pause:
            playStatus = @"Pause";
            break;
        case PKVideoPlayerPlayStatus_ReachEnd:
            playStatus = @"ReachEnd";
            break;
        case PKVideoPlayerPlayStatus_Failed:
            playStatus = @"Failed";
            break;
        default:
            playStatus = [NSString stringWithFormat:@"%d",status];
            break;
    }
    VDLog(@"update Status [Play] ===> %@ %@",playStatus,error);
}

- (void)videoPlayer:(PKVideoPlayer *)player updateBufferTime:(CGFloat)bufferTime {}

- (void)videoPlayer:(PKVideoPlayer *)player willLoadVideoPlayerItem:(id<PKVideoPlayerItem>)playerItem
{
    _isPreparedToPlay = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:SHMoviePlayerNowPlayingMovieDidChangeNotification object:self];
}

- (void)videoPlayer:(PKVideoPlayer *)player didLoadVideoPlayerItem:(id<PKVideoPlayerItem>)playerItem
{
    _isPreparedToPlay = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SHMovieDurationAvailableNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHMediaPlaybackIsPreparedToPlayDidChangeNotification object:self];
    if (!self.prepareLoadAndPlay) { // 如果没调用 play 方法 则暂停
        [player playerPause];
    }
    if (SHPMovieLoadStateUnknown == self.loadState) {
        _loadState = SHPMovieLoadStatePlayable;
    }
}

#pragma mark - Getter/Setter

- (void)setPrepareLoadAndPlay:(BOOL)prepareLoadAndPlay
{
    [self willChangeValueForKey:@"prepareLoadAndPlay"];
    objc_setAssociatedObject(self, _kSHMoviePlayerControllerAssociatedPrepareLoadAndPlayKey, [NSNumber numberWithBool:prepareLoadAndPlay], OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"prepareLoadAndPlay"];
}

- (BOOL)prepareLoadAndPlay
{
    BOOL ret = [objc_getAssociatedObject(self, _kSHMoviePlayerControllerAssociatedPrepareLoadAndPlayKey) boolValue];
    return ret;
}

- (void)setRetryTimes:(NSInteger)retryTimes
{
    [self willChangeValueForKey:@"retryTimes"];
    objc_setAssociatedObject(self, _kSHMoviePlayerControllerAssociatedRetryTimesKey, [NSNumber numberWithInteger:retryTimes], OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"retryTimes"];
}

- (NSInteger)retryTimes
{
    NSInteger ret = [objc_getAssociatedObject(self, _kSHMoviePlayerControllerAssociatedRetryTimesKey) integerValue];
    return ret;
}

@end
