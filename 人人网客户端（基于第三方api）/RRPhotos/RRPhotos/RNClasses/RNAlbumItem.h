//
//  RNAlbumItem.h
//  RRSpring
//
//  Created by sheng siglea on 4/11/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAlbumHasPassword 1

/*
//album_type 	0：普通相册 1：手机相册 2：快速上传 3：头像相册 
 */
typedef enum AlbumType {
    AlbumTypeNormal = 0,
    AlbumTypePhone = 1,
    AlbumTypeQuickUpload = 2,
    AlbumTypeHead = 3,
    AlbumTypeUnknown
    
}AlbumType;

//visible 	权限范围,有4个int值: 99(所有人),3(同城),1(好友), -1(仅自己可见) 	
typedef enum AlbumVisible {
    AlbumVisibleAll = 99,
    AlbumVisibleOneCity = 3,
    AlbumVisibleFriend = 1,
    AlbumVisibleSelf = -1,
    AlbumVisibleUnknown
}AlbumVisible;


@interface RNAlbumItem : NSObject{
    AlbumType _albumType;
    NSInteger _commentCount;
    long long _createTime;
    NSString *_description;
    BOOL _hasPassword;
    NSNumber *_aid;
    NSString *_img;
    NSString *_largeImg;
    NSString *_location;
    NSString *_mainImg;
    NSInteger _size;
    NSString *_title;
    long long _uploadTime;
    NSNumber *_uid;
    AlbumVisible _visible;
}

@property(nonatomic,assign) AlbumType albumType;
@property(nonatomic,assign) NSInteger commentCount;
@property(nonatomic,assign) long long createTime;
@property(nonatomic,copy) NSString *description;
@property(nonatomic,assign) BOOL hasPassword;
@property(nonatomic,copy) NSNumber *aid;
@property(nonatomic,copy) NSString *img;
@property(nonatomic,copy) NSString *largeImg;
@property(nonatomic,copy) NSString *location;
@property(nonatomic,copy) NSString *mainImg;
@property(nonatomic,assign) NSInteger size;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,assign) long long uploadTime;
@property(nonatomic,copy) NSNumber *uid;
@property(nonatomic,assign) AlbumVisible visible;


- (id)initWithDictionary:(NSDictionary *)dict;
@end
/*
 
 ==========相册
 
 {
 "album_type" = 3;
 "comment_count" = 0;
 "create_time" = 1327224652000;
 description = "";
 "has_password" = 0;
 id = 562522177;
 img = "http://hdn.xnimg.cn/photos/hdn221/20120329/1825/h_head_yRLY_30240000e34c2f76.jpg";
 "large_img" = "http://hdn.xnimg.cn/photos/hdn221/20120329/1825/h_large_omK0_30240000e34c2f76.jpg";
 location = "";
 "main_img" = "http://hdn.xnimg.cn/photos/hdn221/20120329/1825/h_main_lSqY_30240000e34c2f76.jpg";
 size = 4;
 title = "\U5934\U50cf\U76f8\U518c";
 "upload_time" = 1327224652000;
 "user_id" = 439643362;
 visible = 99;
 }
 );
 count = 25;
 */

