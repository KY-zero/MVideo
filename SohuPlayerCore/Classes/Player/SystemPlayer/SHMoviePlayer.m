//
//  SHMoviePlayer.m
//  SohuPlayerCore
//
//  Created by Cui Chunjian on 10/8/13.
//  Copyright (c) 2013 Sohu Inc. All rights reserved.
//

#import "SHMoviePlayer.h"

@interface SHMoviePlayer () {
}

@property (nonatomic, assign) SHMoviePlaybackState lastPlaybackState;
@end

@implementation SHMoviePlayer

@synthesize delegate;
@synthesize finishReason;

- (id)init {
    self = [super init];
    if (self) {
        self.view.userInteractionEnabled = NO;
        [self registerMovieNotificationObservers];
    }
    return self;
}

- (void)exitPlay {
    [self stop];
    self.contentURL = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - common codes (system and custom player)

- (void)registerMovieNotificationObservers {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(playerLoadStateDidChange:)
                               name:SHMoviePlayerLoadStateDidChangeNotification
                             object:nil];
    [notificationCenter addObserver:self selector:@selector(playbackDurationAvailable:)
                               name:SHMovieDurationAvailableNotification
                             object:nil];
    [notificationCenter addObserver:self selector:@selector(playbackStateDidChange:)
                               name:SHMoviePlayerPlaybackStateDidChangeNotification
                             object:nil];
    [notificationCenter addObserver:self selector:@selector(playbackPrepared:)
                               name:SHMediaPlaybackIsPreparedToPlayDidChangeNotification
                             object:nil];
    [notificationCenter addObserver:self selector:@selector(playerPlaybackDidFinish:)
                               name:SHMoviePlayerPlaybackDidFinishNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(playerIsAirPlayVideoActiveDidChange:)
                               name:SHMoviePlayerIsAirPlayVideoActiveDidChangeNotification
                             object:nil];
    [notificationCenter addObserver:self selector:@selector(playerNowPlayingMovieDidChange:)
                               name:SHMoviePlayerNowPlayingMovieDidChangeNotification
                             object:nil];
}

- (void)playbackDurationAvailable:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(playbackDurationAvailable:)]) {
        [self.delegate playbackDurationAvailable:self];
    }
}

- (void)playerLoadStateDidChange:(NSNotification *)notification {
    if (notification.object != self) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(playerLoadStateDidChange:)]) {
        [self.delegate playerLoadStateDidChange:self];
    }
}

- (void)playbackStateDidChange:(NSNotification *)notification {
    if (notification.object != self) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(playerPlaybackStateDidChange:)]) {
        [self.delegate playerPlaybackStateDidChange:self];
    }
    
    SHMoviePlaybackState playbackState = [self playbackState];
    
    switch (playbackState) {
        case SHMoviePlaybackStateUnknown:
        case SHMoviePlaybackStateInterrupted:
        case SHMoviePlaybackStateSeekingForward:
        case SHMoviePlaybackStateSeekingBackward: {
            if (self.lastPlaybackState != SHMoviePlaybackStatePaused) {
                [self playbackPreparing];
            }
        }
            break;
        case SHMoviePlaybackStateStopped:
        case SHMoviePlaybackStatePlaying:
        case SHMoviePlaybackStatePaused:
        default:
            break;
    }
    self.lastPlaybackState = playbackState;
}

- (void)playbackPreparing {
    if ([self.delegate respondsToSelector:@selector(playbackPreparing:)]) {
        [self.delegate playbackPreparing:self];
    }
}

- (void)playbackPrepared:(NSNotification *)notification {
    if (notification.object != self) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(playbackPrepared:)]) {
        [self.delegate playbackPrepared:self];
    }
}

- (void)playerPlaybackDidFinish:(NSNotification *)notification {
    if (notification.object != self) {
        return;
    }

    finishReason = [[notification.userInfo objectForKey:SHMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    
    switch (finishReason) {
        case SHMovieFinishReasonPlaybackEnded:
            break;
        case SHMovieFinishReasonPlaybackError:
            break;
        case SHMovieFinishReasonUserExited:
            break;
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(playerPlaybackDidFinish:)]) {
        [self.delegate playerPlaybackDidFinish:self];
    }
}

- (void)playerIsAirPlayVideoActiveDidChange:(NSNotification *)notification {
    if (notification.object != self) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(playerIsAirPlayVideoActiveDidChange:)]) {
        [self.delegate playerIsAirPlayVideoActiveDidChange:self];
    }
}

- (void)playerNowPlayingMovieDidChange:(NSNotification *)notification {
    if (notification.object != self) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(playerNowPlayingMovieDidChange:)]) {
        [self.delegate playerNowPlayingMovieDidChange:self];
    }
    // initial playback finish reason when movie started.
    finishReason = SHMovieFinishReasonUnknown;
    [self playbackPreparing];
}

@end
