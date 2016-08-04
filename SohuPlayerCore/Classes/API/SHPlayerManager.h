//
//  SHPlayerController.h
//  SohuVideoSDK
//
//  Created by wangzy on 13-9-17.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHMoviePlayer.h"
#import "SHMoviePlayerController.h"
#import "SHMedia.h"

@class VideoItem;

#pragma mark--
#pragma protocol
@protocol SHPlayerManagerProtocol <NSObject>
- (void)playerPlayWithURL:(NSURL *)contentURL initialPlaybackTime:(NSTimeInterval)initialTime;

- (void)playerPreloadWithMedia:(SHMedia *)media;
- (void)playerPreloadWithVideoItem:(VideoItem *)videoItem;

- (void)playerPlayWithMedia:(SHMedia *)media;
- (void)playerPlayWithVideoItem:(VideoItem *)videoItem;

- (void)playerPlay;
- (void)playerStop;
- (void)playerPause;
- (void)playerSeekTo:(NSTimeInterval)newPos;
@end


#pragma delegate
@protocol PlayerManagerDelegate;

@interface SHPlayerManager : NSObject <SHPlayerManagerProtocol, SHPlayerDelegate>

@property (nonatomic, assign) id<PlayerManagerDelegate> delegate;
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, copy) NSURL *conentUrl;

@property (nonatomic, assign) BOOL shouldAutoplay;
@property (nonatomic, assign) BOOL muted;// 是否静音
@property (nonatomic, assign) SHMovieScalingMode movieScaleMode;
@property (nonatomic, assign) SHMovieQualityType movieQualityType;

@property (nonatomic, readonly, assign) SHMoviePlaybackState playbackState;
@property (nonatomic, readonly, assign) SHPrivateMovieLoadState loadState;
@property (nonatomic, readonly, assign) SHMediaSourceType mediaSourceType;

@property (nonatomic, readonly, assign, getter = isPlayerActiviting) BOOL playerActiviting;
@property (nonatomic, readonly, assign, getter = isPlayerStop)       BOOL playerStop;

@property (nonatomic, assign) BOOL allowsAirPlay;
@property (nonatomic, readonly, assign, getter = isAirPlayActive) BOOL airPlayActive;
@property (nonatomic, readonly, assign, getter = isAirPlaying)    BOOL airPlaying;

@property(nonatomic, getter=isFullscreen) BOOL fullscreen;
- (void)setFullscreen:(BOOL)aFullscreen animated:(BOOL)animated;

@property (nonatomic, readonly, assign) NSTimeInterval duration;
@property (nonatomic, readonly, assign) NSTimeInterval initialPlaybackTime;
@property (nonatomic, readonly, assign) NSTimeInterval currentPlaybackTime;
@property (nonatomic, readonly, assign) float currentPlaybackRate;
@property (nonatomic, readonly, assign) NSTimeInterval playableDuration;

@property (nonatomic, assign) BOOL isFirstPlayVideo; // 是否是第一个播放视频, 用于统计连播还是手动点击播放
@property (nonatomic, assign) BOOL isInAdvertMode;
@property (nonatomic, assign) BOOL openPreloadModel;

- (void)playerWillDestroy;
@end

#pragma mark--
#pragma delegate
@protocol PlayerManagerDelegate <NSObject>
@optional
- (void)playbackLoadDuration:(NSTimeInterval)loadDuration success:(BOOL)success;
- (void)playbackDurationAvailable:(SHPlayerManager *)player;
- (void)playbackPreparing:(SHPlayerManager *)playerManager;
- (void)playbackStalling:(SHPlayerManager *)playerManager;
- (void)playbackPrepared:(SHPlayerManager *)playerManager;
- (void)playbackStart:(SHPlayerManager *)playerManager;

- (void)playerPlaybackStateDidChange:(SHPlayerManager *)playerManager;
- (void)playerPlaybackDidFinish:(SHPlayerManager *)playerManager reason:(SHMovieFinishReason)finishedReason;
- (void)playerPlaybackError:(SHPlayerManager *)playerManager error:(NSError *)error;

- (void)playerIsAirPlayVideoActiveDidChange:(SHPlayerManager *)playerManager;
@end
