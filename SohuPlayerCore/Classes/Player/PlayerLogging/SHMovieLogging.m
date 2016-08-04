//
//  SHMovieLogging.m
//  SohuPlayerCore
//
//  Created by Cui Chunjian on 10/21/13.
//  Copyright (c) 2013 Sohu Inc. All rights reserved.
//

#import "SHMovieLogging.h"

@implementation SHMovieAccessLog
@synthesize accessLog = _accessLog;

- (NSString *)accessLog {
    return [[NSString alloc] initWithData:self.extendedLogData encoding:self.extendedLogDataStringEncoding];
}

@end



@implementation SHMovieErrorLog
@synthesize errorLog = errorLog;

- (NSString *)errorLog {
    return [[NSString alloc] initWithData:self.extendedLogData encoding:self.extendedLogDataStringEncoding];
}

@end
