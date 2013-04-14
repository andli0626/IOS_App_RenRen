//
//  RSChatContactSectionView.h
//  RenrenSixin
//
//  Created by 陶宁 on 11-11-9.
//  Copyright (c) 2011年 renren. All rights reserved.
//
// #import "UIView.h"
#import "RNView.h"
@class RNFriendsSectionView;
@class RNFriendsSectionInfo;
@class RNFriendsSectionButton;

@protocol RNFriendsSectionDelegate <NSObject>
-(void)sectionHeaderView:(RNFriendsSectionView*)sectionHeaderView viewWithActionByExtendButton:(RNFriendsSectionButton*)extBtn;
-(void)sectionHeaderView:(RNFriendsSectionView*)sectionHeaderView viewWithActionByTitleButton:(RNFriendsSectionButton*)titleBtn;
@end

@interface RNFriendsSectionView : RNView <UIScrollViewDelegate>{
    
    id<RNFriendsSectionDelegate> _delegate;

    UIScrollView *_scrollView;
    UIImageView *_scrollBGView;
    
    NSArray *_titleArray;           
    NSMutableArray *_titleBtnArray;
    
    float _heightChanged;           // 高度变化
    
    CGSize _scrollContentSize;  
    CGRect _scrollBGFrame;       // 背景大小        
    
    NSInteger _titlesCount;  // 姓 数量
    NSInteger _rowCount;     // 行数
    
    BOOL _firstAppear;
    UIView* _leftTitleView;
    RNFriendsSectionButton* _expButton;

}

@property (nonatomic, retain) id<RNFriendsSectionDelegate> delegate;
@property (nonatomic, retain) NSArray *titleArray;
@property (nonatomic, assign) float heightChanged;
@property (nonatomic, retain) UIView* leftTitleView;
@property (nonatomic, retain) RNFriendsSectionButton* expButton;
// 初始化设置sectionInfo
- (id)initWithTitleArray:(NSArray *)array;
- (void)configTitleArray:(NSArray *)array;
- (void)setExpButtonTitle:(NSString *)title personCount:(NSInteger)count;
- (void)extendByBtnIsOpenOrNot:(BOOL)open; // 暴露展开 收缩的接口
@end

@interface RNFriendsSectionButton : UIButton 
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL open;
@end
