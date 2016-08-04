//
//  MediaSourceManager.h
//  SohuPlayerCore
//
//  Created by wangzy on 13-10-15.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHMedia;

@interface SHMediaSourceManager : NSObject

@property (nonatomic, strong) NSMutableArray *mediaArray;
@property (nonatomic, strong) NSString *keyword;

@property (nonatomic, readonly, assign) NSInteger currentPlayindex;
@property (nonatomic, readonly, assign, getter = getPlayMediaCount) int playMediaCount;

+ (SHMediaSourceManager *)shareMediaSourceManager;

- (void)appendMedia:(SHMedia *)media;
- (void)appendMediasArray:(NSArray *)mediaArray;

- (void)setKeywordString:(NSString *)aKeyword;

- (SHMedia *)currentPlayMedia;
- (SHMedia *)prePlayMedia;
- (SHMedia *)nextPlayMedia;
- (SHMedia *)playIndex:(NSInteger)index;

- (BOOL)hasPrePlayMedia;
- (BOOL)hasNextPlayMedia;

- (void)resetData;
@end
