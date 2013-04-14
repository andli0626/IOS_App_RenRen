//
//  RNAtFriendViewController.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-31.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBaseViewController.h"
#import "RCMainUser.h"
#import "RNAtFriendsModel.h"
#import "RNAtFriendsTableItemCell.h"
#import "RNFriendsSectionInfo.h"
#import "RNFriendsSectionView.h"
#import "RNCustomText.h"
//at好友数据回传

//friendInfoDic 包括好友的id（key值类型NSNumber*）好友的名称（val类型NSString*）
@protocol RNAtFriendDelegate <NSObject>

- (void)atFriendFinished:(NSDictionary * )friendInfoDic;

@end
@interface RNAtFriendViewController : RNPublishBaseViewController<RNFriendsSectionDelegate,RNCustomTextDelegate>{
    AtFriendType _currentAtType;
    // 记录当前展开的sectionview
    RNFriendsSectionView *_markedExtendSectionView;
    RNCustomText *searchbar;
    UIView *tabview;//切换按钮区域
    BOOL _isSearch;
    id<RNAtFriendDelegate> _atFrienddelete;
    NSNumber* _ownerId;//用于请求权限
}
-(id)initWithOwnerId:(NSNumber*)ownerid;
// 记录哪个section在最顶层
@property (nonatomic, assign) NSInteger inTopSection;
@property (nonatomic, retain) RNFriendsSectionView *markedExtendSectionView;
@property (nonatomic, assign) id<RNAtFriendDelegate> atFrienddelete;
@property (nonatomic, retain) NSNumber *ownerId;
@end
