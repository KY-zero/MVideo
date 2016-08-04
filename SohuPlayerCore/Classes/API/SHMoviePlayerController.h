//
//  SHMoviePlayerController.h
//  SohuVideoSDK
//
//  Created by wangzy on 13-9-16.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//

#ifdef __cplusplus
#define SH_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define SH_EXTERN     extern __attribute__((visibility ("default")))
#endif

enum {
    SHMoviePlayStateStopped         = 0,
    SHMoviePlayStatePlaying         = 1,
    SHMoviePlayStatePaused          = 2,
    SHMoviePlayStateInterrupted     = 3,
    SHMoviePlayStateSeekingForward  = 4,
    SHMoviePlayStateSeekingBackward = 5,
};
typedef NSInteger SHMoviePlayState;

enum {
    SHMovieLoadStateUnknown         = 0,
    SHMovieLoadStatePlayable        = 1 << 0,
    SHMovieLoadStatePlaythroughOK   = 1 << 1,
    SHMovieLoadStateStalled         = 1 << 2
};
typedef NSInteger SHMovieLoadState;

enum {
    SHMovieScaleModeNone,
    SHMovieScaleModeAspectFit,
    SHMovieScaleModeAspectFill,
    SHMovieScaleModeFill,
};
typedef NSInteger SHMovieScaleMode;

enum {
    SHMoviePlayErrorUnknow,              // 未知错误
    SHMoviePlayErrorSystem,              // 播放器内部错误
    SHMoviePlayErrorUrlNull,             // 播放url为空
    SHMoviePlayErrorSHVideoVidIsNull,    // 播放搜狐视频资源，视频vid为空
    SHMoviePlayErrorSHVideoLoadFailed,   // 播放搜狐视频资源，获取搜狐视频详情失败
    SHMoviePlayErrorNoAuthority          // 没有权限
};
typedef NSInteger SHMoviePlayErrorType;

enum {
    SHAdvertPlayStateUnknown,
    SHAdvertPlayStateStoped,
    SHAdvertPlayStatePlaying,
    SHAdvertPlayStatePause
};
typedef NSInteger SHAdvertPlayState;

enum {
    SHMovieQualityUlitra   = 0, // 超清
    SHMovieQualityHigh     = 1, // 高清
    SHMovieQualityNormal   = 2, // 流畅
};
typedef NSUInteger SHMovieQualityType;

@class SHMedia;

@protocol SHMoviePlayerControllerDelegate;

@interface SHMoviePlayerController : NSObject

#pragma Property ###############################################################

/**
 *  是否静音
 *  YES 静音 ， NO 不静音
 */
@property (nonatomic, assign) BOOL muted;

/**
 *  代理回调对象
 */
@property (nonatomic, assign) id<SHMoviePlayerControllerDelegate> delegate;

/**
 *  广告服务器开关
 *  YES - 使用测试服务器，NO - 使用正式广告服务器
 */
@property (nonatomic, assign) BOOL advertHostTestSwitch;

/**
 *  播放器View
 */
@property (nonatomic, readonly) UIView *view;

/**
 *  当前播放视频URL
 */
@property (nonatomic, readonly) NSURL *contentURL;

/**
 *  当前播放Media
 */
@property (nonatomic, readonly) SHMedia *currentPlayMedia;

/**
 *  ShouldAutoplay, 与系统播放器相同，默认为YES
 */
@property (nonatomic, assign) BOOL shouldAutoplay;

/**
 *  是否在广告播放过程中预先加载视频正片，因为与广告同时加载，可能会影响广告播放
 */
@property (nonatomic, assign) BOOL isPreloadMovieWhenPlayAdvert;

/**
 *  ScaleMode,与系统播放器相同
 */
@property (nonatomic, assign) SHMovieScaleMode movieScaleMode;

/**
 *  播放器当前播放状态,与系统播放器相同
 */
@property (nonatomic, readonly, assign) SHMoviePlayState playbackState;

/**
 *  加载状态
 */
@property (nonatomic, readonly, assign) SHMovieLoadState loadState;

/**
 *  视频分辨率
 */
@property (nonatomic, assign) SHMovieQualityType movieQualityType;

/**
 *  视频播放时长
 */
@property (nonatomic, readonly, assign) NSTimeInterval duration;

/**
 *  视频当前播放时长
 */
@property (nonatomic, readonly, assign) NSTimeInterval currentPlaybackTime;

/**
 *  播放速率
 */
@property (nonatomic, readonly, assign) float currentPlaybackRate;

/**
 *  播放器缓存视频时长
 */
@property (nonatomic, readonly, assign) NSTimeInterval playableDuration;

/**
 *  广告总时长
 */
@property (nonatomic, readonly, assign) NSTimeInterval advertDuration;

/**
 *  广告当前播放剩余时长
 */
@property (nonatomic, readonly, assign) NSTimeInterval advertCurrentPlaybackTime;

/**
 *  广告当前播放时长
 */
@property (nonatomic, readonly, assign) NSTimeInterval advertCurrentPlaybackTimeByRightOrder;

/**
 *  是否打开广告的开关:
 *  YES:播放视频带有的广告, NO:跳过所有广告(改开关只负责控制搜狐视频源非长视频源)
 */
@property (nonatomic, assign) BOOL isLoadAdvert;

/**
 *  当前是否在播放模式下, 广告模式下
 */
@property (nonatomic, readonly, assign) BOOL isInAdvertMode;

/**
 *  全屏播放控制
 */
@property (nonatomic, getter=isFullscreen) BOOL fullscreen;

/**
 *  是否允许airplay播放,与系统播放器相同
 */
@property (nonatomic, assign) BOOL allowsAirPlay;

/**
 *  当前是否使用airplay播放,与系统播放器相同
 */
@property (nonatomic, readonly, getter=isAirPlayVideoActive) BOOL airPlayVideoActive;

/**
 *  是否按照播放列表，顺序播放
 *  当播放列表大于0有效
 */
@property (nonatomic, assign) BOOL isAutoPlayNextVideo;


#pragma Api Function ###############################################################

/**
 *  注册Appkey，在程序启动时调用
 *
 *  @param appKey
 */
+ (void)registerAppKey:(NSString *)appKey;

/**
 *  以下播放播放器基本控制函数
 */
- (void)play;
- (void)stop;
- (void)pause;
- (void)seekForward:(NSTimeInterval)second;
- (void)seekBackward:(NSTimeInterval)second;
- (void)seekTo:(NSTimeInterval)posTime;
- (void)setFullscreen:(BOOL)aFullscreen animated:(BOOL)animated;

/**
 *  播放单个视频
 *
 *  @param media 视频对象
 */
- (void)playWithMedia:(SHMedia *)media;

/**
 *  播放一组视频，并指定起始播放位置
 *
 *  @param mediaArray 视频数组（SHMedia）
 *  @param index      其实播放位置
 */
- (void)playWithMediaArray:(NSArray *)mediaArray index:(int)index;

/**
 *  追加一个视频到当前播放列表
 *
 *  @param media 视频对象
 */
- (void)appendMedia:(SHMedia *)media;

/**
 *  追加一组视频到当前播放列表
 *
 *  @param mediaArray 视频数组（SHMedia）
 */
- (void)appendMediaArray:(NSArray *)mediaArray;

/**
 *  播放上一个视频
 *
 *  @return YES:视频存在，开始播放；NO:视频不存在
 */
- (BOOL)playPreviousMedia;

/**
 *  播放下一个视频
 *
 *  @return YES:视频存在，开始播放；NO:视频不存在
 */
- (BOOL)playNextMedia;

/**
 *  播放列表指定位置视频
 *
 *  @param index 列表指定位置
 *
 *  @return YES:视频存在，开始播放；NO:视频不存在
 */
- (BOOL)playMediaWithIndex:(NSInteger)index;

/**
 *  退出播放器，结束播放，需要调用该方法
 */
- (void)playerExit;

#pragma 广告相关
/**
 *  点击前贴片广告，获取广告信息供app使用
 *  该函数会上报广告点击统计
 *  @return 广告信息
 */
- (NSString *)getCurrentOADAdvertInfo;

@end


#pragma Delegate ###############################################################

@protocol SHMoviePlayerControllerDelegate <NSObject>

@optional

/**
 *  视频加载第一针请求时长
 */
- (void)playerLoadDuration:(NSTimeInterval)loadDuration success:(BOOL)success;

/**
 *  等同系统播放器MPMovieDurationAvailableNotification通知，
 *  获取视频时长
 */
- (void)playbackDurationAvailable;

/**
 *  正常缓存，该函数对应的缓冲包括：首次加载缓冲、前后拖动进度引起的缓存
 *
 */
- (void)playbackPreparing;

/**
 *  卡顿，播放过程中因网络或播放源引起的卡顿，不包括首次加载缓冲、前后拖动进度引起的缓冲
 */
- (void)playbackStalling;

/**
 *  缓冲结束（正常缓冲和卡顿缓冲），准备开始播放
 */
- (void)playbackPrepared;

/**
 *  播放开始
 */
- (void)playbackStart;

/**
 *  播放暂停
 */
- (void)playbackPause;

/**
 *  播放停止
 */
- (void)playbackStop;

/**
 *  播放中断
 */
- (void)playbackInterrupted;

/**
 *  前/后拖动进度条
 */
- (void)playbackSeekingForward;
- (void)playbackSeekingBackward;

/**
 *  播放失败
 *
 *  @param error 错误信息
 */
- (void)playerPlayError:(SHMoviePlayErrorType)errorType;

/**
 *  播放器对播放用户定制的视频相关回调函数
 *  若果只有一个定制播放视频将不会调用这个函数，直接回调playerPlaybackComplete函数
 */
- (void)playerPlaybackFinish:(int)playIndex;

/**
 *  所有定制视频播放完成回调函数
 */
- (void)playerPlaybackComplete;

/**
 *  点击系统播放器完成按钮触发
 */
- (void)playerPlaybackFinishByUserExited;


#pragma 广告相关
/**
 *  将要进入广告播放器，开始请求广告地址
 */
- (void)playerEnterAdvertMode;

/**
 *  广告地址请求完成，开始加载广告
 */
- (void)advertPlayerPreparing;

/**
 *  广告加载完成，开始播放
 */
- (void)advertPlayerPrepared;

/**
 *  广告播放完成，退出广告播放器
 */
- (void)playerExitAdvertMode;

/**
 *  广告播放发生错误
 */
- (void)playerPlayAdvertError;

/**
 *  当前播放广告详细信息回调
 */
- (void)playerPlayAdvertWithInfo:(id)advertInfo;
@end

