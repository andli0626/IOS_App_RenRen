//
//  RNInputViewController.h
//  RRSpring
//
//  Created by 黎 伟 ✪ on 3/6/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//  edit by 玉平 孙

#import <UIKit/UIKit.h>
#import "RNPublisherAccessoryBar.h"
#import "RNPublisherBottomBar.h"
#import "RNCommentViewController.h"
#import "RNPublishBigCommentViewController.h"
#import "RNPublishRequestProto.h"
#import "RNBaseViewController.h"
@interface RNPublisherViewController : RNBaseViewController<RNPublisherAccessoryBarDelegate,UITextViewDelegate>{
    RNPublisherAccessoryBar *_accessoryBar;
    //RNCommentViewController *_publishbigComment;
    RNPublishBigCommentViewController *_currentViewControl;
    NSMutableDictionary *_currentPrgam;
    PublisherType _publishType;
    
    id<RNPublishRequestProto> _requestDelegate;
    
}
@property (nonatomic,retain)    RNPublisherAccessoryBar *accessoryBar;
@property (nonatomic,retain)    NSMutableDictionary *currentPrgam;
@property (nonatomic,retain)    RNPublishBigCommentViewController *currentViewControl;
@property (nonatomic,assign)    id<RNPublishRequestProto> requestDelegate;
@property (nonatomic,assign)    PublisherType publishType;
-(id)initWithInfo:(NSMutableDictionary*)info;

@end
