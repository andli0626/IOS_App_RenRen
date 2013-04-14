//
//  RNPopupView.h
//  RRSpring
//
//  Created by gaosi on 12-3-31.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNView.h"
typedef enum {
	RNPointDirectionUp = 0,
	RNPointDirectionDown
} RNPointDirection;

typedef enum {
    RNPopupAnimationSlide = 0,
    RNPopupAnimationPop
} RNPopupAnimation;

@protocol RNPopupViewDelegate;

@interface RNPopupView : RNView{
	id<RNPopupViewDelegate>	_delegate;
	id						_targetObject;
    RNPopupAnimation       _animation;
    UIImageView*    _backgroundView;
    
@private
	RNPointDirection		_pointDirection;
	CGFloat					_pointerSize;
	CGPoint					_targetPoint;
}

@property (nonatomic, assign)	id<RNPopupViewDelegate> delegate;
@property (nonatomic, retain, readonly)	id	targetObject;
@property (nonatomic, assign)   RNPopupAnimation animation;
@property (nonatomic, retain)   UIImageView* backgroundView;

- (void)presentPointingAtView:(UIView *)targetView inView:(UIView *)containerView animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;
- (id)initWithFrame:(CGRect)frame;

@end


@protocol RNPopupViewDelegate <NSObject>
- (void)popupViewWasDismissedByUser:(RNPopupView *)popupView;
- (void)popupViewDirectionChanged:(RNPointDirection)direction;
@end

