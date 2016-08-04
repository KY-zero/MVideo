//
//  SHMoviePlayer.h
//  SohuPlayerCore
//
//  Created by Cui Chunjian on 10/8/13.
//  Copyright (c) 2013 Sohu Inc. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "SHPlayerDefinitions.h"
#import "SHPMoviePlayerController.h"

//enum {
//    SHMoviePlaybackStateStopped         = MPMoviePlaybackStateStopped,
//    SHMoviePlaybackStatePlaying         = MPMoviePlaybackStatePlaying,
//    SHMoviePlaybackStatePaused          = MPMoviePlaybackStatePaused,
//    SHMoviePlaybackStateInterrupted     = MPMoviePlaybackStateInterrupted,
//    SHMoviePlaybackStateSeekingForward  = MPMoviePlaybackStateSeekingForward,
//    SHMoviePlaybackStateSeekingBackward = MPMoviePlaybackStateSeekingBackward,
//    SHMoviePlaybackStateUnknown
//};
//typedef NSInteger SHMoviePlaybackState;

enum {
    SHPrivateMovieLoadStateUnknown         = MPMovieLoadStateUnknown,
    SHPrivateMovieLoadStatePlayable        = MPMovieLoadStatePlayable,
    SHPrivateMovieLoadStatePlaythroughOK   = MPMovieLoadStatePlaythroughOK,
    SHPrivateMovieLoadStateStalled         = MPMovieLoadStateStalled
};
typedef NSInteger SHPrivateMovieLoadState;

enum {
    SHPrivateMovieSourceTypeUnknown   = MPMovieSourceTypeUnknown,
    SHPrivateMovieSourceTypeFile      = MPMovieSourceTypeFile,
    SHPrivateMovieSourceTypeStreaming = MPMovieSourceTypeStreaming
};
typedef NSInteger SHPrivateMovieSourceType;

//enum {
//    SHMovieFinishReasonPlaybackEnded     = MPMovieFinishReasonPlaybackEnded,
//    SHMovieFinishReasonPlaybackError     = MPMovieFinishReasonPlaybackError,
//    SHMovieFinishReasonUserExited        = MPMovieFinishReasonUserExited,
//    SHMovieFinishReasonURLChanged        = 999,
//    SHMovieFinishReasonSkipToTail,
//    SHMovieFinishReasonUnknown
//};
//typedef NSInteger SHMovieFinishReason;

//enum {
//    SHMovieScalingModeNone       = MPMovieScalingModeNone,       // No scaling
//    SHMovieScalingModeAspectFit  = MPMovieScalingModeAspectFit,
//    SHMovieScalingModeAspectFill = MPMovieScalingModeAspectFill,
//    SHMovieScalingModeFill       = MPMovieScalingModeFill
//};
//typedef NSInteger SHMovieScalingMode;


@protocol SHPlayerDelegate;

@interface SHMoviePlayer : SHPMoviePlayerController

@property (nonatomic, assign) id<SHPlayerDelegate> delegate;
@property(nonatomic, readonly) SHMovieFinishReason finishReason;

- (void)exitPlay;
@end

// -------------------------------------------------------------------------
// SHPlayerDelegate provides callbacks for players' users

@protocol SHPlayerDelegate <NSObject>
@optional
- (void)playbackPreparing:(SHMoviePlayer *)player;
- (void)playbackPrepared:(SHMoviePlayer *)player;
- (void)playbackDurationAvailable:(SHMoviePlayer *)player;

// player status changed
- (void)playerLoadStateDidChange:(SHMoviePlayer *)player;
- (void)playerPlaybackStateDidChange:(SHMoviePlayer *)player;
- (void)playerNowPlayingMovieDidChange:(SHMoviePlayer *)player;
- (void)playerIsAirPlayVideoActiveDidChange:(SHMoviePlayer *)player;
- (void)playerPlaybackDidFinish:(SHMoviePlayer *)player;
- (void)playerThumbnailRequestDidFinish:(UIImage *)thumbnail atTime:(NSTimeInterval)time;
@end


