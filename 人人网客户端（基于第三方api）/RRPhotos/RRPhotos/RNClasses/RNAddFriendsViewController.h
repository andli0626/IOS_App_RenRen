//
//  RNAddFriendsViewController.h
//  RRSpring
//
//  Created by yi chen on 12-4-12.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBigCommentViewController.h"
#import "RNPublisherAccessoryBar.h"
@interface RNAddFriendsViewController : RNPublishBigCommentViewController
{

	//用于检查是否要加特别关注
	BOOL _bFocusFriend;
	
	//添加好友的必要信息
	NSMutableDictionary *_infoDic;
	
	//默认文案，我是xxx，想加你为好友
	NSString *_defaultContent;
	
}
@property(nonatomic,assign)BOOL bFocusFriend;

@property(nonatomic,retain)NSMutableDictionary *infoDic;

@property(nonatomic,copy)NSString *defaultContent;
/*
	必传参数：uid	 	 申请用户id
 */
- (id)initWithInfo:(NSMutableDictionary*)info;
@end
