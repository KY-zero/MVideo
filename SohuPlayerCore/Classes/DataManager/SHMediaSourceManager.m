//
//  MediaSourceManager.m
//  SohuPlayerCore
//
//  Created by wangzy on 13-10-15.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//

#import "SHMediaSourceManager.h"
#import "SHPropertyDefinitions.h"
#import "SHMedia.h"

@interface SHMediaSourceManager () {
}
@end

@implementation SHMediaSourceManager

+ (SHMediaSourceManager *)shareMediaSourceManager {
    static SHMediaSourceManager *mediaSourceManagerInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediaSourceManagerInstance = [[self alloc] init];
    });
    return mediaSourceManagerInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.mediaArray = [NSMutableArray array];
    }
    return self;
}

- (void)resetData {
    _currentPlayindex = 0;
    [self.mediaArray removeAllObjects];
}

- (int)getPlayMediaCount {
    return self.mediaArray.count;
}

- (void)appendMedia:(SHMedia *)aMedia {
    if (nil == aMedia) {
        return;
    }
    [self.mediaArray addObject:aMedia];
}

- (void)appendMediasArray:(NSArray *)aMediaArray {
    if (nil == aMediaArray || aMediaArray.count == 0) {
        return;
    }
    [self.mediaArray addObjectsFromArray:aMediaArray];
}

- (void)setKeywordString:(NSString *)aKeyword {
    self.keyword = aKeyword;
}

- (SHMedia *)currentPlayMedia {
    if (nil != self.mediaArray && self.mediaArray.count > _currentPlayindex) {
        return [self.mediaArray objectAtIndex:_currentPlayindex];
    }
    return nil;
}

- (SHMedia *)prePlayMedia {
    if ([self hasPrePlayMedia]) {
        _currentPlayindex--;
        return [self currentPlayMedia];
    }
    return nil;
}

- (SHMedia *)nextPlayMedia {
    if ([self hasNextPlayMedia]) {
        _currentPlayindex++;
        return [self currentPlayMedia];
    }    return nil;
}

- (SHMedia *)playIndex:(NSInteger)index {
    if (index >= 0 && index < self.mediaArray.count) {
        _currentPlayindex = index;
        return [self currentPlayMedia];
    }
    return nil;
}

- (BOOL)hasPrePlayMedia {
    return _currentPlayindex > 0;
}

- (BOOL)hasNextPlayMedia {
    return _currentPlayindex < (self.mediaArray.count - 1);
}
@end
