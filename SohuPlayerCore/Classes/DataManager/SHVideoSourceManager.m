//
//  SHVideoSourceManager.m
//  SohuPlayerCore
//
//  Created by wangzy on 2/28/14.
//  Copyright (c) 2014 Sohu Inc. All rights reserved.
//

#import "SHVideoSourceManager.h"
//#import "VideoItem.h"
#import "SHMedia.h"

#define InvalidID -999

NSString * const LoadVideoItemDetailSuccessNotification = @"LoadVideoItemDetailSuccessNotification";
NSString * const LoadVideoItemDetailFailedNotification  = @"LoadVideoItemDetailFailedNotification";

@interface SHVideoSourceManager ()

//@property (nonatomic, strong) RequestItem *videoRequestItem;
@property (nonatomic, assign) NSUInteger currentRequestId;
@end

@implementation SHVideoSourceManager

- (void)resetData {
    [super resetData];
    [self cancelRequest];
}

- (void)loadVideoItemWidthMedia:(SHMedia *)media {
    if (!media) {
        return;
    }
    
    // 取消上次请求
    [self cancelRequest];
    
    switch (media.sourceType) {
        case SHSohuMedia:
            [self loadVideoDetailInfo:media];
            break;
        case SHLiveMedia:
            [self loadLiveVideoDetailInfo:media];
            break;
        default:
            break;
    }
}

#pragma mark - 点播类视频详情

- (void)loadVideoDetailInfo:(SHMedia*)aMedia {
//    VideoRequestItem *requestItem = [[VideoRequestItem alloc] init];
//    [requestItem setDelegateTarget:self
//                               succeedMethod:@selector(loadVideoItemSuccessWithResponseItem:)
//                                failedMethod:@selector(loadVideoItemFailedWithResponseItem:)];
//    requestItem.videoID = aMedia.vid;
//    requestItem.site = [NSString stringWithFormat:@"%d", aMedia.site];
//    requestItem.subjectID = aMedia.aid;
//    self.videoRequestItem = requestItem;
//    self.currentRequestId = [[DataCenter sharedCenter] requestCategoryVideoItemByVidWithRequestItem:(VideoRequestItem*)self.videoRequestItem];
//    MDebugLog(@"vid : %@ , site : %d , 开始加载点播视频详情 ::: %d", aMedia.vid, aMedia.site, self.currentRequestId);
}

#pragma mark - 直播类视频详情（SOHU内部直播）

- (void)loadLiveVideoDetailInfo:(SHMedia*)aMedia {
//    LiveRequestItem *requestItem = [[LiveRequestItem alloc] init];
//    [requestItem setDelegateTarget:self
//                               succeedMethod:@selector(loadVideoItemSuccessWithResponseItem:)
//                                failedMethod:@selector(loadVideoItemFailedWithResponseItem:)];
//    requestItem.tvId = [aMedia.lid longLongValue];
//    self.videoRequestItem = requestItem;
//    self.currentRequestId = [[DataCenter sharedCenter] requestLiveTVInfoWithRequestItem:(LiveRequestItem*)self.videoRequestItem];
//    MDebugLog(@"vid : %@ , 开始加载直播视频详情 ::: %d", aMedia.vid, self.currentRequestId);
}

#pragma mark - 

//- (void)loadVideoItemSuccessWithResponseItem:(ResponseItem *)responseItem {
//    if (self.videoRequestItem == nil) {
//        return;
//    }
//    self.videoRequestItem = nil;
//    
//    if (!responseItem.responseData || !responseItem.requestItem) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:LoadVideoItemDetailFailedNotification object:self];
//        return;
//    }
//    
//    VideoItem *videoItem = [[VideoItem alloc] init];
//    if ([responseItem.requestItem isKindOfClass:[LiveRequestItem class]]) {
//        if ([responseItem.responseData isKindOfClass:[LiveVideoItem class]]) {
//            LiveVideoItem* liveVideoItem = (LiveVideoItem*)responseItem.responseData;
//            videoItem.videoTitle = liveVideoItem.name;
//            videoItem.highM3u8UrlString = liveVideoItem.liveHighUrl;
//            videoItem.vid = liveVideoItem.tvId;
//            MDebugLog(@"加载直播视频成功 ::: %d", self.currentRequestId);
//        } else {
//            [[NSNotificationCenter defaultCenter] postNotificationName:LoadVideoItemDetailFailedNotification object:self];
//        }
//    } else {
//        NSDictionary *jsonDictionary = [responseItem responseDictionary];
//        if (!jsonDictionary) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:LoadVideoItemDetailFailedNotification object:self];
//        } else {
//            MDebugLog(@"加载视频成功 ::: %d", self.currentRequestId);
//            [videoItem updateWithJSONDictionary:jsonDictionary];
//        }
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:LoadVideoItemDetailSuccessNotification
//                                                        object:self
//                                                      userInfo:[NSDictionary dictionaryWithObject:videoItem forKey:kVideoItemKey]];
//}
//
//- (void)loadVideoItemFailedWithResponseItem:(ResponseItem *)responseItem {
//    MDebugLog(@"加载视频详情失败 ::: %d", self.currentRequestId);
//    self.videoRequestItem = nil;
//    [[NSNotificationCenter defaultCenter] postNotificationName:LoadVideoItemDetailFailedNotification object:self];
//}
//
//- (void)cancelRequest {
//    if (self.videoRequestItem) {
//        [[DataCenter sharedCenter] cancelDataRequestWithRequestID:self.currentRequestId];
//        [self.videoRequestItem setDelegateTarget:nil succeedMethod:nil failedMethod:nil];
//        self.videoRequestItem = nil;
//        MDebugLog(@"取消当次请求 ::: %d", self.currentRequestId);
//    }
//}
@end
