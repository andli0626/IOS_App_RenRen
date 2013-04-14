//
//  RCPageitem.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-1.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPageInfo.h"
@interface RCPageitem : RCPageInfo{
    BOOL _isSelected;
}

@property (nonatomic,assign)BOOL isSelected;
-(id)initWithDicInfo:(NSDictionary *)pageDic;
+(id)itemWithDicInfo:(NSDictionary *)pageDic;

@end
