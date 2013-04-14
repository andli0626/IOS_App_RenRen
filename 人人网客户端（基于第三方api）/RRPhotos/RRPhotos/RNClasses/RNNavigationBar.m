//
//  RNNavBar.m
//  RRSpring
//
//  Created by hai zhang on 2/20/12.
//  Copyright (c) 2012 Renn. All rights reserved.
//

#import "RNNavigationBar.h"

#define MAX_EXTENDBUTTON_COUNT 3
#define BACKBUTTON_X 5
#define RIGHTBUTTON_X_OFFSET 5
#define TITLE_HASBACK_X_OFFSET 10 // 有返回按钮时title相对返回按钮的位移
#define TITLE_X_OFFSET 12 // 没有返回按钮时title相对边界的位移
#define EXPANDFLAG_X_OFFSET 6
#define BUTTONS_X_OFFSET 11
#define BUTTONS_SPACE_WIDTH 21

#define EXPAND_ANIMATION_INTERVAL 0.3

@interface RNNavigationBar (RNNavigationBarPrivate)

/*
 * 点击标题
 */
- (void)didClickTitle;

/*
 * 展开动画
 */
- (void)animatedExpand:(BOOL)expand;

@end

@implementation RNNavigationBar

@synthesize backgroundView = _backgroundView;
@synthesize backButton = _backButton;
@synthesize rightButton = _rightButton;
@synthesize title = _title;
@synthesize titleLabel = _titleLabel;
@synthesize expandView = _expandView;
@synthesize isExpand = _isExpand;
@synthesize extendButtons = _extendButtons;
@synthesize backButtonEnable = _backButtonEnable;
@synthesize expandEnable = _expandEnable;
@synthesize rightButtonEnable = _rightButtonEnable;
@synthesize barDelegate = _barDelegate;

- (void)dealloc {
    self.backgroundView = nil;
    RL_RELEASE_SAFELY(_backButton);
    self.rightButton = nil;
    self.title = nil;
    self.titleLabel = nil;
    self.expandView = nil;
    self.extendButtons = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *background = [UIImage middleStretchableImageWithKey:@"button_bar"];
        //[[RCResManager getInstance] imageForKey:@"navigationbar_background"];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:background];
        backgroundView.frame =CGRectMake(0, 0, PHONE_SCREEN_SIZE.width, CONTENT_NAVIGATIONBAR_HEIGHT);
        self.backgroundView = backgroundView;
        RL_RELEASE_SAFELY(backgroundView);
        [self addSubview:self.backgroundView];
        
        _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [self addSubview:self.backButton];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightButton = rightButton;
        [self addSubview:self.rightButton];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font  = [UIFont fontWithName:MED_HEITI_FONT size:18];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0, -1.0);
        titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.75];
        self.titleLabel = titleLabel;
        self.titleLabel.userInteractionEnabled = YES;
        RL_RELEASE_SAFELY(titleLabel);
        [self addSubview:self.titleLabel];
        
        UIImage *expandFlag = [[RCResManager getInstance] imageForKey:@"navigationbar_arrow"];

        UIImageView *expandView = [[UIImageView alloc] initWithImage:expandFlag];
        self.expandView = expandView;
        RL_RELEASE_SAFELY(expandView);
        [self addSubview:self.expandView];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                        action:@selector(didClickTitle)];
        [self addGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = self;
        RL_RELEASE_SAFELY(tapRecognizer);
        
        _maxExtendButtonCount = MAX_EXTENDBUTTON_COUNT;
        self.backButtonEnable = YES;
        self.expandEnable = NO;
        self.rightButtonEnable = NO;
    }
    
    return self;
}

- (void)layoutSubviews{
    if (self.backButtonEnable) {
        CGSize backbuttonSize = [[self.backButton currentImage] size];
        CGRect backbuttonFrame = CGRectMake(BACKBUTTON_X,
                                            (CONTENT_NAVIGATIONBAR_HEIGHT - backbuttonSize.height)/2,
                                            backbuttonSize.width,
                                            backbuttonSize.height);
        self.backButton.frame = CGRectIntegral(backbuttonFrame);
    }

    
    CGSize titleSize = [self.title sizeWithFont:self.titleLabel.font];
    self.titleLabel.text = self.title;
    
    CGFloat originalX = self.backButtonEnable ? CGRectGetMaxX(self.backButton.frame) + TITLE_HASBACK_X_OFFSET : TITLE_X_OFFSET;
    CGRect titleFrame = CGRectMake(self.backButtonEnable ? CGRectGetMaxX(self.backButton.frame) + TITLE_HASBACK_X_OFFSET : TITLE_X_OFFSET,
                                   (CONTENT_NAVIGATIONBAR_HEIGHT - titleSize.height)/2,
                                   titleSize.width,
                                   titleSize.height);
    self.titleLabel.frame = CGRectIntegral(titleFrame);
    
    if (self.expandEnable) {
        CGSize expandViewSize = self.expandView.image.size;
        CGRect expandViewFrame = CGRectMake(CGRectGetMaxX(titleFrame) + EXPANDFLAG_X_OFFSET,
                                            (CONTENT_NAVIGATIONBAR_HEIGHT - expandViewSize.height)/2,
                                            expandViewSize.width,
                                            expandViewSize.height);
        self.expandView.frame = CGRectIntegral(expandViewFrame);
        if (self.isExpand) {
            self.expandView.transform = CGAffineTransformMakeRotation(M_PI);
        }
        else{
            self.expandView.transform = CGAffineTransformIdentity;
        }
    }

    if (self.rightButtonEnable) {
        CGSize rightButtonSize = self.rightButton.currentImage.size;
        if(rightButtonSize.width==0||rightButtonSize.height == 0){
            rightButtonSize = self.rightButton.currentBackgroundImage.size;
        }
        CGRect rightButtonFrame = CGRectMake(self.bounds.size.width - RIGHTBUTTON_X_OFFSET - rightButtonSize.width,
                                             (CONTENT_NAVIGATIONBAR_HEIGHT - rightButtonSize.height)/2,
                                             rightButtonSize.width,
                                             rightButtonSize.height);
        self.rightButton.frame = CGRectIntegral(rightButtonFrame);
        
        
        CGFloat labelWidth = self.rightButton ? CGRectGetMinX(self.rightButton.frame) - originalX : titleSize.width;
        CGRect titleFrame = CGRectMake(self.backButtonEnable ? CGRectGetMaxX(self.backButton.frame) + TITLE_HASBACK_X_OFFSET : TITLE_X_OFFSET,
                                       (CONTENT_NAVIGATIONBAR_HEIGHT - titleSize.height)/2,
                                       labelWidth,
                                       titleSize.height);
        self.titleLabel.frame = CGRectIntegral(titleFrame);
    }else{
        for (NSInteger btnIdx = 0; btnIdx < self.extendButtons.count; btnIdx ++) {
            UIButton *button = [self.extendButtons objectAtIndex:(self.extendButtons.count - btnIdx - 1)];
            CGSize buttonSize = [[button currentImage] size];
            CGFloat buttonX = self.bounds.size.width - BUTTONS_X_OFFSET - btnIdx * (buttonSize.width + BUTTONS_SPACE_WIDTH) - buttonSize.width;
            CGRect buttonFrame = CGRectMake(buttonX,
                                            (CONTENT_NAVIGATIONBAR_HEIGHT - buttonSize.height)/2, 
                                            buttonSize.width,
                                            buttonSize.height);
            button.frame= CGRectIntegral(buttonFrame);
        }
        
        UIButton *firstButton = (UIButton *)[self.extendButtons objectAtIndex:0];
        CGFloat labelWidth = self.extendButtons ? CGRectGetMinX(firstButton.frame) - originalX : titleSize.width;
        CGRect titleFrame = CGRectMake(originalX,
                                       (CONTENT_NAVIGATIONBAR_HEIGHT - titleSize.height)/2,
                                       labelWidth,
                                       titleSize.height);
        self.titleLabel.frame = CGRectIntegral(titleFrame);
    }
}

- (CGFloat)barHeight{
    return CONTENT_NAVIGATIONBAR_HEIGHT;
}

- (void)setBackButtonEnable:(BOOL)backButtonEnable{
    _backButtonEnable = backButtonEnable;
    self.backButton.hidden = !_backButtonEnable;
}

- (void)setExpandEnable:(BOOL)expandEnable{
    _expandEnable = expandEnable;
    self.expandView.hidden = !_expandEnable;
}

- (void)setRightButtonEnable:(BOOL)rightButtonEnable{
    _rightButtonEnable = rightButtonEnable;
    self.rightButton.hidden = !_rightButtonEnable;
    
    for (UIButton *extendButton in self.extendButtons) {
        extendButton.hidden = _rightButtonEnable;
    }
}
/*
 * 添加一个扩展按钮
 * 
 * @target 按钮执行目标
 * @touchUpInSideSelector 在按钮上抬起时的执行方法
 * @normalImage 按钮普通图标
 * @highlightedImage 按钮高亮图标
 *
 * @return 是否添加按钮成功
 */
- (BOOL)addExtendButtonWithTarget:(id)target 
            touchUpInSideSelector:(SEL)selector
                      normalImage:(UIImage *)normalImage
                 highlightedImage:(UIImage *)highlightedImage{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    
    return [self addExtendButton:button];
}

/*
 * 添加一组扩展按钮
 * 
 * @buttons 添加按钮对象数组
 * 
 * @return 是否添加成功
 */
- (BOOL)addExtendButtons:(NSArray *)buttons{
    for (UIButton *button in buttons) {
        if (![self addExtendButton:button]) {
            return NO;
        }
    }
    
    return YES;
}

/*
 * 添加一个扩展按钮
 *
 * @button 添加的按钮对象
 *
 * @return 是否添加按钮成功，失败的原因可能是因为按钮数超过最大允许数量（默认3）
 */
- (BOOL)addExtendButton:(UIButton *)button{
    if (self.extendButtons == nil) {
        NSMutableArray *extendButtons = [NSMutableArray arrayWithCapacity:_maxExtendButtonCount];
        self.extendButtons = extendButtons;
    }
    
    if (button == nil || self.extendButtons.count >= _maxExtendButtonCount) {
        return NO;
    }
    
    [self.extendButtons addObject:button];
    [self addSubview:button];
    return YES;
}

/*
 * 清空所有扩展按钮
 */
- (void)cleanExtendButtons{
    for (UIButton *button in self.extendButtons) {
        [button removeFromSuperview];
    }
    
    [self.extendButtons removeAllObjects];
}

/*
 * 点击标题
 */
- (void)didClickTitle{
    if (!self.expandEnable) {
        return;
    }
    
    self.isExpand = !self.isExpand;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return NO;
    }
    
    CGPoint location = [touch locationInView:self];
    if (location.x > CGRectGetMinX(self.titleLabel.frame)) {
        if (self.rightButtonEnable) {
            if (location.x < CGRectGetMinX(self.rightButton.frame)) {
                return YES;
            }
            return NO;
        }
        else {
            UIButton *firstButton = [self.extendButtons objectAtIndex:0];
            if (firstButton) {
                if (location.x < CGRectGetMinX(firstButton.frame)) {
                    return YES;
                }
                return NO;
            }
        }
        return YES;
    }
    
    return NO;
}


/*
 * 展开动画
 */
- (void)animatedExpand:(BOOL)expand{
    if (!self.expandEnable) {
        return;
    }
    
    [UIView animateWithDuration:EXPAND_ANIMATION_INTERVAL
                     animations:^{
                         self.expandView.transform = expand ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
                     }];
}

/*
 * 设置展开标记
 */
- (void)setIsExpand:(BOOL)isExpand{
    if (!self.expandEnable) {
        return;
    }
    
    _isExpand = isExpand;
    [self animatedExpand:_isExpand];
    if (self.barDelegate) {
        [self.barDelegate navigationBar:self didClickExpand:_isExpand];
    }
}


@end