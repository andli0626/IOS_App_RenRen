//
//  RNEmotionMap.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-11.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNEmotionMap.h"
static RNEmotionMap *_instance = nil;
@implementation RNEmotionMap
@synthesize defaultEmotionsArray = _defaultEmotionsArray;
@synthesize aliEmotionsArray = _aliEmotionsArray;
@synthesize jjEmotionsArray = _jjEmotionsArray;

+ (RNEmotionMap *)getInstance{
    @synchronized(self){
        if (_instance == nil) {
            _instance = [[RNEmotionMap alloc] init];
        }
    }        
    return _instance;
}
@end
