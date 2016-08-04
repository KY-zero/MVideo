//
//  SHPlayerSDKUtil.m
//  SohuPlayerSDK
//
//  Created by wangzy on 13-9-23.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//

#import "SHPlayerSDKUtil.h"
#import "VideoItem.h"
#import "SHMedia.h"
//#import "constants.h"
#import "SHPropertyDefinitions.h"
//#import "M9Utilities.h"

@implementation SHPlayerSDKUtil

+ (NSURL *)urlWithString:(NSString *)urlString {
    NSURL *url = nil;
    if (urlString != nil && urlString.length > 0) {
        if ([[urlString lowercaseString] hasPrefix:@"http://"] || [[urlString lowercaseString] hasPrefix:@"https://"]) {
            url = [NSURL URLWithString:urlString];
        } else {
            url = [NSURL fileURLWithPath:urlString];
        }
    }
    return url;
}

+ (NSURL *)getDefaultPlayURLOfVideoItem:(VideoItem *)aVideoItem {
    NSURL *playUrl = nil;
    // 标清 M3U8 播放地址
    if (nil != aVideoItem.mediumM3u8UrlString && aVideoItem.mediumM3u8UrlString.length > 0) {
        if (nil == playUrl) {
            playUrl = [NSURL URLWithString:aVideoItem.mediumM3u8UrlString];
        }
    }
    // 高清 M3U8 播放地址
    if (nil != aVideoItem.highM3u8UrlString && aVideoItem.highM3u8UrlString.length > 0) {
        playUrl = [NSURL URLWithString:aVideoItem.highM3u8UrlString];
    }
    // 超清 M3U8 播放地址
    if (nil != aVideoItem.superM3u8UrlString && aVideoItem.superM3u8UrlString.length > 0) {
        if (nil == playUrl) {
            playUrl = [NSURL URLWithString:aVideoItem.superM3u8UrlString];
        }
    }
    // 原画 M3U8 播放地址
    if (nil != aVideoItem.originalM3u8UrlString && aVideoItem.originalM3u8UrlString.length > 0) {
        if (nil == playUrl) {
            playUrl = [NSURL URLWithString:aVideoItem.originalM3u8UrlString];
        }
    }
    return [[self class] adapterVideoUrl:playUrl];
}

+ (NSURL *)getURLWithVideoItem:(VideoItem *)aVideoItem videoQuality:(SHQualityType)videoQuality {
    NSURL *url = nil;
    switch (videoQuality) {
        case SHQualityUlitra: {
            if (aVideoItem.superM3u8UrlString) {
                url = [NSURL URLWithString:aVideoItem.superM3u8UrlString];
            }
        }
            break;
        case SHQualityHigh: {
            if (aVideoItem.highM3u8UrlString) {
                url = [NSURL URLWithString:aVideoItem.highM3u8UrlString];
            }
        }
            break;
        case SHQualityNormal: {
            if (aVideoItem.mediumM3u8UrlString) {
                url = [NSURL URLWithString:aVideoItem.mediumM3u8UrlString];
            }
        }
            break;
        default:
            break;
    }

    return [[self class] adapterVideoUrl:url];
}

+ (NSArray *)getSupportQualityOfVideoItem:(VideoItem *)aVideoItem {
    NSMutableArray *qualityArray = [NSMutableArray array];
    // 高清 M3U8 播放地址
    if (nil != aVideoItem.highM3u8UrlString && aVideoItem.highM3u8UrlString.length > 0) {
        [qualityArray addObject:[NSNumber numberWithInt:SHQualityHigh]];
    }
    // 标清 M3U8 播放地址
    if (nil != aVideoItem.mediumM3u8UrlString && aVideoItem.mediumM3u8UrlString.length > 0) {
        [qualityArray addObject:[NSNumber numberWithInt:SHQualityNormal]];
    }
    // 超清 M3U8 播放地址
    if (nil != aVideoItem.superM3u8UrlString && aVideoItem.superM3u8UrlString.length > 0) {
        [qualityArray addObject:[NSNumber numberWithInt:SHQualityUlitra]];
    }
    return qualityArray;
}

+ (SHQualityType)getDefaultPlayQualityOfVideoItem:(VideoItem *)aVideoItem {
    // 标清 M3U8 播放地址
    if (nil != aVideoItem.mediumM3u8UrlString && aVideoItem.mediumM3u8UrlString.length > 0) {
        return SHQualityNormal;
    }
    // 高清 M3U8 播放地址
    if (nil != aVideoItem.highM3u8UrlString && aVideoItem.highM3u8UrlString.length > 0) {
        return SHQualityHigh;
    }
    // 超清 M3U8 播放地址
    if (nil != aVideoItem.superM3u8UrlString && aVideoItem.superM3u8UrlString.length > 0) {
        return SHQualityUlitra;
    }
    return SHQualityNormal;
}

+ (NSURL *)adapterVideoUrl:(NSURL *)url {
    NSURL *videoUrl = url;
    if (url) {
        NSString* videoUrlStr = [url absoluteString];
        if (![videoUrlStr hasPrefix:@"file://"]) {
            if ([videoUrlStr rangeOfString:@"plat="].location == NSNotFound) {
                NSString *plat = nil;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    plat = @"2";
                }else {
                    plat = @"3";
                }
                videoUrlStr = [[self class] stringByAppendingUrl:videoUrlStr parameter:plat forKey:@"plat"];
            }
            //CDN 需求
            if ([videoUrlStr rangeOfString:@"uid="].location == NSNotFound) {
                videoUrlStr = [[self class] stringByAppendingUrl:videoUrlStr parameter:@"" forKey:@"uid"];
            }
            if ([videoUrlStr rangeOfString:@"pt="].location == NSNotFound) { // 2, iPad; 3, iPhone
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    videoUrlStr = [[self class] stringByAppendingUrl:videoUrlStr parameter:@"2" forKey:@"pt"];
                }else {
                    videoUrlStr = [[self class] stringByAppendingUrl:videoUrlStr parameter:@"3" forKey:@"pt"];
                }
            }
            if ([videoUrlStr rangeOfString:@"prod="].location == NSNotFound) { // app, 移动客户端
                videoUrlStr = [[self class] stringByAppendingUrl:videoUrlStr parameter:@"news" forKey:@"prod"];
            }
            if ([videoUrlStr rangeOfString:@"pg="].location == NSNotFound) { // 1,在线；０，离线
                videoUrlStr = [[self class] stringByAppendingUrl:videoUrlStr parameter:@"1" forKey:@"pg"];
            }
        }
        videoUrl = [NSURL URLWithString:videoUrlStr];
    }
    return videoUrl;
}

+ (NSString *)stringByAppendingUrl:(NSString *)url parameter:(NSString *)param forKey:(NSString *)key
{
	NSRange ret = [url rangeOfString:@"?"];
	if(ret.location == NSNotFound)
	{
		url = [url stringByAppendingFormat:@"?%@=%@", key, param];
	}
	else
	{
		url = [url stringByAppendingFormat:@"&%@=%@", key, param];
	}
	
	return url;
}


@end
