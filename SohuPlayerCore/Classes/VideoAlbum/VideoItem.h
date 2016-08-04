//
//  VideoItem.h
//  SohuPlayerCore
//
//  Created by LHL on 16/8/4.
//  Copyright © 2016年 Sohu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+Shortcuts.h"

typedef enum _VideoQuality
{
    kVideoQualityNone  = (0),        //无效
    kVideoQualityUltra = (1 << 0),   //超清
    kVideoQualityHigh  = (1 << 1),   //高清
    kVideoQualityLow   = (1 << 2),   //低清
    kVideoQuality720P  = (1 << 3)    //720P
} VideoQuality;

typedef enum
{
    kDMWtypeOnline = 1,         // 在线播放
    kDMWtypeCache,              // 离线播放
    kDMWtypeLocal,              // 本地视频
    kDMWtypeUnknown = 0xFFFFFFFF
} DMWtype; // wtype


typedef enum
{
    kDMLtypeSignalVideo = 0,        // 点播
    kDMLtypeLiveVideo,              // 电视台直播
    kDMLtypeSingalLiveVideo,        // 单场直播
    kDMLtypeUnknown = 0xFFFFFFFF
} DMLtype; // ltype

typedef enum
{
    kDMTypeSohu = 0,        // 搜狐视频
    kDMTypeLocal,           // 本地资源
    kDMTypeThird,           // 第三方视频
    kDMTypeUnknown = 0xFFFFFFFF
} DMType; // ltype


typedef enum _SHPlayerPlaybackStopReason {
    SHPlayerPlaybackStopReasonUnknow,
    SHPlayerPlaybackStopReasonEnd,        // 播放正常结束
    SHPlayerPlaybackStopReasonExit,       // 切换视频、退出播放器
    SHPlayerPlaybackStopReasonFail,       // 播放错误
    SHPlayerPlaybackStopReasonTerminal    // 客户端终止
} SHPlayerPlaybackStopReason; // 用于DM统计


typedef enum
{
    kVideoType_SearchAll = -2,   // 搜索返回的全部
    kVideoType_HomePageLive = -1, // 首页焦点图跳转直播返回的类型
    kVideoAll = 0, // 所有类型
    kVideoType_Movie = 1, // 电影
    kVideoType_TV = 2, // 电视剧
    kVideoType_Talk = 3, //访谈
    kVideoType_Show = 4, //节目
    KVideoType_Match = 5, //赛事
    kVideoType_Original = 6, //原创
    kVideoType_VarietyChina = 7, //综艺 7
    kVideoType_Newsreel = 8, //纪录片 8
    kVideoType_NewsCenter = 9, //新闻中心 9
    kVideoType_Fashion = 10, //时尚
    kVideoType_Finance = 11, //财经
    kVideoType_Car = 12, // 汽车
    kVideoType_EntertainNews = 13, //视频新闻
    kVideoType_Clip = 14, //片花
    kVideoType_MTV = 15, //MTV
    kVideoType_Commic = 16,	  // 动漫
    kVideoType_Bomb = 17, // 视频雷区
    kVideoType_Guangdong = 18, // 广东站
    kVideoType_Travel = 19, // 旅游频道
    kVideoType_Education = 21, // 教育片
    kVideoType_Other = 22, // 其它
    kVideoType_Music = 24, // 音乐
    kVideoType_News = 25, // 新闻
    kVideoType_StarFashion = 33, //星尚
    
    kVideoType_DaPeng = 100, // 大鹏
    kVideoType_Star, // 明星在线
    kVideoType_Tide, // 潮流实验室
    kVideoType_NewsTV = 1300,   //视频新闻  added by Tiger 12.6.13
    kVideoType_Blog = 9001,	// 播客 added by ybc 11-10-17
    kVideoType_Live = 9002, // 直播频道
} kVideoType_DataCenter;



@interface VideoItem : NSObject

@property(nonatomic, retain) NSString *videoTitle;              // 视频标题
@property(nonatomic, retain) NSString *videoFirstName;          // 正标题
@property(nonatomic, retain) NSString *videoShortName;          // 副标题
@property(nonatomic, retain) NSString *videoDescription;        // -- 原 videoDes
@property(nonatomic, retain) NSString *showTime;                // 什么东西？

@property(nonatomic, assign) NSInteger playOrder;               // 播放顺序
@property(nonatomic, assign) NSInteger videoHeaderTime;         // 视频片头时间点
@property(nonatomic, assign) NSInteger videoTailTime;           // 视频片尾时间点
@property(nonatomic, retain) NSArray *viewPointList;            // 看点信息

@property(nonatomic, retain) NSString *originalM3u8UrlString;   // 原画 M3U8 播放地址
@property(nonatomic, retain) NSString *superM3u8UrlString;      // 超清 M3U8 播放地址
@property(nonatomic, retain) NSString *highM3u8UrlString;       // 高清 M3U8 播放地址
@property(nonatomic, retain) NSString *mediumM3u8UrlString;     // 标清 M3U8 播放地址
@property(nonatomic, retain) NSString *lowMp4UrlString;         // 流畅整段 MP4 下载地址
@property(nonatomic, retain) NSString *webPlayUriString;        // 网页播放地址

//
@property(nonatomic, retain) NSArray *musicAlbumPics;           // 视频相册


@property(nonatomic, assign) kVideoType_DataCenter cid; // 分类 ID -- 原 videoType、videoTypeID
@property(nonatomic, retain) NSString *cateCode;        // 视频分类 ID，可能分号分隔一、二、三级别

@property(nonatomic, assign) long long aid; // 专辑 ID -- 原 categoryID
@property(nonatomic, assign) long long vid; // 剧集 ID -- 原 videoID
@property(nonatomic, assign) NSInteger site;
@property(nonatomic, assign) NSInteger pid; // 用于网页播放 -- 原 pID

@property(nonatomic, assign) NSInteger   streamType;         // 最高清晰度
@property(nonatomic, assign) NSInteger  videoSubType;       // 二级分类 （片花、正片、幕后专辑。。）
@property(nonatomic, assign) NSInteger      releaseYear;        // 上映年份
@property(nonatomic, assign) NSInteger      playCount;         // 播放次数
@property(nonatomic, retain) NSString       *applicationTime;   // 发布时间
@property(nonatomic, retain) NSString       *updateTime;        // 更新时间

@property(nonatomic, retain) NSString *source;      // 来源
@property(nonatomic, retain) NSString *timeLength;  // 视频时长
@property(nonatomic, retain) NSString *tip;         // 视频信息（时长、集数、简介、最新一集等）
@property(nonatomic, retain) NSString *subtitle;    // 一句话推荐 -- 原 sub_title
@property(nonatomic, retain) NSString *tvSubName;   // 频道页子标题
@property(nonatomic, retain) NSString *tvIssue;     // 最新一期的期号

@property(nonatomic, retain) NSString *guest;                   // 综艺 ONLY，嘉宾

@property(nonatomic, retain) NSString *bigVerImageUrl;      // 大竖图 - 删除未解析的 smallVerImageUrl
@property(nonatomic, retain) NSString *bigHorImageUrl;      // 大横图 - 删除未解析的 smallHorImageUrl
@property(nonatomic, retain) NSString *bigVideoImageUrl;    // 单视频大横图 - 删除未解析的 smallVideoImageUrl
@property(nonatomic, retain) NSString *videoSourceImageUrl; // 网站原图

@property(nonatomic, assign) BOOL isVidValid;       // 为1时有效，0时无效，即vid为负不能播放
@property(nonatomic, assign) BOOL isIPLimit;        // 为1时为ip限制，为0时不受限 -- 原 isIpLimit
@property(nonatomic, assign) BOOL mobileLimit;      // 为1时客户端版权受限，为0不受限
@property(nonatomic, assign) BOOL isDownloadable;   // 是否可以下载 - 只是服务端返回字段 isDownload，不再判断 fee，参考 canBeDownLoaded 方法
@property(nonatomic, assign) BOOL fee;              // 是否付费
@property(nonatomic, assign) BOOL feeMonth;         // 是否是包月
@property(nonatomic, assign) NSInteger feeRuleID;   // 付费规则 ID

@property(nonatomic, retain) NSString *areaID;      // -- 原 areaId
@property(nonatomic, retain) NSString *languageID;  // -- 原 languageId
@property(nonatomic, retain) NSString *companyID;   // -- 原 companyIdentifier

@property(nonatomic, retain) NSString *area;        // 地区
@property(nonatomic, retain) NSString *subType;     // 子分类 动作片等
@property(nonatomic, retain) NSString *keyword;     // 关键词 奶妈；网站；露骨照片
@property(nonatomic, retain) NSString *tvAlias;     // 标签 2013穿名堂；穿名堂；街拍

@property(nonatomic, assign) long long programID;  // 节目ID
@property(nonatomic, retain) NSString *programTitle; // 节目标题


@end
