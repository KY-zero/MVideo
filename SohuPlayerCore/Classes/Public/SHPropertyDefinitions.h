//
//  SHPropertyDefinitions.h
//  SohuPlayerCore
//
//  Created by wangzy on 13-10-12.
//  Copyright (c) 2013年 Sohu Inc. All rights reserved.
//

#define k_channel_id    @"999"

// media property
#define k_sourceType        @"sourceType"           // 数据来源
#define k_identifier        @"identifier"           // 第三方定义的唯一标识
#define k_sid               @"aid"                  // 搜狐来源的SID
#define k_cid               @"cid"                  // 搜狐来源的CID
#define k_vid               @"vid"                  // 搜狐来源的vid/第三方视频的vid
#define k_url               @"url"                  // 任意来源的uri
#define k_title             @"title"                // 播放标题
#define k_summary           @"summary"              // 视频简介
#define k_initPlaybackTime  @"initialPlaybackTime"  // 起始播放时间
#define k_tvId              @"tvId"                 // 电视台的Id
#define k_advUrl            @"advUrl"               // 第三方广告Url


// media advertising property
#define k_pt            @"pt"       // 广告形式     (N) - oad - 前贴;pad - 暂停; banner - 通栏;open - 开机启动图; focus - 焦点图;
#define k_plat          @"plat"     // 移动端平台ID  (N) - 6 - android phone; 16 - android pad;
#define k_clentVersion  @"sver"     // 客户端版本    (N)
#define k_partner       @"partner"  // 渠道         (Y)
#define k_systemVersion @"sysver"   // 系统版本     (Y)
#define k_productId     @"poid"     // 产品 id      (Y) - 目前只有搜狐视 频客户端
#define k_channel       @"c"        // 频道         (N)
#define k_vc            @"vc"       // Vrs 分类     (N)
#define k_deviceName    @"pn"       // 设备名称      (N)
#define k_albumId       @"al"       // 专辑 id      (N)
#define k_vDuration     @"du"       // 视频时长      (N)
#define k_age           @"ag"       // 年龄         (Y)
#define k_star          @"st"       // 明星         (Y)
#define k_address       @"ar"       // 产地         (Y)
#define k_vid           @"vid"      // 视频 ID      (N)
#define k_uUniqe        @"tuv"      // 用户唯一标识  (N)
#define k_uVIP          @"vu"       // vip 用户的用户名 (Y) - 非空代表 vip 用户
#define k_source        @"source"   // 入口来源     (N)
#define k_netType       @"wt"       // 网络状态     (N) - wifi;3G;2G;unkown;
