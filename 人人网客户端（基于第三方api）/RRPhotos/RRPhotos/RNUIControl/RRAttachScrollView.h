//
//  RRCellScrollView.h
//  RRPhotos
//
//  Created by yi chen on 12-3-27.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RRImageView.h"
#import "RRNewsFeedItem.h"
#import "UIImageView+RRWebImage.h"
//滚动视图在屏幕宽度范围内显示的最多照片数目
#define kAttachImageViewCountMax	3	
//每个照片高度
#define kAttachImageViewHeight (PHONE_SCREEN_SIZE.width / kAttachImageViewCountMax) 
//每个照片宽度
#define kAttachImageViewWidth kAttachImageViewHeight		

@protocol RRAttachScrollViewDelegate <UIScrollViewDelegate>

/*
	点击某张照片
 */
- (void)tapAttachImageAtIndex:(NSInteger)index andAttachItem:(RRAttachmentItem *)item;

@end
@interface RRAttachScrollView : UIScrollView <UIScrollViewDelegate>
{
	@private
	//附件信息容容器
	NSMutableArray *_attachments;
	//照片
	NSMutableArray *_attachImageViews;
	//当前选中的图片索引
	NSInteger _selectedIndex;
	
	id<RRAttachScrollViewDelegate> _attachScrollViewDelegate;
}
@property(nonatomic, retain) NSMutableArray *attachments;
@property(nonatomic, retain) NSMutableArray *attachImageViews;
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, assign) id<RRAttachScrollViewDelegate> attachScrollViewDelgate;
/*
	通过附件数据重置控件内容
 */
- (void)setWithAttachments:(NSArray *)attachments;
@end
