//
//  RNEmotionMap.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-11.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNEmotionMap : NSObject{
    // 默认表情映射关系数组，
    NSMutableArray *_defaultEmotionsArray;
    // 阿狸表情映射关系数组，工程的资源文件
    NSMutableArray *_aliEmotionsArray;
    // //囧囧熊表情的  工程的资源文件
    NSMutableArray *_jjEmotionsArray;
}
@property (nonatomic, retain) NSMutableArray *defaultEmotionsArray;
@property (nonatomic, retain) NSMutableArray *aliEmotionsArray;
@property (nonatomic, retain) NSMutableArray *jjEmotionsArray;

+ (RNEmotionMap *)getInstance;
@end
