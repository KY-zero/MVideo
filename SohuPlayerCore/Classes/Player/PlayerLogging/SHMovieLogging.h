//
//  SHMovieLogging.h
//  SohuPlayerCore
//
//  Created by Cui Chunjian on 10/21/13.
//  Copyright (c) 2013 Sohu Inc. All rights reserved.
//

#import "SHPlayerDefinitions.h"


@interface SHMovieAccessLog : MPMovieAccessLog {
    NSString *_accessLog;
}
@property (nonatomic, readonly) NSString *accessLog;
@end


@interface SHMovieErrorLog : MPMovieErrorLog {
    NSString *_errorLog;
}
@property (nonatomic, readonly) NSString *errorLog;
@end
