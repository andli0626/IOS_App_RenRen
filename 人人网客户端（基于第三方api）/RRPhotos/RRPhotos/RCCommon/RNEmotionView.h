//
//  RNEmotionView.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-28.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNView.h"
@class RNEmotionContentView;
@interface RNEmotionView : RNView{
    // 父窗口Controller
    UIView *_parentController;
    // 默认表情的ContentView
    RNEmotionContentView *_defaultEmotionsView;
    // 阿狸表情的ContentView
    RNEmotionContentView *_aliEmotionsView;
    //囧囧熊表情的ContentView
    RNEmotionContentView *_jjEmotionsView;
    //默认表情按钮
    UIButton *_defaultEmotionsButton;
    //炫酷表情按钮
    UIButton *_aliEmotionsButton;
    //囧囧熊表情按钮
    UIButton *_jjEmotionsButton;
}
@property (nonatomic, assign) UIView *parentController;
@property (nonatomic, retain) RNEmotionContentView *defaultEmotionsView;
@property (nonatomic, retain) RNEmotionContentView *aliEmotionsView;
@property (nonatomic, retain) RNEmotionContentView *jjEmotionsView;

@property (nonatomic, retain) UIButton *defaultEmotionsButton;
@property (nonatomic, retain) UIButton *aliEmotionsButton;
@property (nonatomic, retain) UIButton *jjEmotionsButton;

+ (RNEmotionView *)getInstance;
//简历表情视图
- (void)buildEmotionView; 
//将选中的表情以text形式加到输入框
- (void)addEmotionInText:(NSString*)emojeText;

@end
