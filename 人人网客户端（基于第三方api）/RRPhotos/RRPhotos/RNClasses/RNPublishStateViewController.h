//
//  RNPublishStateViewController.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-12.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBigCommentViewController.h"

@interface RNPublishStateViewController : RNPublishBigCommentViewController{
    NSMutableDictionary *_currentPrgam;
}
@property (nonatomic,retain) NSMutableDictionary *currentPrgam;
@end
