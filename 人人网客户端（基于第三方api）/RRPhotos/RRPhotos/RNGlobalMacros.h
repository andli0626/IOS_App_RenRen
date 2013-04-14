//
//  RNGlobalMacros.h
//  RRPhotos
//
//  Created by yi chen on 12-3-26.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#ifndef RRSpring_RNGlobalMacros_h
#define RRSpring_RNGlobalMacros_h

/*
 * 内容区导航条高度
 */
#define CONTENT_NAVIGATIONBAR_HEIGHT 44

/*
 * 导航条动画时间
 */
#define NAVIGATIONBAT_ANIMATION_TIMEINTERVAL 0.5

/*
 * 导航扩展页动画时间
 */
#define NAVIGATION_EXTEND_ANIMATION_TIMEINTEVAL 0.5

/*
 * 华文黑体-light
 */
#define LIGHT_HEITI_FONT @"STHeitiSC-Light"

/*
 * 华文黑体-medium
 */
#define MED_HEITI_FONT @"STHeitiSC-Medium"

/*
 * publish中输入导航条的高度
 */
#define PUBLISH_BOTTOM_HEIGHT 36
/*
 * publish中输入导航条的上方的信息条的高度
 */
#define PUBLISH_BOTTOM_INFO_HRIGHT 27
/*
 * 英文状态下键盘的高度
 */
#define PUBLISH_ENGISH_KEYBOARD_TOP 216.0
/*
 * 照片新鲜事的列表背景色
 */
#define kNewsFeedTableViewBgColor RGBCOLOR(240, 240, 240)
/*
 * 照片新鲜事的列表Section背景色
 */
#define kNewsFeedSectionBgColor  RGBCOLOR(235, 235, 235)

/*
 *	照片新鲜事的列表Section高度
 */
#define kNewsFeedSectionViewHeight  44

#define RN_DEBUG_LOG NSLog(@"-------%s---%d",__FUNCTION__,__LINE__)

#endif
