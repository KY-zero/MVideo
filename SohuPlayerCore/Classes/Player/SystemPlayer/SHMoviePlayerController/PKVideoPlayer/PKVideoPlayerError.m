//
//  PKVideoPlayerError.m
//  PKTestProj
//
//  Created by zhongsheng on 13-8-25.
//  Copyright (c) 2013年 zhongsheng. All rights reserved.
//

#import "PKVideoPlayerError.h"

@implementation PKVideoPlayerError

+ (PKVideoPlayerError *)errorWithNSError:(NSError *)error
{
    if (error) {
        PKVideoPlayerError *playerError = [PKVideoPlayerError errorWithDomain:error.domain
                                                                         code:error.code
                                                                     userInfo:error.userInfo];
        return playerError;
    }
    return nil;
}

@end

NSString* const PKVideoPlayerErrorDomain = @"PKVideoPlayerErrorDomain";