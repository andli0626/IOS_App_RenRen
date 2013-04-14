//
//  RNPlaceEvaluationViewController.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-21.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBigCommentViewController.h"

@interface RNPlaceEvaluationViewController : RNPublishBigCommentViewController{
    NSMutableDictionary *_currentPrgam;
}
@property (nonatomic,retain) NSMutableDictionary *currentPrgam;
/*
	info:传入地点信息NSDictionary
	包括:
			place_id 
			place_name
			
 */
-(id)initWithInfo:(NSMutableDictionary*)info;

@end
