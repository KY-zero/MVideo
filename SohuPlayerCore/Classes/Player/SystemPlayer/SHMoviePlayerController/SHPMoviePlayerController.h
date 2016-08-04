//
//  SHMoviePlayerController.h
//  PKTestProj
//
//  Created by zhongsheng on 14-3-5.
//  Copyright (c) 2014年 zhongsheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHMoviePlayback.h"

enum {
    SHMovieScalingModeNone,       // No scaling
    SHMovieScalingModeAspectFit,  // Uniform scale until one dimension fits
    SHMovieScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents
    SHMovieScalingModeFill        // Non-uniform scale. Both render dimensions will exactly match the visible bounds
};
typedef NSInteger SHMovieScalingMode;

enum {
    SHMoviePlaybackStateStopped,
    SHMoviePlaybackStatePlaying,
    SHMoviePlaybackStatePaused,
    SHMoviePlaybackStateInterrupted,
    SHMoviePlaybackStateSeekingForward,
    SHMoviePlaybackStateSeekingBackward,
    SHMoviePlaybackStateUnknown
};
typedef NSInteger SHMoviePlaybackState;

enum {
    SHPMovieLoadStateUnknown        = 0,
    SHPMovieLoadStatePlayable       = 1 << 0,
    SHPMovieLoadStatePlaythroughOK  = 1 << 1, // buffer 满了,可以播放了
    SHPMovieLoadStateStalled        = 1 << 2, // buffer 不满,卡顿状态
};
typedef NSInteger SHPMovieLoadState;

//enum {
//    SHMovieRepeatModeNone,
//    SHMovieRepeatModeOne
//};
//typedef NSInteger SHMovieRepeatMode;

//enum {
//    SHMovieControlStyleNone,       // No controls
//    SHMovieControlStyleEmbedded,   // Controls for an embedded view
//    SHMovieControlStyleFullscreen, // Controls for fullscreen playback
//
//    SHMovieControlStyleDefault = SHMovieControlStyleEmbedded
//};
//typedef NSInteger SHMovieControlStyle;

enum {
    SHMovieFinishReasonPlaybackEnded,
    SHMovieFinishReasonPlaybackError,
    SHMovieFinishReasonUserExited,
    SHMovieFinishReasonURLChanged = 999,
    SHMovieFinishReasonSkipToTail,
    SHMovieFinishReasonUnknown
};
typedef NSInteger SHMovieFinishReason;

// -----------------------------------------------------------------------------
// Movie Property Types

//enum {
//    SHMovieMediaTypeMaskNone  = 0,
//    SHMovieMediaTypeMaskVideo = 1 << 0,
//    SHMovieMediaTypeMaskAudio = 1 << 1
//};
//typedef NSInteger SHMovieMediaTypeMask;

enum {
    SHMovieSourceTypeUnknown,
    SHMovieSourceTypeFile,     // Local or progressively downloaded network content
    SHMovieSourceTypeStreaming // Live or on-demand streaming content
};
typedef NSInteger SHMovieSourceType;


// -----------------------------------------------------------------------------
// Movie Player
//

@interface SHPMoviePlayerController : NSObject <SHMoviePlayback>{
    BOOL _isPreparedToPlay;
    SHPMovieLoadState _loadState;
}

- (id)initWithContentURL:(NSURL *)url;

// 解决AVPlayer黑屏问题,出问题了,调用一次即可。
- (void)resetPlayer;
// 强制重试用,切换视频源码流无法播放,通过销毁播放器方式,重新播放
- (void)forceRetryPlayCurrentVideo;

@property(nonatomic, copy) NSURL *contentURL;

// The view in which the media and playback controls are displayed.
@property(nonatomic, readonly) UIView *view; // <SHMovieView>

// A view for customization which is always displayed behind movie content.
//@property(nonatomic, readonly) UIView *backgroundView; // 真正的层次应该是这样的: MovieView-SwipableView-VideoContainerView-backgroundView

// Returns the current playback state of the movie player.
@property(nonatomic, readonly) SHMoviePlaybackState playbackState;

// Returns the network load state of the movie player.
@property(nonatomic, readonly) SHPMovieLoadState loadState;

@property(nonatomic) BOOL muted;

// The style of the playback controls. Defaults to SHMovieControlStyleDefault.
//@property(nonatomic) SHMovieControlStyle controlStyle;

// Determines how the movie player repeats when reaching the end of playback. Defaults to SHMovieRepeatModeNone.
//@property(nonatomic) SHMovieRepeatMode repeatMode;

// Indicates if a movie should automatically start playback when it is likely to finish uninterrupted based on e.g. network conditions. Defaults to YES.
@property(nonatomic) BOOL shouldAutoplay;

// Determines if the movie is presented in the entire screen (obscuring all other application content). Default is NO.
// Setting this property to YES before the movie player's view is visible will have no effect.
//@property(nonatomic, getter=isFullscreen) BOOL fullscreen;
//- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated;

// Determines how the content scales to fit the view. Defaults to SHMovieScalingModeAspectFit.
@property(nonatomic) SHMovieScalingMode scalingMode;

// Returns YES if the first video frame has been made ready for display for the current item.
// Will remain NO for items that do not have video tracks associated.
//@property(nonatomic, readonly) BOOL readyForDisplay;

// The current playback rate of the now playing item. Default is 1.0 (normal speed).
// Pausing will set the rate to 0.0. Setting the rate to non-zero implies playing.
@property(nonatomic) float currentPlaybackRate;
@end



@interface SHPMoviePlayerController (SHMovieProperties)

// The types of media in the movie, or SHMovieMediaTypeNone if not known.
//@property(nonatomic, readonly) SHMovieMediaTypeMask movieMediaTypes;

// The playback type of the movie. Defaults to SHMovieSourceTypeUnknown.
// Specifying a playback type before playing the movie can result in faster load times.
@property(nonatomic) SHMovieSourceType movieSourceType;

// The duration of the movie, or 0.0 if not known.
@property(nonatomic, readonly) NSTimeInterval duration;

// The currently playable duration of the movie, for progressively downloaded network content.
@property(nonatomic, readonly) NSTimeInterval playableDuration;

// The natural size of the movie, or CGSizeZero if not known/applicable.
//@property(nonatomic, readonly) CGSize naturalSize;

// The start time of movie playback. Defaults to NaN, indicating the natural start time of the movie.
//@property(nonatomic) NSTimeInterval initialPlaybackTime;

// The end time of movie playback. Defaults to NaN, which indicates natural end time of the movie.
//@property(nonatomic) NSTimeInterval endPlaybackTime;

// Indicates whether the movie player allows AirPlay video playback. Defaults to YES on iOS 5.0 and later.
@property(nonatomic) BOOL allowsAirPlay NS_AVAILABLE_IOS(4_3);

// Indicates whether the movie player is currently playing video via AirPlay.
@property(nonatomic, readonly, getter=isAirPlayVideoActive) BOOL airPlayVideoActive NS_AVAILABLE_IOS(5_0);

@end

// -----------------------------------------------------------------------------
// Movie Player Notifications

// Posted when the scaling mode changes.
extern NSString *const SHMoviePlayerScalingModeDidChangeNotification;

// Posted when movie playback ends or a user exits playback.
extern NSString *const SHMoviePlayerPlaybackDidFinishNotification;

extern NSString *const SHMoviePlayerPlaybackDidFinishReasonUserInfoKey NS_AVAILABLE_IOS(3_2); // NSNumber (SHMovieFinishReason)

// Posted when the playback state changes, either programatically or by the user.
extern NSString *const SHMoviePlayerPlaybackStateDidChangeNotification NS_AVAILABLE_IOS(3_2);

// Posted when the network load state changes.
extern NSString *const SHMoviePlayerLoadStateDidChangeNotification NS_AVAILABLE_IOS(3_2);

// Posted when the currently playing movie changes.
extern NSString *const SHMoviePlayerNowPlayingMovieDidChangeNotification NS_AVAILABLE_IOS(3_2);

// Posted when the movie player enters or exits fullscreen mode.
//extern NSString *const SHMoviePlayerWillEnterFullscreenNotification NS_AVAILABLE_IOS(3_2);
//extern NSString *const SHMoviePlayerDidEnterFullscreenNotification NS_AVAILABLE_IOS(3_2);
//extern NSString *const SHMoviePlayerWillExitFullscreenNotification NS_AVAILABLE_IOS(3_2);
//extern NSString *const SHMoviePlayerDidExitFullscreenNotification NS_AVAILABLE_IOS(3_2);
//extern NSString *const SHMoviePlayerFullscreenAnimationDurationUserInfoKey NS_AVAILABLE_IOS(3_2); // NSNumber of double (NSTimeInterval)
//extern NSString *const SHMoviePlayerFullscreenAnimationCurveUserInfoKey NS_AVAILABLE_IOS(3_2);     // NSNumber of NSUInteger (UIViewAnimationCurve)

// Posted when the movie player begins or ends playing video via AirPlay.
extern NSString *const SHMoviePlayerIsAirPlayVideoActiveDidChangeNotification NS_AVAILABLE_IOS(5_0);

// Posted when the ready for display state changes.
extern NSString *const SHMoviePlayerReadyForDisplayDidChangeNotification NS_AVAILABLE_IOS(6_0);

// -----------------------------------------------------------------------------
// Movie Property Notifications

// Calling -prepareToPlay on the movie player will begin determining movie properties asynchronously.
// These notifications are posted when the associated movie property becomes available.
//extern NSString *const SHMovieMediaTypesAvailableNotification NS_AVAILABLE_IOS(3_2);
//extern NSString *const SHMovieSourceTypeAvailableNotification NS_AVAILABLE_IOS(3_2); // Posted if the movieSourceType is SHMovieSourceTypeUnknown when preparing for playback.
extern NSString *const SHMovieDurationAvailableNotification NS_AVAILABLE_IOS(3_2);
//extern NSString *const SHMovieNaturalSizeAvailableNotification NS_AVAILABLE_IOS(3_2);
