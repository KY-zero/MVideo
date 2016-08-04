//
//  SHMoviePlayerController+PKVideoPlayerDelegate.h
//  PKTestProj
//
//  Created by zhongsheng on 14-3-6.
//  Copyright (c) 2014年 zhongsheng. All rights reserved.
//

#import "SHPMoviePlayerController.h"
#import "PKVideoPlayerKit.h"

#define kSHMoviePlayerMaxRertyTimes (1)

@interface SHPMoviePlayerController (PKVideoPlayerDelegate) <PKVideoPlayerDelegate>

@property (nonatomic, assign) BOOL prepareLoadAndPlay;

@property (nonatomic, assign) NSInteger retryTimes;

@end
