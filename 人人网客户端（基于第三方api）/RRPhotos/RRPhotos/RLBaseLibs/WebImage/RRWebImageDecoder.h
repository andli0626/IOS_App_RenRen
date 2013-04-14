//
//  RRWebImageDecoder.h
//  RRSpring
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RRWebImageDecoderDelegate;

@interface RRWebImageDecoder : NSObject{
    NSOperationQueue* _imageDecodingQueue;
}
+ (RRWebImageDecoder *)sharedImageDecoder;
- (void)decodeImage:(UIImage *)image withDelegate:(id <RRWebImageDecoderDelegate>)delegate userInfo:(NSDictionary *)info;

@end

@protocol RRWebImageDecoderDelegate <NSObject>

- (void)imageDecoder:(RRWebImageDecoder *)decoder didFinishDecodingImage:(UIImage *)image userInfo:(NSDictionary *)userInfo;

@end

@interface UIImage (ForceDecode)

+ (UIImage *)decodedImageWithImage:(UIImage *)image;

@end

NS_INLINE UIImage *RRScaledImageForPath(NSString *path, NSData *imageData)
{
    if (!imageData)
    {
        return nil;
    }
    
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        CGFloat scale = 1.0;
        if (path.length >= 8)
        {
            // Search @2x. at the end of the string, before a 3 to 4 extension length (only if key len is 8 or more @2x. + 4 len ext)
            NSRange range = [path rangeOfString:@"@2x." options:0 range:NSMakeRange(path.length - 8, 5)];
            if (range.location != NSNotFound)
            {
                scale = 2.0;
            }
        }
        
        UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
        RL_RELEASE_SAFELY(image);
        image = scaledImage;
    }
    
    return [image autorelease];
}

