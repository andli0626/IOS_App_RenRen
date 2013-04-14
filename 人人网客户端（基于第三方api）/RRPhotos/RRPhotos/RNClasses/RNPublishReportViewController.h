//
//  RNPublishReportViewController.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-19.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBigCommentViewController.h"

@interface RNPublishReportViewController : RNPublishBigCommentViewController{
    NSMutableDictionary *_currentPrgam;
}
@property (nonatomic,retain) NSMutableDictionary *currentPrgam;
-(id)initWithInfo:(NSMutableDictionary*)info;
@end
