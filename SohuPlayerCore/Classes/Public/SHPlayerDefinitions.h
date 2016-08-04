//
//  SHPlayerDefinitions.h
//  SohuPlayerCore
//
//  Created by wangzy on 13-9-27.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//
//

#import <MediaPlayer/MediaPlayer.h>

#define SHInvalid -9998

enum {
    SHAdvertTypeOad,    // 前贴
    SHAdvertTypePad,    // 暂停
    SHAdvertTypeBanner, // banner通栏
    SHAdvertTypeOpen,   // 开机启动图
    SHAdvertTypeFocus   // 焦点图
};
typedef NSInteger SHAdvertType;

enum {
    SHQualityUlitra   = 0, // 超清
    SHQualityHigh     = 1, // 高清
    SHQualityNormal   = 2, // 流畅
};
typedef NSUInteger SHQualityType;

enum {
    SHAdvertNotAllowPlay,
    SHAdvertAllowPlay,
    SHAdvertServerAllowPlay
};
typedef NSInteger SHAdvertPlayType;