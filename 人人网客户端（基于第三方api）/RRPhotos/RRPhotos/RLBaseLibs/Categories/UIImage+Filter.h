//
//  UIImage+Filter.h
//  Cngram
//
//  Created by Chen Changneng on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef struct {
    unsigned char b[256];
    unsigned char g[256];
    unsigned char r[256];
} Curve;
@interface UIImage (Filter)

#pragma mark Base Method
- (CGContextRef) ImageToContex: (UIImage *) image;
- (UIImage *) ContexToImage: (CGContextRef) contex;

#pragma mark Core Method
- (UIImage *) applyBlend:(UIImage *) image Callback: (void (^)(unsigned char *, unsigned char *)) fn;
- (UIImage *) applyCurve:(Curve) curve;
- (UIImage *) applyFilter: (void (^)(unsigned char * )) fn;

#pragma mark Blend Effect
- (UIImage *) screen: (UIImage *) image ratio: (double) ratio;
- (UIImage *) overlay: (UIImage *) image ratio: (double) ratio;
- (UIImage *) overlay: (UIImage *) image ratio: (double) ratio channel: (int) channel;
- (UIImage *) multiply: (UIImage *) image ratio: (double) ratio;
- (UIImage *) lighten: (UIImage *) image ratio: (double) ratio;
- (UIImage *) linearDodge: (UIImage *) image ratio: (double) ratio;
- (UIImage *) mask: (UIImage *) image;

#pragma mark Common Effect
- (UIImage *) ink;
@end
