//
//  RNInputAccessoryView.m
//  RRSpring
//
//  Created by 黎 伟 ✪ on 3/12/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//  edit by 玉平 孙

#import "RNPublisherAccessoryBar.h"

@implementation RNPublisherAccessoryBar
@synthesize backgroundView = _backgroundView;
@synthesize backButton = _backButton;
@synthesize rightButton = _rightButton;
@synthesize title = _title;
@synthesize titleLabel = _titleLabel;
@synthesize publisherBarDelegate = _publisherBarDelegate;
@synthesize publishState=_publishState;
@synthesize backButtonEnable = _backButtonEnable;
@synthesize rightButtonEnable = _rightButtonEnable;

- (void)dealloc {
    self.backgroundView = nil;
    RL_RELEASE_SAFELY(_backButton);
    self.rightButton = nil;
    self.title = nil;
    self.titleLabel = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        UIImage *background = [UIImage middleStretchableImageWithKey:@"navigationbar_background"];
        //[[RCResManager getInstance] imageForKey:@"navigationbar_background"];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:background];
        backgroundView.frame =CGRectMake(0, 0, PHONE_SCREEN_SIZE.width, CONTENT_NAVIGATIONBAR_HEIGHT);
        self.backgroundView = backgroundView;
        RL_RELEASE_SAFELY(backgroundView);
        [self addSubview:self.backgroundView];
        
        _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [self addSubview:self.backButton];
        [_backButton addTarget:self action:@selector(leftbuttonClick) forControlEvents:UIControlEventTouchDown];
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton addTarget:self action:@selector(rightbuttonClick) forControlEvents:UIControlEventTouchDown];
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
        self.backButtonEnable = YES;
        self.rightButtonEnable = YES;
        self.titleLabel.enabled = YES;
//        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
//                                                                                        action:@selector(didClickTitle)];
//        [self.titleLabel addGestureRecognizer:tapRecognizer];
//        RL_RELEASE_SAFELY(tapRecognizer);
        
    }
    return self;
}
- (void)setBackButtonEnable:(BOOL)backButtonEnable{
    _backButtonEnable = backButtonEnable;
    self.backButton.hidden = !_backButtonEnable;
}

- (void)setRightButtonEnable:(BOOL)rightButtonEnable{
    _rightButtonEnable = rightButtonEnable;
    self.rightButton.hidden = !_rightButtonEnable;
}
- (CGFloat)barHeight{
    return CONTENT_NAVIGATIONBAR_HEIGHT;
}
- (void)layoutSubviews{
    [self.backButton setImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_back"]
                     forState:UIControlStateNormal];
    [self.backButton setImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_back_hl"]
                     forState:UIControlStateHighlighted];
    [self.rightButton setBackgroundImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_bg"] forState:UIControlStateNormal];
    if (self.backButtonEnable) {
        CGSize backbuttonSize = [[self.backButton currentImage] size];
        CGRect backbuttonFrame = CGRectMake(5,
                                            (CONTENT_NAVIGATIONBAR_HEIGHT - backbuttonSize.height)/2,
                                            backbuttonSize.width,
                                            backbuttonSize.height);
        self.backButton.frame = CGRectIntegral(backbuttonFrame);
    }
    
    CGSize titleSize = [self.title sizeWithFont:self.titleLabel.font];
    self.titleLabel.text = self.title;
    CGRect titleFrame = CGRectMake((PHONE_SCREEN_SIZE.width -titleSize.width)/2,
                                   (CONTENT_NAVIGATIONBAR_HEIGHT - titleSize.height)/2,
                                   titleSize.width,
                                   titleSize.height);
    self.titleLabel.frame = CGRectIntegral(titleFrame);
    
    if (self.rightButtonEnable) {
        CGSize rightButtonSize = self.rightButton.currentBackgroundImage.size;
        CGRect rightButtonFrame = CGRectMake(PHONE_SCREEN_SIZE.width - 5 - rightButtonSize.width,
                                             (CONTENT_NAVIGATIONBAR_HEIGHT - rightButtonSize.height)/2,
                                             rightButtonSize.width,
                                             rightButtonSize.height);
        self.rightButton.frame = CGRectIntegral(rightButtonFrame);
    }
}
-(void)leftbuttonClick{
    //如果delegate实现了就需要调用，如果没有实现不需要就不去调用
    if (_publisherBarDelegate) {
        if ([_publisherBarDelegate respondsToSelector:@selector(publisherAccessoryBarLeftButtonClick:)] ) {
            [_publisherBarDelegate publisherAccessoryBarLeftButtonClick:self];
        }
    }
}
-(void)rightbuttonClick{
    if (_publisherBarDelegate) {
        if ([_publisherBarDelegate respondsToSelector:@selector(publisherAccessoryBarRightButtonClick:)] ) {
            [_publisherBarDelegate publisherAccessoryBarRightButtonClick:self];
        }
    }
}


@end
