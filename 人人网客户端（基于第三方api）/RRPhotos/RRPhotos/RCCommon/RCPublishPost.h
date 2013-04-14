//
//  RCPublishPost.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-27.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCBasePost.h"

@interface RCPublishPost : RCBasePost{
    
	/**
	 *请求参数对
	 */
	NSMutableDictionary* _pair; 
    /**
	 * 照片的数据
	 * 图片文件按标准的HTTP Multipart方式传输，可按标准自行选择编码方式；此值不参与sig值运算。
	 */
	NSData* _photoData;
    
    BOOL _isPhoto;
    //如果又定位信息需要回调lbs相关功能
    BOOL _isLocation;
}
/*
 *是否只能上传图片，为了满足在发表状态的时候能转化为上传图片
 *
 */
@property(nonatomic,assign)BOOL isPhoto;
/*
 *
 */
@property(nonatomic,assign)BOOL isLocation;
/*
 *发表图片需要的数据也是判断发布状态还是上传图片的依据
 *
 */
@property(nonatomic, copy) NSData* photoData;
@property(nonatomic, retain)NSMutableDictionary *pair;
/**
 *　publish网络请求。
 *  @photoImage : 照片数据可以不传。
 *  @paramDic: 自组织必要的请求参数，共性信息可不传
 * 	@ method: api接口方法
 */
- (void)publishPostWith:(UIImage *)photoImage
               paramDic:(NSDictionary *)paramDic
             withMethod:(NSString*)method;
@end
