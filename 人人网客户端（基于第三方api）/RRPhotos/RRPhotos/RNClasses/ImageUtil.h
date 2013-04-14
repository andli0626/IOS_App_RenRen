//
//  ImageUtil.h
//  ImageProcessing
//
//  Created by yi chen on 12-3-27.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>

@interface ImageUtil : NSObject 

//改变照片的大小
+ (CGSize) fitSize: (CGSize)thisSize inSize: (CGSize) aSize;
+ (UIImage *) image: (UIImage *) image fitInSize: (CGSize) viewsize;

+ (UIImage*)blackWhite:(UIImage*)inImage;
+ (UIImage*)cartoon:(UIImage*)inImage;
+ (UIImage*)memory:(UIImage*)inImage;
+ (UIImage*)bopo:(UIImage*)inImage;
+(UIImage*)scanLine:(UIImage*)inImage;
@end
