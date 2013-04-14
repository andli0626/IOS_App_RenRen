//
//  RLUtility.h
//  RRSpring
//
//  Created by renren-inc on 12-2-21.
//  Copyright (c) 2012年 Renn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLUtility : NSObject

+(id)convertAsacIItoUTF8Array:(NSArray*)dictionary;

+(id)convertAsacIItoUTF8:(NSDictionary*)dictionary;

/**
 截取中央方图像
 */

+ (UIImage *)getCentralSquareImage:(UIImage *)img Length:(CGFloat)length;  

@end
