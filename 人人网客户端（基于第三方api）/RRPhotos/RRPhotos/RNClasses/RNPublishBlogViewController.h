//
//  RNPublishBlogViewController.h
//  RRSpring
//
//  Created by yi chen on 12-4-11.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBigCommentViewController.h"
#import "RNPublisherAccessoryBar.h"
@interface RNPublishBlogViewController : RNPublishBigCommentViewController<UITextFieldDelegate>
{
	//导航条
	RNPublisherAccessoryBar *_accessoryBar;

	//日志标题栏
	UITextField *_blogTitleField;
	
	NSString *_firstResponder;
}
@property(nonatomic,retain) RNPublisherAccessoryBar *accessoryBar;

@property(nonatomic,retain) UITextField *blogTitleField;


@end
