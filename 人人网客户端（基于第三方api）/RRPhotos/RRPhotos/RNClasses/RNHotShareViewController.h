//
//  RNExploreViewController.h
//  RRPhotos
//
//  Created by yi chen on 12-5-11.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNModelViewController.h"
#import "RNHotShareContentViewController.h"
#import "RNHotShareItem.h"
/*	-----------------------------------  */
/*			热门分享首页					 */
/*	-----------------------------------  */
@interface RNHotShareViewController : RNModelViewController
{
	//分享的数据项
	NSMutableArray *_hotShareItems;
	//照片内容滚动视图
	UIScrollView *_contentScrollView;
	//父Controller
	UIViewController *_parentController;
	
}
@property(nonatomic,retain)NSMutableArray *hotShareItems;
@property(nonatomic,retain)UIScrollView *contentScrollView;
@property(nonatomic,assign)UIViewController *parentController;

@end
