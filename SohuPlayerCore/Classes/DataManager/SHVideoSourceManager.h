//
//  SHVideoSourceManager.h
//  SohuPlayerCore
//
//  Created by wangzy on 2/28/14.
//  Copyright (c) 2014 Sohu Inc. All rights reserved.
//

#import "SHMediaSourceManager.h"

#define kVideoItemKey @"VideoItemKey"

extern NSString * const LoadVideoItemDetailSuccessNotification;
extern NSString * const LoadVideoItemDetailFailedNotification;

typedef enum {
    RequestLoading,
    RequestLoaded,
} eVideoRequestItemLoadState;

@interface SHVideoSourceManager : SHMediaSourceManager

- (void)loadVideoItemWidthMedia:(SHMedia *)media;

- (void)cancelRequest;
@end
