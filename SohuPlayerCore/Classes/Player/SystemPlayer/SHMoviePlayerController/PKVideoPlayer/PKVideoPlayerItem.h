//
//  PKVideoPlayerItem.h
//  PKTestProj
//
//  Created by zhongsheng on 13-9-2.
//  Copyright (c) 2013年 zhongsheng. All rights reserved.
//

#import "PKVideoPlayerKit.h"

@interface PKVideoPlayerItem : NSObject <PKVideoPlayerItem>

@property (nonatomic, strong) NSURL *URL;         //<PKVideoPlayerItem>

@property (nonatomic, assign) CGFloat beginTime;  //<PKVideoPlayerItem>

+ (PKVideoPlayerItem *)itemWithURL:(NSURL *)URL;

+ (PKVideoPlayerItem *)itemWithURL:(NSURL *)URL beginTime:(CGFloat)time;

@end
