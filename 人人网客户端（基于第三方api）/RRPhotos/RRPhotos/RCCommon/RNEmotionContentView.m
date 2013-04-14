//
//  RNEmotionContentView.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-28.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNEmotionContentView.h"
#import "RRGIFImageView.h"
#import "RNEmotionView.h"
#import "RNEmotion.h"
static NSUInteger emotionContentViewWidth = 320;
static NSUInteger emotionContentViewHight = 188;
static NSUInteger pageControlHight = 20;

@implementation RNEmotionContentView
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize parentView = _parentView;
@synthesize emotionLayoutData = _emotionLayoutData;
@synthesize dataSource = _dataSource;

- (void)dealloc{
    self.scrollView = nil;
    self.pageControl = nil;
    self.parentView = nil;
    self.emotionLayoutData = nil;
    self.dataSource = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithLayoutData:(RNEmotionLayoutData *) layoutData andDataSource:(NSArray *)dataSource{
    self = [super init];
    if (self) {
        self.emotionLayoutData = layoutData;
        self.dataSource = dataSource;
        self.frame = CGRectMake(0, 0, emotionContentViewWidth, emotionContentViewHight);
        [self initSubviews];
        [self loadScrollView];
    }
    return self;
}

#pragma mark - init and layout subviews
- (void)initSubviews{
    // 计算展示表情需要的页数
    NSUInteger itemCountInOneRow = (emotionContentViewWidth - self.emotionLayoutData.emotionOriginalX + self.emotionLayoutData.emotionXvalueIncrement - self.emotionLayoutData.emotionSize.width) / self.emotionLayoutData.emotionXvalueIncrement;
    NSUInteger itemCountInOneColumn = (emotionContentViewHight - self.emotionLayoutData.emotionOriginalY + self.emotionLayoutData.buttonYvalueIncrement - self.emotionLayoutData.buttonSize.height) / self.emotionLayoutData.emotionYvalueIncrement;
    _numberOfPages = (self.emotionLayoutData.emotionCount + itemCountInOneRow * itemCountInOneColumn - 1) / (itemCountInOneRow * itemCountInOneColumn);
    
    // 初始化scrollView
    _scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = CGRectMake(0, 0, emotionContentViewWidth, emotionContentViewHight);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(320 * _numberOfPages, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces =NO;
    self.scrollView.delegate = self;
    //随便默认背景色
    //self.scrollView.backgroundColor = [UIColor blackColor];
    UIImage *imagebg = [UIImage imageNamed:@"publish_emotionsButton_bg_sel.png"]; 
    imagebg = [imagebg stretchableImageWithLeftCapWidth:floorf(imagebg.size.width/2) 
                                             topCapHeight:floorf(imagebg.size.height/2)];   
    
    self.scrollView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:0.96];
    [self addSubview:self.scrollView];
    // 初始化pageControl
    _pageControl = [[RNPageControl alloc] init];
    self.pageControl.frame = CGRectMake(0, emotionContentViewHight - pageControlHight, 320, pageControlHight);
    self.pageControl.numberOfPages = _numberOfPages;
    self.pageControl.currentPage = 0;
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.dotColorCurrentPage = RGBCOLOR(128,128,128);
    self.pageControl.dotColorOtherPage = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    [self addSubview:self.pageControl];
}

- (void)loadScrollView{
    // 在scrollView上面加载表情和覆盖在表情上面的按钮
    // 准备计算坐标需要的基本数据
    CGFloat pageWidth = self.scrollView.frame.size.width;
    CGFloat pageHight = self.scrollView.frame.size.height;
    NSUInteger pageCount = _numberOfPages;
    NSUInteger itemCountInOneRow = (pageWidth - self.emotionLayoutData.emotionOriginalX + self.emotionLayoutData.emotionXvalueIncrement - self.emotionLayoutData.emotionSize.width) / self.emotionLayoutData.emotionXvalueIncrement;
    NSUInteger itemCountInOneColumn = (pageHight - self.emotionLayoutData.emotionOriginalY + self.emotionLayoutData.buttonYvalueIncrement - self.emotionLayoutData.buttonSize.height) / self.emotionLayoutData.emotionYvalueIncrement;
    NSUInteger currentItemPosition = 0;
    // 表情和按钮的起始坐标
    NSUInteger emotionX = self.emotionLayoutData.emotionOriginalX;
    NSUInteger emotionY = self.emotionLayoutData.emotionOriginalY;
    NSUInteger buttonX = self.emotionLayoutData.buttonOriginalX;
    NSUInteger buttonY = self.emotionLayoutData.buttonOriginalY;
    // 分页往每一页写坐标
    for (int currentPage = 0; currentPage < pageCount; currentPage ++) {
        
        emotionX = currentPage * pageWidth + self.emotionLayoutData.emotionOriginalX;
        emotionY = self.emotionLayoutData.emotionOriginalY;
        buttonX = currentPage * pageWidth + self.emotionLayoutData.buttonOriginalX;
        buttonY = self.emotionLayoutData.buttonOriginalY;
        // 计算每一页的布局
        for (int onePageCount = 0; 
             (onePageCount < itemCountInOneRow * itemCountInOneColumn) && 
             (currentItemPosition < self.emotionLayoutData.emotionCount); 
             onePageCount ++,currentItemPosition ++) {
            
          
            RNEmotion *emotion = (RNEmotion *)[self.dataSource objectAtIndex:currentItemPosition];

        
            NSString *filepath = emotion.emotionPath;
            if(emotion.emotionPosition == InProjectResource){
                filepath = [[NSBundle mainBundle] pathForResource:emotion.emotionPath ofType:nil];
            }
            RRGIFImageView *emotionImageView = [[RRGIFImageView alloc] initWithGIFFile:filepath];
             
            
            emotionImageView.frame = CGRectMake(emotionX, 
                                                emotionY, 
                                                self.emotionLayoutData.emotionSize.width, 
                                                self.emotionLayoutData.emotionSize.width);
            [self.scrollView addSubview:emotionImageView];
            //[emotionImageView release];
            
            UIButton *button = [[UIButton alloc] init];
            button.frame = CGRectMake(buttonX, 
                                      buttonY, 
                                      self.emotionLayoutData.buttonSize.width, 
                                      self.emotionLayoutData.buttonSize.width);
            [button setTitle:emotion.escapeCode forState:UIControlStateDisabled];
            [button setImage:[UIImage imageNamed:@"navigationbar_btn_bg.png"] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(sendTextToParentView:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:button];
            [button release];
            // 重新计算表情起点
            if (((currentItemPosition + 1) % itemCountInOneRow)) {
                // 不换行
                buttonX += self.emotionLayoutData.buttonXvalueIncrement;
                emotionX += self.emotionLayoutData.emotionXvalueIncrement;
            }else{
                // 换行
                buttonX = currentPage * pageWidth + self.emotionLayoutData.buttonOriginalX;
                buttonY += self.emotionLayoutData.buttonYvalueIncrement;
                emotionX = currentPage * pageWidth + self.emotionLayoutData.emotionOriginalX;
                emotionY += self.emotionLayoutData.emotionYvalueIncrement;
            }
        }
    }
    
}

- (void)sendTextToParentView:(UIButton*)sender{
    if ([self.parentView isKindOfClass:[RNEmotionView class]]) {
        RNEmotionView *parentview = (RNEmotionView *)self.parentView;
        if ([parentview respondsToSelector:@selector(addEmotionInText:)] ) {
            [parentview addEmotionInText:[sender titleForState: UIControlStateDisabled]];
        }
    }
}

#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
}

@end
