//
//  RNView.h
//  RRSpring
//
//  Created by 洪杰 任 on 12-4-16.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 所有View的基类，遵循换肤协议，所有集成它的View都能集成换皮肤的接口
 */
@interface RNView : UIView <RCResChangeSkinProtocol>

@end
