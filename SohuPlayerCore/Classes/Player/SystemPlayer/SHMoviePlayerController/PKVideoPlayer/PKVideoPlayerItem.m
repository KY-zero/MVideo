//
//  PKVideoPlayerItem.m
//  PKTestProj
//
//  Created by zhongsheng on 13-9-2.
//  Copyright (c) 2013年 zhongsheng. All rights reserved.
//

#import "PKVideoPlayerItem.h"

@implementation PKVideoPlayerItem

+ (PKVideoPlayerItem *)itemWithURL:(NSURL *)URL beginTime:(CGFloat)time
{
    PKVideoPlayerItem *item = [[PKVideoPlayerItem alloc] init];
    item.URL = URL;
    item.beginTime = time;
    return item;
}

+ (PKVideoPlayerItem *)itemWithURL:(NSURL *)URL
{
    return [PKVideoPlayerItem itemWithURL:URL beginTime:0.0f];
}
@end
