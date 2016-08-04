//
//  PKVideoPlayer.h
//  PKTestProj
//
//  Created by zhongsheng on 14-1-21.
//  Copyright (c) 2014年 zhongsheng. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, PKVideoPlayerLoadStatus) {
    PKVideoPlayerLoadStatus_Unload,
    PKVideoPlayerLoadStatus_LoadFailed,
    PKVideoPlayerLoadStatus_Loading,
    PKVideoPlayerLoadStatus_LoadSuccessed,
};

typedef NS_ENUM(NSInteger, PKVideoPlayerPlayStatus) {
    PKVideoPlayerPlayStatus_Unknow = -1,
    PKVideoPlayerPlayStatus_Failed,
    PKVideoPlayerPlayStatus_Stop,
    PKVideoPlayerPlayStatus_Play,
    PKVideoPlayerPlayStatus_Pause,
    PKVideoPlayerPlayStatus_ReachEnd,
    PKVideoPlayerPlayStatus_Forward,
    PKVideoPlayerPlayStatus_Backward
};

@class PKVideoPlayerError;
@protocol PKVideoPlayerItem;
@protocol PKVideoPlayerDelegate;

@interface PKVideoPlayer : AVPlayer

@property (nonatomic,     weak) id<PKVideoPlayerDelegate> playerDelegate;

@property (nonatomic,   assign) BOOL playerShouldAutoPlay; // Default is YES 是否自动播放

@property (nonatomic, readonly) PKVideoPlayerLoadStatus loadStatus;

@property (nonatomic, readonly) PKVideoPlayerPlayStatus playStatus;

@property (nonatomic, readonly) id<PKVideoPlayerItem> currentPlayerItem;

@property (nonatomic, readonly) CGFloat playerCurrentTime;

@property (nonatomic, readonly) CGFloat playerDuration;

@property (nonatomic, readonly) CGFloat playerAvailableDuration;

@property (nonatomic, readonly) BOOL playerVideoPlayable;

- (void)setVideoPlayerItem:(id<PKVideoPlayerItem>)playerItem;

- (void)playerPlay;

- (void)playerPause;

- (void)playerStop;

- (void)playerSeekToTime:(CGFloat)time;

- (void)playerSeekToTime:(CGFloat)time completionHandler:(void (^)(BOOL finished))completionHandler;

@end

@protocol PKVideoPlayerDelegate <NSObject>

@optional

- (void)videoPlayer:(PKVideoPlayer *)player updateLoadStatus:(PKVideoPlayerLoadStatus)status error:(PKVideoPlayerError *)error;

- (void)videoPlayer:(PKVideoPlayer *)player updatePlayStatus:(PKVideoPlayerPlayStatus)status error:(PKVideoPlayerError *)error;

- (void)videoPlayer:(PKVideoPlayer *)player updateBufferTime:(CGFloat)bufferTime;

- (void)videoPlayer:(PKVideoPlayer *)player willLoadVideoPlayerItem:(id<PKVideoPlayerItem>)playerItem;

- (void)videoPlayer:(PKVideoPlayer *)player didLoadVideoPlayerItem:(id<PKVideoPlayerItem>)playerItem;

@end

@protocol PKVideoPlayerItem <NSObject>

@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, assign) CGFloat beginTime;

@end

