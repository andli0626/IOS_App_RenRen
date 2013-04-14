//
//  RNCommentViewController.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-30.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBigCommentViewController.h"
typedef enum {
	// 分享的类型
  	RRShareTypeNone = 0,
	RRShareTypeBlog = 1, // 用户日志
	RRShareTypePhoto = 2,// 用户照片
    RRShareTypeLink = 6,// 用户链接
	RRShareTypeAlbum = 8,// 用户相册
    RRShareTypeVideo = 10,// 用户视频
    RRShareTypeDiscovery = 11,
    RRShareTypeStatus    =12,//用户状态
    RRShareTypeBlogForPage = 20,// page日志
    RRShareTypeLinkForPage = 21,// page链接
    RRShareTypePhotoForPage = 22,//page照片
    RRShareTypeVideoForPage = 23,// page视频
    RRShareTypeAlbumForPage = 136,// page相册
} RRShareType;
@interface RNCommentViewController : RNPublishBigCommentViewController{
    NSMutableDictionary *_currentPrgam;
    RRShareType _sharetype;//分享视频还是日志。。。。。
    NSInteger pageType;//分享/收藏（0为分享，1为收藏 默认为0)
    //用于获取@权限
    RCBaseRequest *_baseRequest;
    //
    NSMutableString *atRequestMethod;
    //用于同时评论给好友
    RCPublishPost *_commentRequest;
}
@property (nonatomic,retain) NSMutableDictionary *currentPrgam;
-(id)initWithInfo:(NSMutableDictionary*)info;
@end
