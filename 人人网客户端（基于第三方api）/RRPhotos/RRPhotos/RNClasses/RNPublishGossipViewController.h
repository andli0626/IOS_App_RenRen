//
//  RNPublishGossipViewController.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-21.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBigCommentViewController.h"

@interface RNPublishGossipViewController : RNPublishBigCommentViewController  {
    NSMutableDictionary *_currentPrgam;
}
@property (nonatomic,retain) NSMutableDictionary *currentPrgam;
-(id)initWithInfo:(NSMutableDictionary*)info;

@end
