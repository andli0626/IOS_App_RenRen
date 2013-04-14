//
//  RRCellScrollView.m
//  RRPhotos
//
//  Created by yi chen on 12-3-27.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RRAttachScrollView.h"
//照片上填充
#define kScrollViewPhotoPaddingTop 3
#define kScrollViewPhotoPaddingBottom 3
#define kScrollViewPhotoPaddingLeft 1.5
#define kScrollViewPhotoPaddingRight 1.5

@implementation RRAttachScrollView
@synthesize attachments = _attachments;
@synthesize attachImageViews = _attachImageViews;
@synthesize selectedIndex = _selectedIndex;
@synthesize attachScrollViewDelgate = _attachScrollViewDelegate;
- (void)dealloc{
	self.attachments = nil;
	self.attachImageViews = nil;
	self.attachScrollViewDelgate = nil;
	[super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		//　设置委托
		self.delegate = self; 
		// 是否按页滚动
		self.pagingEnabled = YES;
		// 背景色 ,测试用红色
		self.backgroundColor = [UIColor clearColor];
		// 滚动条颜色 因为背景为黑,所以用白色
		self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
		
		// 显示滚动条
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.canCancelContentTouches = NO;
		self.clipsToBounds = YES;
		self.userInteractionEnabled = YES;
		
    }
	
    return self;
}

/*
	通过附件数据重置控件内容
 */
- (void)setWithAttachments:(NSArray *)attachments{
	if (!attachments || [attachments count] == 0) {
		return;
	}
	self.attachments = [NSMutableArray arrayWithArray:attachments];
	NSMutableArray *imageViews = [[NSMutableArray alloc]initWithCapacity:[self.attachments count]];
	self.attachImageViews  = imageViews;
	TT_RELEASE_SAFELY(imageViews);
	
	[self removeAllSubviews];
	NSInteger tag = 0;
	for (id attachment in attachments) {
		if ([attachment isKindOfClass:RRAttachmentItem.class ]) {
			UIImageView *attachImageView = [[UIImageView alloc]init];
			//添加点击事件

			attachImageView.userInteractionEnabled = YES;
			attachImageView.backgroundColor = [UIColor clearColor];
			attachImageView.contentMode = UIViewContentModeScaleAspectFill; //填充模式设为不改变规模
			NSLog(@"tag= %d",tag);
			attachImageView.tag = tag;
			
			UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAttachImage:)];
			tapGesture.numberOfTapsRequired = 1;
			[attachImageView addGestureRecognizer:tapGesture];
			TT_RELEASE_SAFELY(tapGesture);
			
			CALayer* layer = [attachImageView layer];
			[layer setCornerRadius:5.0];
			layer.masksToBounds = YES;

			//导入高清图片
			NSURL *url;
			if ([attachments count] > 2) {
				//如果图片数目大于2张显示缩略图
				url =[NSURL URLWithString: ((RRAttachmentItem *)attachment).miniUrl];
			}else {
				//否则加载高清图片
				url =[NSURL URLWithString: ((RRAttachmentItem *)attachment).largeUrl];
			}
			[attachImageView setImageWithURL:url]; //从url导入图片
			[self.attachImageViews addObject:attachImageView];
			[self addSubview:attachImageView];
			TT_RELEASE_SAFELY(attachImageView);
			
		}
		tag ++;

	}
	
	[self layoutIfNeeded];
}

- (void)layoutSubviews{
	
	[super layoutSubviews];

	/*	
		布局视图大小分两种情况，1.照片数目大于等于三张,之多显示三张 2.照片数目小于三张，只显示一张图片
	 */
	if ([self.attachImageViews count] >= 3) {
	
		CGFloat photoWidth;
		CGFloat photoHeight;
		CGFloat scrollViewHeight = self.bounds.size.height - kScrollViewPhotoPaddingBottom -  kScrollViewPhotoPaddingTop;
		photoWidth = self.width / kAttachImageViewCountMax;
		photoWidth -= (kScrollViewPhotoPaddingLeft  + kScrollViewPhotoPaddingRight);
		photoHeight = scrollViewHeight;
		NSLog(@"cell中单个照片的高度=%f,宽度=%f",photoHeight,photoWidth);
		int index = 0;
		for (UIImageView *currentImageView in self.attachImageViews) {
			CGFloat currentX = kScrollViewPhotoPaddingLeft + 
				index * (kScrollViewPhotoPaddingLeft + photoWidth + kScrollViewPhotoPaddingRight);
			CGFloat currentY = kScrollViewPhotoPaddingTop;
			
			currentImageView.frame = CGRectMake(currentX, currentY, photoWidth, photoHeight);
			
			index ++;
		}
		
		//设置滚动内容的大小
		self.contentSize = CGSizeMake( [self.attachImageViews count] * 
									  (kScrollViewPhotoPaddingLeft + photoWidth + kScrollViewPhotoPaddingRight),
										self.bounds.size.height);
		
	}else if ([self.attachImageViews count] > 0) {
		CGFloat photoWidth;
		CGFloat photoHeight;
		CGFloat scrollViewHeight = self.bounds.size.height - kScrollViewPhotoPaddingBottom - kScrollViewPhotoPaddingTop;
		photoWidth = self.bounds.size.width - (kScrollViewPhotoPaddingLeft  + kScrollViewPhotoPaddingRight);
		photoHeight = scrollViewHeight;

		//只计算第一张照片
		CGFloat maxImageWidth = (self.width - kScrollViewPhotoPaddingLeft - kScrollViewPhotoPaddingRight);

		int i = 0;
		for (UIImageView *currentImageView in self.attachImageViews) {
		
			if (currentImageView.image.size.width > maxImageWidth) {
				//如果超出边界范围
				photoWidth  = maxImageWidth;
				photoHeight = currentImageView.image.size.height * photoWidth / currentImageView.image.size.width;
			}else {
				photoWidth = currentImageView.image.size.width;
				photoHeight = currentImageView.image.size.width;
			}
			NSLog(@"大照片模式下单个照片的高度=%f,宽度=%f",photoHeight,photoWidth);

			currentImageView.frame = CGRectMake(0,
												10, 
												300, 
												300);
			self.contentSize = CGSizeMake(currentImageView.frame.size.width, currentImageView.frame.size.height);
			
			i ++;
		}

	}
	
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma -mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {


}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

}

/**
 *	附件照片单击手势
 */
- (void)tapAttachImage:(UITapGestureRecognizer *)recognizer{
	for (int i = 0; i < [self.attachImageViews count]; i++) {
		NSLog(@"tag ======= %d",[recognizer view].tag);
		if ([recognizer view].tag == [[self.attachImageViews objectAtIndex:i] tag]) {
			if ([self.attachScrollViewDelgate respondsToSelector:@selector(tapAttachImageAtIndex:andAttachItem:)]) {
				[self.attachScrollViewDelgate tapAttachImageAtIndex:i 
													  andAttachItem:[self.attachments objectAtIndex:i]];
			}
		}
	}

}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
	
	return YES;
}
@end
