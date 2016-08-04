//
//  SHCustomPlayerController.m
//  SohuVideoSDK
//
//  Created by wangzy on 13-9-16.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//

#import "SHCustomPlayer.h"

@implementation SHCustomPlayer
@synthesize delegate;
@synthesize view;
@synthesize backgroundView;
@synthesize contentURL;
@synthesize playbackState;
@synthesize loadState;
@synthesize repeatMode;
@synthesize shouldAutoplay;
@synthesize fullscreen;
@synthesize scalingMode;
@synthesize controlStyle;
@synthesize readyForDisplay;
@synthesize movieMediaTypes;
@synthesize movieSourceType;
@synthesize duration;
@synthesize playableDuration;
@synthesize naturalSize;
@synthesize initialPlaybackTime;
@synthesize endPlaybackTime;
@synthesize allowsAirPlay;
@synthesize airPlayVideoActive;

- (id)initWithContentURL:(NSURL *)url {
    self = [super init];
    if (self) {
        // custom code
    }
    return self;
}

- (void)setFullscreen:(BOOL)aFullscreen animated:(BOOL)animated {
    
}
@end
