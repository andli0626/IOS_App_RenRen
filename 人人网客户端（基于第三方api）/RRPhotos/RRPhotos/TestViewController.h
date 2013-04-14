//
//  TestViewController.h
//  RRSpring
//
//  Created by sheng siglea on 4/21/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNModelViewController.h"
@interface TestViewController : UIViewController{
    // 被访问相册的用户
    NSNumber *_userId;
    // 被访问相册id
    NSNumber *_albumId;
        RCMainUser *_mainUser;
    UIButton *button;
    RCGeneralRequestAssistant *mReqAssistant;
    
}
- (id)initWithUid:(NSNumber *)uid albumId:(NSNumber *)aid;
- (void)requestAlbumInfo;
@end
