//
//  PKVideoPlayerError.h
//  PKTestProj
//
//  Created by zhongsheng on 13-8-25.
//  Copyright (c) 2013年 zhongsheng. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: errorCode ...

extern NSString *const PKVideoPlayerErrorDomain;

@interface PKVideoPlayerError : NSError
+ (PKVideoPlayerError *)errorWithNSError:(NSError *)error;
@end

typedef NS_ENUM(NSInteger, PKVideoPlayerErrorCode){
    PKVideoPlayerErrorUnknow  = 0,
    PKVideoPlayerErrorPlayerItemFailedToPlayToEndTime,       // 结束播放失败
    PKVideoPlayerErrorOther,                                 // 用与扩展
};
