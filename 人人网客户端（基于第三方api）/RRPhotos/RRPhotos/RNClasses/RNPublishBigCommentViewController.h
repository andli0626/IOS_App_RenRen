//
//  RNPublishBigCommentViewController.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-26.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNPublisherBottomBar.h"
#import "RNBaseViewController.h"
#import "RRUIImageView.h"
#import "RCPublishPost.h"
#import "RNPublisherAccessoryBar.h"
#import "RNPublishRequestProto.h"
#import "AppDelegate.h"
#import "NSString+NSStringEx.h"
#import "RNFastAtFriendView.h"

@interface RNPublishBigCommentViewController : RNBaseViewController<UITextViewDelegate,RNPublisherBottomBtnDelegate,RNPublisherAccessoryBarDelegate,UIActionSheetDelegate,RNEditPhotoFinishDelegate,RNFastAtFriendViewDelegate>{
    UITextView *_contentView;
    RNPublisherBottomBar *_bottombar;
    UIButton *_photo;
    RCPublishPost *_publishPost;
    id<RNPublishRequestProto> _requestDelegate;
    UIViewController *_parentControl;
    RNFastAtFriendView *_fasrAtview;
}
@property (nonatomic, retain)  UITextView *contentView;
@property (nonatomic, retain)  UIButton *photo;
@property (nonatomic, assign)  RNPublisherBottomBar *bottombar;
@property (nonatomic, retain)  RCPublishPost *publishPost;
@property (nonatomic, assign)  id<RNPublishRequestProto> requestDelegate;
@property (nonatomic, assign)  UIViewController *parentControl;
/*
 *初始化publish
 *@pram：userId 用户di信息
 */
-(id)initWithUserID:(NSNumber*)userId;
-(void)setSelectPhoto:(UIImage*)imagedata;

/**
 *　publish网络请求。
 *  @photoImage : 照片数据可以不传。
 *  @paramDic: 自组织必要的请求参数，共性信息可不传
 * 	@ method: api接口方法
 */
- (void)publishPostWith:(UIImage *)photoImage
               paramDic:(NSDictionary *)paramDic
             withMethod:(NSString*)method;

//内部弹出错误提示框
-(void)showAlertWithMsg:(NSString*)msg;

@end
