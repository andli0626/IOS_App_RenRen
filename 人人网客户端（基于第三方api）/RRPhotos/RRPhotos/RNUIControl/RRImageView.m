//
//  RRImageView.m
//  RRSpring
//
//  Created by yi chen on 12-3-16.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RRImageView.h"

@implementation RRImageView

@synthesize url = _url;
@synthesize imageView = _imageView;
@synthesize defaultImageView = _defaultImageView;
@synthesize engine = _engine;


- (void)dealloc{
	TT_RELEASE_SAFELY(_imageView);
	TT_RELEASE_SAFELY(_defaultImageView);
	TT_RELEASE_SAFELY(_engine);
    
	[super dealloc];
}
//初始化成员变量
- (void)initMemberVariables{
	_engine = [[MKNetworkEngine alloc]init];
	[_engine useCache]; //设置要使用缓存
    
	_imageView = [[UIImageView alloc]init ];
	_defaultImageView = [[UIImageView alloc]init ];
    
    
	[self addSubview: _defaultImageView];
	[self addSubview: _imageView];
    
	[self layoutIfNeeded];
}

- (void)layoutSubviews {
    //	self.imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    //	self.defaultImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    //	
	self.clipsToBounds = YES; //填充方式
	self.contentMode = UIViewContentModeScaleAspectFill;
    
	self.imageView.clipsToBounds = YES;//在不变形的情况下填充图片
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;  	
    
	self.defaultImageView.clipsToBounds = YES;
	self.defaultImageView.contentMode = UIViewContentModeScaleAspectFit;
    
	self.imageView.frame = self.bounds;
	self.defaultImageView.frame = self.bounds;
    
}

/**
 * 设置默认的图片
 */
- (void) setDefaultImage:(UIImage *)defaultImage{
    [_defaultImageView setImage: defaultImage];
	if (nil == _url || 0 == _url.length) { //如果URL为空，将显示默认图片
		self.imageView = _defaultImageView;
	}
}

/**
 * 初始化
 */
- (id)initWithFrame:(CGRect) frame{
	if (self = [super initWithFrame:frame]) {
		[self initMemberVariables];
	}
	return self;
}

/**
 * 加载视图
 * @url: 视图的URL地址
 * @isUseCache: 是否使用网络缓存
 */
- (void)loadImageWithUrl:(NSString *)url isUseCache:(BOOL)isUseCache
{
	if (url == nil) {
        return;
    }
    if (isUseCache) { //如果使用缓存
        [_engine useCache];
    }
    MKNetworkOperation *op = [_engine operationWithURLString:url];
    [op onCompletion:^(MKNetworkOperation *completedOperation){
        
		UIImage *netimage = [completedOperation responseImage];
		[self.imageView setImage:netimage];
		[self.imageView setNeedsLayout];
        
    }
             onError:^(NSError* error) { 
                 NSLog(@" 加载图片错误！！！error:%d",error.code);
             }];    
    
    [_engine enqueueOperation:op];
    
    [op onDownloadProgressChanged:^(double progress) {
        //实现实时监控图片下载进度，可以利用这个实现加载前的动画
        NSLog(@"syp======change===%f",progress);
    }];
}

@end