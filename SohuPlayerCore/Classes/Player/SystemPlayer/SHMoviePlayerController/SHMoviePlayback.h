//
//  SHMoviePlayback.h
//  PKTestProj
//
//  Created by zhongsheng on 14-3-6.
//  Copyright (c) 2014年 zhongsheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SHMoviePlayback

// Prepares the current queue for playback, interrupting any active (non-mixible) audio sessions.
// Automatically invoked when -play is called if the player is not already prepared.
- (void)prepareToPlay;

// Returns YES if prepared for playback.
@property(nonatomic, readonly) BOOL isPreparedToPlay;

// Plays items from the current queue, resuming paused playback if possible.
- (void)play;

// Pauses playback if playing.
- (void)pause;

// Ends playback. Calling -play again will start from the beginnning of the queue.
- (void)stop;

// The current playback time of the now playing item in seconds.
@property(nonatomic) NSTimeInterval currentPlaybackTime;

@end

// Posted when the prepared state changes of an object conforming to the SHMediaPlayback protocol changes.
extern NSString *const SHMediaPlaybackIsPreparedToPlayDidChangeNotification NS_AVAILABLE_IOS(3_2);
