//
//  RRWebImageDecoder.m
//  RRSpring
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RRWebImageDecoder.h"

#define DECOMPRESSED_IMAGE_KEY @"decompressedImage"
#define DECODE_INFO_KEY @"decodeInfo"

#define IMAGE_KEY @"image"
#define DELEGATE_KEY @"delegate"
#define USER_INFO_KEY @"userInfo"

@implementation RRWebImageDecoder

static RRWebImageDecoder* sharedInstance;

- (void)notifyDelegateOnMainThreadWithInfo:(NSDictionary *)dict
{
    [dict retain];
    NSDictionary *decodeInfo = [dict objectForKey:DECODE_INFO_KEY];
    UIImage *decodedImage = [dict objectForKey:DECOMPRESSED_IMAGE_KEY];
    
    id <RRWebImageDecoderDelegate> delegate = [decodeInfo objectForKey:DELEGATE_KEY];
    NSDictionary *userInfo = [decodeInfo objectForKey:USER_INFO_KEY];
    
    [delegate imageDecoder:self didFinishDecodingImage:decodedImage userInfo:userInfo];
    [dict release];
}

- (void)decodeImageWithInfo:(NSDictionary *)decodeInfo
{
    UIImage *image = [decodeInfo objectForKey:IMAGE_KEY];
    
    UIImage *decompressedImage = [UIImage decodedImageWithImage:image];
    if (!decompressedImage)
    {
        // If really have any error occurs, we use the original image at this moment
        decompressedImage = image;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          decompressedImage, DECOMPRESSED_IMAGE_KEY,
                          decodeInfo, DECODE_INFO_KEY, nil];
    
    [self performSelectorOnMainThread:@selector(notifyDelegateOnMainThreadWithInfo:) withObject:dict waitUntilDone:NO];
}

- (id)init
{
    if ((self = [super init]))
    {
        // Initialization code here.
        _imageDecodingQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

- (void)decodeImage:(UIImage *)image withDelegate:(id<RRWebImageDecoderDelegate>)delegate userInfo:(NSDictionary *)info
{
    NSDictionary *decodeInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                image, IMAGE_KEY,
                                delegate, DELEGATE_KEY,
                                info, USER_INFO_KEY, nil];
    
    NSOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(decodeImageWithInfo:) object:decodeInfo];
    [_imageDecodingQueue addOperation:operation];
    [operation release];
}

- (void)dealloc
{
    RL_RELEASE_SAFELY(_imageDecodingQueue);
    [super dealloc];
}

+ (RRWebImageDecoder *)sharedImageDecoder
{
    if (!sharedInstance)
    {
        sharedInstance = [[RRWebImageDecoder alloc] init];
    }
    return sharedInstance;
}

@end


@implementation UIImage (ForceDecode)

+ (UIImage *)decodedImageWithImage:(UIImage *)image
{
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 CGImageGetWidth(imageRef),
                                                 CGImageGetHeight(imageRef),
                                                 8,
                                                 // Just always return width * 4 will be enough
                                                 CGImageGetWidth(imageRef) * 4,
                                                 // System only supports RGB, set explicitly
                                                 colorSpace,
                                                 // Makes system don't need to do extra conversion when displayed.
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little); 
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;
    
    CGRect rect = (CGRect){CGPointZero, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)};
    CGContextDrawImage(context, rect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *decompressedImage = [[[UIImage alloc] initWithCGImage:decompressedImageRef] autorelease];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

@end
