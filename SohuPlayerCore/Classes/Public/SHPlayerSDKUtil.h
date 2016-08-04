//
//  SHPlayerSDKUtil.h
//  SohuPlayerSDK
//
//  Created by wangzy on 13-9-23.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPlayerDefinitions.h"

@class SHMedia;
@class VideoItem;

#define SHSize(__width__, __height__)                   CGSizeMake(__width__, __height__)
#define SHPoint(__x__, __y__)                           CGPointMake(__x__, __y__)
#define SHRect(__x__, __y__, __width__, __height__)     CGRectMake(__x__, __y__, __width__, __height__)
#define SHIntNumber(__int__)                            [NSNumber numberWithInt:__int__]
#define SHIntString(__int__)                            [NSString stringWithFormat:@"%i", __int__]
#define SHFloatString(__float__)                        [NSString stringWithFormat:@"%f", __float__]

/**
 * 判断指定的版本号v是否高于当前的系统版本
 */
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(__version__)  ([[[UIDevice currentDevice] systemVersion] compare:__version__ options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(__version__)     ([[[UIDevice currentDevice] systemVersion] compare:__version__ options:NSNumericSearch] != NSOrderedDescending)


@interface SHPlayerSDKUtil : NSObject

+ (NSURL *)urlWithString:(NSString *)urlString;

+ (NSURL *)getDefaultPlayURLOfVideoItem:(VideoItem *)aVideoItem;
+ (NSURL *)getURLWithVideoItem:(VideoItem *)aVideoItem videoQuality:(SHQualityType)videoQuality;
+ (NSArray *)getSupportQualityOfVideoItem:(VideoItem *)aVideoItem;
+ (SHQualityType)getDefaultPlayQualityOfVideoItem:(VideoItem *)aVideoItem;

+ (NSString *)getAdvParamDictionayFromThirdPartyMedia:(SHMedia *)media advType:(SHAdvertType)type;
@end
