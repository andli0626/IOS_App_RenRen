//
//  RNEmotionLayoutData.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-28.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNEmotionLayoutData : NSObject{
    NSInteger _emotionCount;
    NSInteger _oneRowCount;//一行表情的个数
    NSInteger _buttonOriginalX;//记录最左侧按钮X坐标
    NSInteger _emotionOriginalX;//记录最左侧表情图片X坐标
    NSInteger _buttonOriginalY;//表情按钮的起始点Y坐标
    NSInteger _emotionOriginalY;//表情图片的起始点Y坐标
    NSInteger _buttonXvalueIncrement;//两个相邻表情按钮的起始点X坐标差值
    NSInteger _buttonYvalueIncrement;//两个相邻表情按钮的起始点Y坐标差值
    NSInteger _emotionXvalueIncrement;//两个相邻表情图片的起始点X坐标差值
    NSInteger _emotionYvalueIncrement;//两个相邻表情图片的起始点Y坐标差值
    CGSize _emotionSize;//表情图片大小
    CGSize _buttonSize;//表情按钮大小
}

@property (nonatomic) NSInteger emotionCount;
@property (nonatomic) NSInteger oneRowCount;//一行表情的个数
@property (nonatomic) NSInteger buttonOriginalX;//记录最左侧按钮X坐标
@property (nonatomic) NSInteger emotionOriginalX;//记录最左侧表情图片X坐标
@property (nonatomic) NSInteger buttonOriginalY;//表情按钮的起始点Y坐标
@property (nonatomic) NSInteger emotionOriginalY;//表情图片的起始点Y坐标
@property (nonatomic) NSInteger buttonXvalueIncrement;//两个相邻表情按钮的起始点X坐标差值
@property (nonatomic) NSInteger buttonYvalueIncrement;//两个相邻表情按钮的起始点Y坐标差值
@property (nonatomic) NSInteger emotionXvalueIncrement;//两个相邻表情图片的起始点X坐标差值
@property (nonatomic) NSInteger emotionYvalueIncrement;//两个相邻表情图片的起始点Y坐标差值
@property (nonatomic) CGSize emotionSize;//表情图片大小
@property (nonatomic) CGSize buttonSize;//表情按钮大小

@end
