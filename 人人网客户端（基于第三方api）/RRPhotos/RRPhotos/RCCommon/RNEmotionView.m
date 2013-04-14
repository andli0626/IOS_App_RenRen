//
//  RNEmotionView.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-28.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNEmotionView.h"
#import "RNEmotionLayoutData.h"
#import "RNEmotionContentView.h"
#import <QuartzCore/QuartzCore.h>
#import "RNPublisherBottomBar.h"
#import "RNEmotionMap.h"
#warning 暂时这样使用以后要加到单件类管理中
static RNEmotionView *_instance = nil;

@implementation RNEmotionView
@synthesize parentController=_parentController;
@synthesize defaultEmotionsView=_defaultEmotionsView;
@synthesize aliEmotionsView=_aliEmotionsView;
@synthesize jjEmotionsView=_jjEmotionsView;

@synthesize defaultEmotionsButton = _defaultEmotionsButton;
@synthesize aliEmotionsButton = _aliEmotionsButton;
@synthesize jjEmotionsButton = _jjEmotionsButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}
+ (RNEmotionView *)getInstance
{
    @synchronized(self){
        if (_instance == nil) {
            _instance = [[self alloc] init]; 
        }
    }
    return _instance;
}

- (void)dealloc{
    self.parentController = nil;
    self.defaultEmotionsView = nil;
    self.aliEmotionsView = nil;
    self.jjEmotionsView = nil;
    
    self.defaultEmotionsButton = nil;
    self.aliEmotionsButton = nil;
    self.jjEmotionsButton = nil;
    [super dealloc];
}

- (id)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, 0, PHONE_SCREEN_SIZE.width, PUBLISH_ENGISH_KEYBOARD_TOP);
        //初始化视图
        [self buildEmotionView];
    }
    return self;
}
-(void)buildDefaultEmotion{
    RNEmotionMap *emomap = [RNEmotionMap getInstance];
    
    RNEmotionLayoutData *defaultEmotionLayoutData = [[RNEmotionLayoutData alloc] init];
    defaultEmotionLayoutData.emotionCount = [emomap.defaultEmotionsArray count];
    defaultEmotionLayoutData.oneRowCount = 8;//一行表情的个数
    defaultEmotionLayoutData.buttonOriginalX = 0;//记录最左侧按钮X坐标
    defaultEmotionLayoutData.emotionOriginalX = 10;//记录最左侧表情图片X坐标
    defaultEmotionLayoutData.buttonOriginalY = 0;//表情按钮的起始点Y坐标
    defaultEmotionLayoutData.emotionOriginalY = 10;//表情图片的起始点Y坐标
    defaultEmotionLayoutData.buttonXvalueIncrement = 40;//两个相邻表情按钮的起始点X坐标差值
    defaultEmotionLayoutData.buttonYvalueIncrement = 35;//两个相邻表情按钮的起始点Y坐标差值
    defaultEmotionLayoutData.emotionXvalueIncrement = 40;//两个相邻表情图片的起始点X坐标差值
    defaultEmotionLayoutData.emotionYvalueIncrement = 35;//两个相邻表情图片的起始点Y坐标差值
    defaultEmotionLayoutData.emotionSize = CGSizeMake(20, 20);//表情图片大小
    defaultEmotionLayoutData.buttonSize = CGSizeMake(40, 35);//表情按钮大小
    
    RNEmotionContentView *defaultEmotionsView = [[RNEmotionContentView alloc]initWithLayoutData:defaultEmotionLayoutData andDataSource:emomap.defaultEmotionsArray];
    self.defaultEmotionsView = defaultEmotionsView;
    defaultEmotionsView.parentView = self;
    [self addSubview:defaultEmotionsView];
    [defaultEmotionLayoutData release];
    [defaultEmotionsView release];
}
-(void)buildAliEmotion{
    // 初始化阿里表情
    RNEmotionMap *emomap = [RNEmotionMap getInstance];
    RNEmotionLayoutData *aliEmotionLayoutData = [[RNEmotionLayoutData alloc] init];
    aliEmotionLayoutData.emotionCount = [emomap.aliEmotionsArray count];
    aliEmotionLayoutData.oneRowCount = 4;//一行表情的个数
    aliEmotionLayoutData.buttonOriginalX = 16;//记录最左侧按钮X坐标
    aliEmotionLayoutData.emotionOriginalX = 20;//记录最左侧表情图片X坐标
    aliEmotionLayoutData.buttonOriginalY = 23;//表情按钮的起始点Y坐标
    aliEmotionLayoutData.emotionOriginalY = 27;//表情图片的起始点Y坐标
    aliEmotionLayoutData.buttonXvalueIncrement = 80;//两个相邻表情按钮的起始点X坐标差值
    aliEmotionLayoutData.buttonYvalueIncrement = 78;//两个相邻表情按钮的起始点Y坐标差值
    aliEmotionLayoutData.emotionXvalueIncrement = 80;//两个相邻表情图片的起始点X坐标差值
    aliEmotionLayoutData.emotionYvalueIncrement = 78;//两个相邻表情图片的起始点Y坐标差值
    aliEmotionLayoutData.emotionSize = CGSizeMake(40, 40);//表情图片大小
    aliEmotionLayoutData.buttonSize = CGSizeMake(48, 48);//表情按钮大小
    
    RNEmotionContentView *aliEmotionsView = [[RNEmotionContentView alloc] initWithLayoutData:aliEmotionLayoutData andDataSource:emomap.aliEmotionsArray];
    self.aliEmotionsView = aliEmotionsView;
    self.aliEmotionsView.parentView = self;
    self.aliEmotionsView.hidden = YES;
    [self addSubview:aliEmotionsView];
    [aliEmotionLayoutData release];
    [aliEmotionsView release];
}
-(void)buildJjEmotion{
    // 初始化囧囧表情
    RNEmotionMap *emomap = [RNEmotionMap getInstance];
    RNEmotionLayoutData *jjEmotionLayoutData = [[RNEmotionLayoutData alloc] init];
    jjEmotionLayoutData.emotionCount = [emomap.jjEmotionsArray count];
    jjEmotionLayoutData.oneRowCount = 4;//一行表情的个数
    jjEmotionLayoutData.buttonOriginalX = 16;//记录最左侧按钮X坐标
    jjEmotionLayoutData.emotionOriginalX = 20;//记录最左侧表情图片X坐标
    jjEmotionLayoutData.buttonOriginalY = 23;//表情按钮的起始点Y坐标
    jjEmotionLayoutData.emotionOriginalY = 27;//表情图片的起始点Y坐标
    jjEmotionLayoutData.buttonXvalueIncrement = 80;//两个相邻表情按钮的起始点X坐标差值
    jjEmotionLayoutData.buttonYvalueIncrement = 78;//两个相邻表情按钮的起始点Y坐标差值
    jjEmotionLayoutData.emotionXvalueIncrement = 80;//两个相邻表情图片的起始点X坐标差值
    jjEmotionLayoutData.emotionYvalueIncrement = 78;//两个相邻表情图片的起始点Y坐标差值
    jjEmotionLayoutData.emotionSize = CGSizeMake(40, 40);//表情图片大小
    jjEmotionLayoutData.buttonSize = CGSizeMake(48, 48);//表情按钮大小
    
    RNEmotionContentView *jjEmotionsView = [[RNEmotionContentView alloc] initWithLayoutData:jjEmotionLayoutData andDataSource:emomap.jjEmotionsArray];
    self.jjEmotionsView = jjEmotionsView;
    self.jjEmotionsView.parentView = self;
    self.jjEmotionsView.hidden = YES;
    [self addSubview:jjEmotionsView];
    [jjEmotionLayoutData release];
    [jjEmotionsView release];
    

}
//简历表情视图
- (void)buildEmotionView{
    
    //默认表情
    [self buildDefaultEmotion];
    //阿里表情

    //囧囧熊表情
        
    
    //添加按钮区域
    NSInteger btn_h = 28;
    UIView *btnbg=[[UIView alloc] initWithFrame:CGRectMake(0,188 , PHONE_SCREEN_SIZE.width, btn_h)];//184
    btnbg.clipsToBounds = YES;
    NSInteger btnRadius = 8;
    UIView *rectbtnbg = [[UIView alloc] initWithFrame:CGRectMake(1, -btnRadius, PHONE_SCREEN_SIZE.width-2, 40)];
    rectbtnbg.layer.cornerRadius = btnRadius;  
    rectbtnbg.clipsToBounds = YES;
    [btnbg addSubview:rectbtnbg];
    [rectbtnbg release];
    _defaultEmotionsButton = [[UIButton alloc] init];
    self.defaultEmotionsButton.frame = CGRectMake(0, btnRadius, 106, btn_h);
    self.defaultEmotionsButton.tag = 101;
    //zanshi 
    //[self.defaultEmotionsButton setBackgroundColor:[UIColor blueColor]];
    UIImage *imagenormal = [UIImage imageNamed:@"publish_emotionsButton_bg.png"]; 
    imagenormal = [imagenormal stretchableImageWithLeftCapWidth:floorf(imagenormal.size.width/2) 
                                       topCapHeight:floorf(imagenormal.size.height/2)];
    UIImage *imagesel = [UIImage imageNamed:@"publish_emotionsButton_bg_sel.png"]; 
    imagesel = [imagesel stretchableImageWithLeftCapWidth:floorf(imagesel.size.width/2) 
                                             topCapHeight:floorf(imagesel.size.height/2)]; 
    
    [self.defaultEmotionsButton setBackgroundImage:imagenormal forState:UIControlStateNormal];
    [self.defaultEmotionsButton setBackgroundImage:imagesel forState:UIControlStateHighlighted];
    [self.defaultEmotionsButton setTitle:NSLocalizedString(@"默认", @"默认")  forState:UIControlStateNormal];
    [self.defaultEmotionsButton setTitle:NSLocalizedString(@"默认", @"默认")  forState:UIControlStateHighlighted];
    
    //[self.defaultEmotionsButton.titleLabel setFont:[UIFont systemFontOfSize:20.0f ]];
    [self.defaultEmotionsButton setTitleColor:RGBCOLOR(152,154,156) forState:UIControlStateNormal];
    [self.defaultEmotionsButton setTitleShadowColor:RGBCOLOR(0,0,0) forState:UIControlStateNormal];
    
    [self.defaultEmotionsButton addTarget:self action:@selector(chageEmotions:) forControlEvents:UIControlEventTouchUpInside];
    [rectbtnbg addSubview:self.defaultEmotionsButton];
    
    _aliEmotionsButton = [[UIButton alloc] init];
    self.aliEmotionsButton.frame = CGRectMake(106, btnRadius, 106, btn_h);
    self.aliEmotionsButton.tag = 102;
    //zanshi
    [self.aliEmotionsButton setBackgroundImage:imagenormal forState:UIControlStateNormal];
    [self.aliEmotionsButton setBackgroundImage:imagesel forState:UIControlStateHighlighted];
    [self.aliEmotionsButton setTitle:NSLocalizedString(@"阿狸", @"阿狸")  forState:UIControlStateNormal];
    [self.aliEmotionsButton setTitle:NSLocalizedString(@"阿狸", @"阿狸")  forState:UIControlStateHighlighted];
    [self.aliEmotionsButton setTitleColor:RGBCOLOR(152,154,156) forState:UIControlStateNormal];
    [self.aliEmotionsButton setTitleShadowColor:RGBCOLOR(0,0,0) forState:UIControlStateNormal];
    
    [self.aliEmotionsButton addTarget:self action:@selector(chageEmotions:) forControlEvents:UIControlEventTouchUpInside];
    [rectbtnbg addSubview:self.aliEmotionsButton];

    _jjEmotionsButton = [[UIButton alloc] init];
    self.jjEmotionsButton.frame = CGRectMake(212, btnRadius, 106, btn_h);
    self.jjEmotionsButton.tag = 103;
    //zanshi
    [self.jjEmotionsButton setBackgroundImage:imagenormal forState:UIControlStateNormal];
    [self.jjEmotionsButton setBackgroundImage:imagesel forState:UIControlStateHighlighted];
    [self.jjEmotionsButton setTitle:NSLocalizedString(@"囧囧熊", @"囧囧熊")  forState:UIControlStateNormal];
    [self.jjEmotionsButton setTitle:NSLocalizedString(@"囧囧熊", @"囧囧熊")  forState:UIControlStateHighlighted];
    [self.jjEmotionsButton setTitleColor:RGBCOLOR(152,154,156) forState:UIControlStateNormal];
    [self.jjEmotionsButton setTitleShadowColor:RGBCOLOR(0,0,0) forState:UIControlStateNormal];
    
    [self.jjEmotionsButton addTarget:self action:@selector(chageEmotions:) forControlEvents:UIControlEventTouchUpInside];
    [rectbtnbg addSubview:self.jjEmotionsButton];
    [self addSubview:btnbg];
    [btnbg release];
    [self chageEmotions:self.defaultEmotionsButton];
}
-(void)chageEmotions:(UIButton*)btn{
    NSLog(@"syp===btn=%d",btn.tag);
    UIImage *imagenormal = [UIImage imageNamed:@"publish_emotionsButton_bg.png"]; 
    imagenormal = [imagenormal stretchableImageWithLeftCapWidth:floorf(imagenormal.size.width/2) 
                                                   topCapHeight:floorf(imagenormal.size.height/2)];
    UIImage *imagesel = [UIImage imageNamed:@"publish_emotionsButton_bg_sel.png"]; 
    imagesel = [imagesel stretchableImageWithLeftCapWidth:floorf(imagesel.size.width/2) 
                                             topCapHeight:floorf(imagesel.size.height/2)];   
    
    [self.defaultEmotionsButton setBackgroundImage:imagenormal forState:UIControlStateNormal];
    [self.aliEmotionsButton setBackgroundImage:imagenormal forState:UIControlStateNormal];
    [self.jjEmotionsButton setBackgroundImage:imagenormal forState:UIControlStateNormal];
    if (self.defaultEmotionsView) {
        self.defaultEmotionsView.hidden = YES;
    }
    if (self.aliEmotionsView) {
        self.aliEmotionsView.hidden = YES;
    }
    if (self.jjEmotionsView) {
        self.jjEmotionsView.hidden = YES;
    }

    
    [btn setBackgroundImage:imagesel forState:UIControlStateNormal];
    if (btn.tag == 101) {
        if (self.defaultEmotionsView==nil) {
            [self buildDefaultEmotion];
        }
        self.defaultEmotionsView.hidden = NO;
    }else if(btn.tag == 102){
        if (self.aliEmotionsView==nil) {
            [self buildAliEmotion];
        }
        self.aliEmotionsView.hidden = NO;
    }else if(btn.tag == 103){
        if (self.jjEmotionsView==nil) {
            [self buildJjEmotion];
        }
        self.jjEmotionsView.hidden = NO;
    }

}
//将选中的表情以text形式加到输入框
-(void)addEmotionInText:(NSString*)emojeText{
    if ([self.parentController isKindOfClass:[RNPublisherBottomBar class]]) {
        RNPublisherBottomBar *pview = (RNPublisherBottomBar*)self.parentController;
        if ([pview respondsToSelector:@selector(addEmotionInText:)] ) {
            [pview addEmotionInText:emojeText];
        }
    }
}

@end
