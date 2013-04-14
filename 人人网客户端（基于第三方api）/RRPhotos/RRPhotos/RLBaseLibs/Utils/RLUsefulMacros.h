//
//  RLUsefulMacros.h
//  RRSpring
//
//  Created by renren-inc on 12-2-21.
//  Copyright (c) 2012年 Renn. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RL_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define RL_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

/*
 * 通过RGB创建UIColor
 */
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

/////////////////////////////////////////////////////////////////////////////////////////
// 一些常用相关尺寸

/*
 * iPhone 屏幕尺寸
 */
#define PHONE_SCREEN_SIZE (CGSizeMake(320, 460))

/*
 * iPhone statusbar 高度
 */
#define PHONE_STATUSBAR_HEIGHT 20

/*
 * iPhone 默认导航条高度
 */
#define PHONE_NAVIGATIONBAR_HEIGHT 44
