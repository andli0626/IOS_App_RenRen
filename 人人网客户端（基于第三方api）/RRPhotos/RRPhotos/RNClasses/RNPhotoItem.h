//
//  RNPhotoItem.h
//  RRSpring
//
//  Created by sheng siglea on 4/5/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RNPhotoLbsItem;

/*
 建议需要使用其他属性的童鞋，继续扩展
 */
@interface RNPhotoItem : NSObject{
    
    NSNumber *_albumId;
    NSString *_albumName;
    NSString *_caption;
    NSInteger _commentCount;
    NSNumber *_pid;
    NSString *_imgHead;
    NSString *_imgLarge;
    CGFloat _imgLargeHeight;
    CGFloat _imgLargeWidth;
    NSString *_imgMain;
    NSString *_imgOrigin;
    CGFloat _imgOriginHeight;
    CGFloat _imgOriginWidth;
    NSTimeInterval _time;
    NSNumber *_userId;
    NSString *_userName;
    NSInteger _viewCount;
    RNPhotoLbsItem *_lbsItem;
    
}

@property(nonatomic,copy) NSNumber *albumId;
@property(nonatomic,copy) NSString *albumName;
@property(nonatomic,copy) NSString *caption;
@property(nonatomic,assign) NSInteger commentCount;
@property(nonatomic,copy) NSNumber *pid;
@property(nonatomic,copy) NSString *imgHead;
@property(nonatomic,copy) NSString *imgLarge;
@property(nonatomic,assign) CGFloat imgLargeHeight;
@property(nonatomic,assign) CGFloat imgLargeWidth;
@property(nonatomic,copy) NSString *imgMain;
@property(nonatomic,copy) NSString *imgOrigin;
@property(nonatomic,assign) CGFloat imgOriginHeight;
@property(nonatomic,assign) CGFloat imgOriginWidth;
@property(nonatomic,assign) NSTimeInterval time;
@property(nonatomic,copy) NSNumber *userId;
@property(nonatomic,copy) NSString *userName;
@property(nonatomic,assign) NSInteger viewCount;
@property(nonatomic,retain) RNPhotoLbsItem *lbsItem;

- (id)initWithDictionary:(NSDictionary *)dict;
@end

@interface RNPhotoLbsItem : NSObject{
    long long _lbsId;
    NSString *_lbsPid;
    NSString *_pname;
    NSString *_location;
    long long _longitude;
    long long _latitude;
}
@property(nonatomic,assign) long long lbsId;
@property(nonatomic,copy)  NSString *lbsPid;
@property(nonatomic,copy)  NSString *pname;
@property(nonatomic,copy)  NSString *location;
@property(nonatomic,assign) long long longitude;
@property(nonatomic,assign) long long latitude;

- (id)initWithDictionary:(NSDictionary *)dict;
@end

/*
 "album_name" = bbbb;
 count = 185;
 "photo_list" =     (
 {
 "album_id" = 587674045;
 "album_name" = bbbb;
 caption = "";
 "comment_count" = 0;
 id = 5741075722;
 "img_head" = "http://fmn.rrfmn.com/fmn058/20120329/1505/head_qcWN_6a350000022f125f.jpg";
 "img_large" = "http://fmn.rrfmn.com/fmn058/20120329/1505/large_qcWN_6a350000022f125f.jpg";
 "img_large_height" = 540;
 "img_large_width" = 720;
 "img_main" = "http://fmn.rrfmn.com/fmn058/20120329/1505/main_qcWN_6a350000022f125f.jpg";
 "img_origin" = "http://fmn.rrfmn.com/fmn058/20120329/1505/original_qcWN_6a350000022f125f.jpg";
 "img_origin_height" = 600;
 "img_origin_width" = 800;
 time = 1333004962000;
 "user_id" = 439643362;
 "user_name" = "\U6c88\U519b\U8230";
 "view_count" = 0;
 }, 
 place 	object 	表示照片附带的地理位置信息 	
 id 	long 	表示照片附带的地理位置信息的LbsId 	place子节点
 pid 	string 	表示照片附带的地理位置信息的PID 	place子节点
 pname 	string 	表示照片附带的地理位置信息的名称 	place子节点
 location 	string 	表示照片附带的地理位置信息的地址 	place子节点
 longitude 	long 	表示照片附带的地理位置信息的经度 	place子节点
 latitude 	long 	表示照片附带的地理位置信息的纬度
 
 */
