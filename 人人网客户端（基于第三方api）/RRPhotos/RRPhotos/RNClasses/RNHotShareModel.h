//
//  RNHotShareModel.h
//  RRPhotos
//
//  Created by yi chen on 12-5-11.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RNModel.h"

#define kHotSharePhotoCountMax 20 //热门分享取得的照片数目


/*	-----------------------------------  */
/*		热门分享网络加载模型		 */
/*	-----------------------------------  */
@interface RNHotShareModel : RNModel
{
	//热门分享的数据
	NSMutableArray *_hotShareItems;
}
@property(nonatomic,retain)NSMutableArray *hotShareItems;
/*
	热门分享
 
	typeString:新鲜事RRNewsfeedType，多个类型以逗号隔开
 */
- (id)initWithTypeString:(NSString *)typeString;
@end
