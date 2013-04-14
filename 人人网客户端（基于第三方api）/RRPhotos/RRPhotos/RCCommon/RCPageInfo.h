//
//  RCPageInfo.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-20.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCPageInfo : NSObject<NSCoding>{
    NSNumber *_pageId;        //id信息
    NSNumber *_fansNumber;    // page的粉丝数
	NSString *_pageName;      //名称
    NSString *_classiFication;//page分类
	NSNumber *_thepageChecked;//当前公共主页是否通过实名认证，0表示不是，1表示是通过官方认证，2表示热门主页
	NSString *_headUrl;       //头像地址
    NSString *_desc;          //公共主页简介
    NSNumber *_isFan;         //当前用户是否是粉丝，1表示是，0表示不是
}
@property (nonatomic,copy)NSNumber *pageId;
@property (nonatomic,copy)NSNumber *fansNumber;
@property (nonatomic,copy)NSString *pageName;
@property (nonatomic,copy)NSString *classiFication;
@property (nonatomic,copy)NSNumber *thepageChecked;
@property (nonatomic,copy)NSString *headUrl;
@property (nonatomic,copy)NSString *desc;
@property (nonatomic,copy)NSNumber *isFan;
/**
 * 根据接口(Page.getList)返回的page信息字典数据填充完整page信息.
 *
 * @param dictionary page信息字典.
 */
- (id)initWithDictionary:(NSDictionary*) dictionary;
/**
 * 返回一个page的字典信息
 */
- (NSDictionary*)encodeWithDictionary;


@end
