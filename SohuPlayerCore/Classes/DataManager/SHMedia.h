//
//  SHMedia.h
//  SohuVideoSDK
//
//  Created by wangzy on 13-9-16.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    SHSohuMedia     = 101,        // 搜狐的播放对象
    SHCommonMedia   = 102,        // 任意来源的播放地址 (包括直播视频)
    SHLiveMedia     = 103,        // 直播播放地址（分两类：直播间视频；电台直播视频）
    SHLocalDownload = 104,        // 离线下载播放地址
};
typedef NSInteger SHMediaSourceType;

@interface SHMedia : NSObject

@property (nonatomic, assign) SHMediaSourceType sourceType; // 视频来源
@property (nonatomic, copy) NSString *identifier;           // 第三方定义的唯一标识
@property (nonatomic, copy) NSString *lid;                  // 搜狐直播视频id（或电台ID）
@property (nonatomic, copy) NSString *aid;                  // 搜狐视频专辑id
@property (nonatomic, copy) NSString *vid;                  // 搜狐来源的vid/第三方视频的vid
@property (nonatomic, assign) NSInteger site;               // 搜狐来源,和搜狐视频vid绑定（1：vrs数据；2：ugc数据；３：直播数据）
@property (nonatomic, assign) float duration;               // 视频时长

@property (nonatomic, copy) NSString *url;                  // 任意来源的uri
@property (nonatomic, copy) NSString *advUrl;               // 符合WAST协议的广告url

@end
