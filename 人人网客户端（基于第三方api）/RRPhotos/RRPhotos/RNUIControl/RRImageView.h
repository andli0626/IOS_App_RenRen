//
//  RRImageView.h
//  RRSpring
//
//  Created by yi chen on 12-3-16.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRImageView : UIControl
{
	/**
	 *图片的URL
	 */
	NSString *_url;
    
	/**
	 *图像内容
	 */
	UIImageView *_imageView;
    
	/**
	 *默认图像内容
	 */
	UIImageView *_defaultImageView;
    
	/**
	 * MK 网络请求
	 */
	MKNetworkEngine *_engine;
    
    
}
@property(nonatomic, copy) NSString *url;

@property(nonatomic, retain) UIImageView *imageView;

@property(nonatomic, retain) UIImageView *defaultImageView;

@property(nonatomic, retain) MKNetworkEngine *engine;

/**
 * 初始化
 */
- (id)initWithFrame:(CGRect) frame;

/**
 * 加载视图
 * @url: 视图的URL地址
 * @isUseCache: 是否使用网络缓存
 */
- (void)loadImageWithUrl:(NSString *)url isUseCache:(BOOL)isUseCache;


/**
 * 设置默认图片
 */
- (void) setDefaultImage:(UIImage *)defaultImage;
@end