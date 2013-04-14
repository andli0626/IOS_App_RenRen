//
//  RSChatContactSectionView.m
//  RenrenSixin
//
//  Created by 陶宁 on 11-11-9.
//  Copyright (c) 2011年 renren. All rights reserved.
//

#import "RNFriendsSectionView.h"
#import "RNFriendsSectionInfo.h"
#import "RCResManager.h"
#import <QuartzCore/QuartzCore.h>
#define ONE_LINE_SPACE 0.0f // 先偷个懒
#define MAX_ROW_TITLE_COUNT 4 // 每行标题数
#define MAX_SCROLL_ROW_COUNT 4  // 最大的滚动行数
#define SCROLL_CLEAR_SPACE 2.0f // scrollview.section 上下透明和偏移
#define BTN_SIZE_WIDTH 42.0f
#define BTN_SIZE_HEIGHT 25.0f//(37.0f-2*SCROLL_CLEAR_SPACE)
#define BTN_ROW_SPACE 3.0f   // 横向间隔
#define BTN_COL_SPACE 8.0f   // 纵向间隔
#define RES_BAR_TRAIL 20.0f  // 主题素材尾部长度
#define TITLE_BTN_START_X 72.0f // 姓button初始x
#define TITLE_BTN_START_Y 1.5f;
#define EXT_TIPS_X 42.0f
#define EXT_TIPS_Y 4.0f
#define MIN_LEFT_COUNT_WIDTH 30

#define MAX_SCROLL_FRAME_HEIGHT MAX_SCROLL_ROW_COUNT*(BTN_SIZE_HEIGHT+BTN_COL_SPACE)+BTN_SIZE_HEIGHT/1.5// 最大的scroll高度 //148.0f

@interface RNFriendsSectionView (private)
- (void)titleBtnTouched:(id)sender;
- (void)extendBtnTouched:(id)sender;
- (void)setImageViewsFrame;
@end 

@implementation RNFriendsSectionView

@synthesize delegate = _delegate;
@synthesize titleArray = _titleArray;
@synthesize heightChanged = _heightChanged;
@synthesize leftTitleView = _leftTitleView;
@synthesize expButton = _expButton;

#pragma mark - Life 

- (void)dealloc
{
    [_titleBtnArray release];
    [_scrollView release];
    [_scrollBGView release];
    self.titleArray = nil;
    self.leftTitleView = nil;
    _delegate = nil;
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _heightChanged = 0.0f;
        _titlesCount = 0;
        _rowCount = 1;
        _scrollContentSize = CGSizeZero;
        _scrollBGFrame = CGRectZero;

        UIImage *image = [[RCResManager getInstance] imageForKey:@"rn_light_contact_cell_section"];
        _scrollBGView = [[UIImageView alloc] initWithImage:
                         [image stretchableImageWithLeftCapWidth:20 
                                                    topCapHeight:16]];
        _scrollBGView.contentMode = UIViewContentModeScaleToFill;
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.canCancelContentTouches = NO;
        _scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _scrollView.clipsToBounds = YES;	
        _scrollView.scrollEnabled = NO; // 初始化不可滑动
        _scrollView.showsHorizontalScrollIndicator = NO;                
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceHorizontal = NO;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.delegate = self;
        
        [self addSubview:_scrollBGView];
        [self addSubview:_scrollView];
        [self addSubview:self.leftTitleView];
        [self addSubview:self.expButton];
        _firstAppear = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //=========================================================================================================
    CGRect theBGFrame = _scrollBGFrame;
    // TODO: open 再展看
    if (_rowCount > MAX_SCROLL_ROW_COUNT && self.expButton.open) {//最大得背景
        if (!_scrollView.scrollEnabled) {
            _scrollView.scrollEnabled = YES;
        }
        theBGFrame.size.height = MAX_SCROLL_FRAME_HEIGHT; 
    }
    else if(_rowCount > 1 && self.expButton.open){//没到最大行数
        // nothing
    }
    else{//没超过一行
        if (_scrollView.scrollEnabled) {
            _scrollView.scrollEnabled = NO;
        }
        // TODO:这。。。不该有啊  没查出来在哪出问题了
        if (theBGFrame.size.width < _scrollBGView.image.size.width) {
            theBGFrame.origin.x = 0.0f;
            theBGFrame.origin.y = ONE_LINE_SPACE;
            theBGFrame.size.width = _scrollBGView.image.size.width;
        }
        theBGFrame.size.height = _scrollBGView.image.size.height; 
    }

    // 控制区域
    CGRect frame = self.frame;
    frame.size.height = theBGFrame.size.height;
    self.frame = frame; // 设置操作区域
    [_scrollView setContentSize:_scrollContentSize];
    
    // 做个动画 不在这里做就会抖
    if (!_firstAppear) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];          
    }
    // 背景图
    _scrollBGView.frame = theBGFrame;
    
    // 滑动区域
    theBGFrame.origin.y += SCROLL_CLEAR_SPACE;
    theBGFrame.size.height -= (2*SCROLL_CLEAR_SPACE); // 减去透明
    _scrollView.frame = theBGFrame;
    if (!_firstAppear) {
        [UIView commitAnimations]; 
    }
    else{
        _firstAppear = NO;
    }
}

#pragma mark - Public function
- (void)configTitleArray:(NSArray *)array
{
    self.titleArray = nil;
    self.titleArray = array;
    if (!!_titleBtnArray) {
        [_titleBtnArray release];
    }
    _titleBtnArray = [[NSMutableArray alloc]init];
    
    // 如果是空，就只显示一个UI，没有事件相应
    if (self.titleArray == nil) {
        RNFriendsSectionButton *titleBtn = [[RNFriendsSectionButton alloc]initWithFrame:CGRectZero];            
        [titleBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [titleBtn setTitleColor:RGBCOLOR(110, 110, 110) forState:UIControlStateNormal];
        titleBtn.titleLabel.shadowColor = [UIColor colorWithRed:53/255.0 green:75/255.0 blue:84/255.0 alpha:1];
        titleBtn.titleLabel.shadowOffset = CGSizeMake(1.0f, 0.0f);
        [_titleBtnArray addObject:titleBtn];
        [_scrollView addSubview:titleBtn];
        [titleBtn release];
        
        [self setImageViewsFrame];
        return;
    }
    // 配置数据
    for (int i = 0 ;i < [self.titleArray count]; ++i) {

        RSFamilyNameInfo *familyNameInfo = [self.titleArray objectAtIndex:i];
        if (i==0) {// 给扩展按钮赋值
            self.expButton.indexPath = [NSIndexPath indexPathForRow:familyNameInfo.indexPath.row
                                                       inSection:familyNameInfo.indexPath.section];
        }
        NSString *titleName = familyNameInfo.name;//[titleArr objectAtIndex:i];
        if ([titleName length]>0) {
            RNFriendsSectionButton *titleBtn = [[RNFriendsSectionButton alloc]initWithFrame:CGRectZero];            
            titleBtn.indexPath = [NSIndexPath indexPathForRow:familyNameInfo.indexPath.row
                                                    inSection:familyNameInfo.indexPath.section];
            [titleBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
            //[titleBtn.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
            [titleBtn setTitleColor:RGBCOLOR(110, 110, 110) forState:UIControlStateNormal];
            [titleBtn setTitle:titleName forState:UIControlStateNormal];
            [titleBtn setBackgroundImage:[UIImage imageNamed:@"rn_light_contact_index_down"] forState:UIControlStateHighlighted];
            [titleBtn addTarget:self action:@selector(titleBtnTouched:) 
               forControlEvents:UIControlEventTouchUpInside];
            [_titleBtnArray addObject:titleBtn];
            [_scrollView addSubview:titleBtn];
            [titleBtn release];
        }
    }
    // 初始化frame
    [self setImageViewsFrame];
}
- (id)initWithTitleArray:(NSArray*)array
{
    self = [self init];
    if (self) {
        //[self setBackgroundColor:RGBCOLOR(246, 246, 246)];
        [self setBackgroundColor:[UIColor clearColor]];
        [self configTitleArray:array];
    }
    return self;
}
- (void)setExpButtonTitle:(NSString *)title personCount:(NSInteger)count
{
    UILabel* label = (UILabel*)[self.leftTitleView viewWithTag:1];
    label.text = title;
    
    UIButton* button = (UIButton*)[self.leftTitleView viewWithTag:2];
    [button setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateNormal];
    CGSize size = CGSizeMake(MAX(MIN_LEFT_COUNT_WIDTH, [button titleLabel].size.width+2), 22);
    [button setSize:size];
    [self setNeedsLayout];
}
- (void)extendByBtnIsOpenOrNot:(BOOL)open
{
    self.expButton.open = open;
    if([self.titleArray count] > MAX_ROW_TITLE_COUNT){
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.18f];
        if(open){
            self.expButton.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
        }
        else {
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.18f];
            self.expButton.layer.transform = CATransform3DIdentity;
            [CATransaction commit];
        }
        [CATransaction commit];
    }
    [_scrollView setContentOffset:CGPointMake(0.0f,0.0f) animated:YES];
    [self setNeedsLayout];
}
#pragma mark -

- (UIView*)leftTitleView
{
    if(!_leftTitleView){
        _leftTitleView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 70, 22)];
        _leftTitleView.userInteractionEnabled = NO;
        _leftTitleView.backgroundColor = [UIColor clearColor];
        
        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 20, 22)] autorelease];
        label.textAlignment = UITextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = RGBACOLOR(54,54,54,0.55);
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        label.shadowColor = RGBCOLOR(255, 255, 255);
        //label.shadowOffset = CGSizeMake(0,-2);
        // test
        label.text = @"";
        label.tag = 1;
        [_leftTitleView addSubview:label];
        
        UIButton* button = [[[UIButton alloc] initWithFrame:CGRectMake(25, 0, 45, 22)] autorelease];
        button.tag = 2;
        [button setBackgroundImage:[[RCResManager getInstance] imageForKey:@"rn_light_contact_cell_titlecount"] forState:UIControlStateNormal];
        [button setTitle:@"10" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:10]];
        CGSize size = CGSizeMake(MAX(MIN_LEFT_COUNT_WIDTH, [button titleLabel].size.width+2), 22);
        [button setSize:size];
        [_leftTitleView addSubview:button];
    }
    return _leftTitleView;
}

- (RNFriendsSectionButton*)expButton
{
    if(!_expButton){
        _expButton = [[RNFriendsSectionButton alloc]initWithFrame:CGRectZero];            
        _expButton.open = NO;
        _expButton.hidden = YES;
        _expButton.userInteractionEnabled = YES;//初始化为全部可以操作
        _expButton.backgroundColor = [UIColor clearColor];
        UIImage *nomalImage = [[RCResManager getInstance] imageForKey:@"rn_light_contact_exp_bottom"];
        [_expButton setBackgroundImage:nomalImage forState:UIControlStateNormal];
        [_expButton setImage:[[RCResManager getInstance] imageForKey:@"rn_light_contact_exp_arrow"] forState:UIControlStateNormal];
        [_expButton addTarget:self action:@selector(extendBtnTouched:) 
          forControlEvents:UIControlEventTouchUpInside];
        //[_expButton setOrigin:CGPointMake(256, 1)];
        [_expButton setFrame:CGRectMake(256, 1, 30, 30)];
    }
    return _expButton;
}

#pragma mark - Private
-(void)setImageViewsFrame
{
    // 根据皮肤来设置是否能展开
    // 如果不可以展开就，锁定宽度
    if (![[RCResManager getInstance] boolForKey:@"boolOfContactSectionExtend"]) {
        _scrollContentSize.width = [UIScreen mainScreen].applicationFrame.size.width;
    }
    
    _titlesCount = [self.titleArray count];
    
    // 不足一行 包括：没有标题(系统工具)
    _rowCount = 1;
    if (_titlesCount > MAX_ROW_TITLE_COUNT ){
        float fRowCount =(float)((float)_titlesCount/(float)MAX_ROW_TITLE_COUNT); 
        // +1
        self.expButton.hidden = NO;
        _rowCount = ceilf(fRowCount);
    }

    // 添加 姓 按钮
    int btnIndex = 0;
    CGPoint btnPoint = CGPointZero;
    RNFriendsSectionButton *titleBtn=nil;
    btnPoint.y = TITLE_BTN_START_Y;
    for (int row = 0 ; row < _rowCount ;++row) {
        btnPoint.x = TITLE_BTN_START_X;//
        for (int index = 0 ; index < MAX_ROW_TITLE_COUNT; ++index) {
            titleBtn = (RNFriendsSectionButton*)[_titleBtnArray objectAtIndex:btnIndex];
            titleBtn.frame = CGRectMake(btnPoint.x,btnPoint.y,BTN_SIZE_WIDTH,BTN_SIZE_HEIGHT);
            titleBtn.backgroundColor = [UIColor clearColor];
            btnPoint.x += (BTN_SIZE_WIDTH+BTN_ROW_SPACE);
            ++btnIndex;
            // 如果超了就break
            if (btnIndex>=[_titleBtnArray count]) {
                if (titleBtn && _scrollContentSize.width<=0) {
                    _scrollContentSize.width = CGRectGetMaxX(titleBtn.frame);            
                }
                break;
            }
        }
        if (titleBtn && _scrollContentSize.width<=0) {
            _scrollContentSize.width = [UIScreen mainScreen].applicationFrame.size.width;
        }
        btnPoint.x = 0.0f;
        btnPoint.y += (BTN_SIZE_HEIGHT+BTN_COL_SPACE);
    }
    // 记录高度变化
    _heightChanged = btnPoint.y;
    
    if (_scrollContentSize.width < _scrollBGView.image.size.width) {
        _scrollContentSize.width = _scrollBGView.image.size.width;
    }
 
    CGRect lastBtnFrame = ((RNFriendsSectionButton*)[_titleBtnArray objectAtIndex:(_titlesCount-1)>0?(_titlesCount-1):0]).frame;    
    CGFloat scrollHeight = CGRectGetMaxY(lastBtnFrame);

    _scrollContentSize.height = scrollHeight+(2*SCROLL_CLEAR_SPACE);// 加回透明
    if (_scrollContentSize.height < _scrollBGView.image.size.height) {
        _scrollContentSize.height = _scrollBGView.image.size.height;
    }
    
    // 初始化为最大高度
    _scrollBGFrame = CGRectMake(0.0f,
                                ONE_LINE_SPACE, 
                                _scrollContentSize.width+RES_BAR_TRAIL,
                                _scrollContentSize.height);
    
    // 初始化触控大小
    CGRect frame = self.frame;
    frame.size.width = [UIScreen mainScreen].applicationFrame.size.width;
    frame.size.height = _scrollBGView.image.size.height;
    self.frame = frame;
    
    [self setNeedsLayout];
}

- (void)titleBtnTouched:(id)sender
{
    // 点击了就收回
    [self extendByBtnIsOpenOrNot:NO];
    if ([_delegate respondsToSelector:@selector(sectionHeaderView:viewWithActionByTitleButton:)]) {
        [_delegate sectionHeaderView:self viewWithActionByTitleButton:sender];
    }
}

- (void)extendBtnTouched:(id)sender
{
    [self extendByBtnIsOpenOrNot:!self.expButton.open];    
    if ([_delegate respondsToSelector:@selector(sectionHeaderView:viewWithActionByExtendButton:)]) {
        [_delegate sectionHeaderView:self viewWithActionByExtendButton:sender];
    }
}

@end

@implementation RNFriendsSectionButton
@synthesize indexPath;
@synthesize open;

-(void)dealloc
{
    if (self.indexPath) {
        self.indexPath = nil;
    }
    [super dealloc];
}
@end
