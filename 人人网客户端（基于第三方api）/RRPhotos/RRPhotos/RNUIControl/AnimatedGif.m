//
//  AnimatedGif.m
//
//  Created by Stijn Spijker (http://www.stijnspijker.nl/) on 2009-07-03.
//  Based on gifdecode written april 2009 by Martin van Spanje, P-Edge media.
//  
//  Changes on gifdecode:
//  - Small optimizations (mainly arrays)
//  - Object Orientated Approach (Class Methods as well as Object Methods)
//  - Added the Graphic Control Extension Frame for transparancy
//  - Changed header to GIF89a
//  - Added methods for ease-of-use
//  - Added animations with transparancy
//  - No need to save frames to the filesystem anymore
//
//  Changelog:
//
//	2010-03-16: Added queing mechanism for static class use
//  2010-01-24: Rework of the entire module, adding static methods, better memory management and URL asynchronous loading
//  2009-10-08: Added dealloc method, and removed leaks, by Pedro Silva
//  2009-08-10: Fixed double release for array, by Christian Garbers
//  2009-06-05: Initial Version
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//  

#import "AnimatedGif.h"

@implementation RNanimatedGifQueueObject

@synthesize uiv;
@synthesize url;

@end


@implementation RNanimatedGifFrame

@synthesize data, delay, disposalMethod, area, header;

- (void) dealloc
{
	[data release];
	[header release];
	[super dealloc];
}

@end
@implementation AnimatedGif

static AnimatedGif * instance;

@synthesize imageView;
@synthesize busyDecoding;

+ (AnimatedGif *) sharedInstance
{
    if (instance == nil)
    {
        instance = [[AnimatedGif alloc] init];
    }
    
    return instance;
}

+ (UIImageView *) getAnimationForGifAtUrl:(NSURL *)animationUrl
{   
    
    RNanimatedGifQueueObject *agqo = [[RNanimatedGifQueueObject alloc] init];
    [agqo setUiv: [[UIImageView alloc] init]]; // 2x retain, alloc and the property.
    [[agqo uiv] autorelease]; // We expect the user to retain the return object.
    [agqo setUrl: animationUrl]; // this object is only retained by the queueobject, which will be released when loading finishes
    [[AnimatedGif sharedInstance] addToQueue: agqo];
    [agqo release];
    

        // Asynchronous loading for URL's, else the GUI won't appear until image is loaded.
       // [[AnimatedGif sharedInstance] performSelector:@selector(asynchronousLoading) withObject:nil afterDelay:0.0];
    if ([AnimatedGif sharedInstance].busyDecoding != YES) {
        [NSThread detachNewThreadSelector:@selector(asynchronousLoading) toTarget:[AnimatedGif sharedInstance] withObject:nil];
    }
    return [agqo uiv];
}
-(void)updateGif:(UIImageView*)tmpimageview{
    [imageView setImage: [tmpimageview image]];
    [imageView sizeToFit];
    [imageView setAnimationImages: [tmpimageview animationImages]];
    [imageView startAnimating];
    
    if ([imageQueue count] > 0) {
        [NSThread detachNewThreadSelector:@selector(asynchronousLoading) toTarget:[AnimatedGif sharedInstance] withObject:nil];
    }else {
        busyDecoding = NO;
    }
}
- (void) asynchronousLoading
{
    // While we have something in queue.
    busyDecoding = YES;
    UIImageView *tempImageView =nil;
    if([imageQueue count] > 0){
        NSData *data = [NSData dataWithContentsOfURL: [(RNanimatedGifQueueObject *) [imageQueue objectAtIndex: 0] url]];
        imageView = [[imageQueue objectAtIndex: 0] uiv];
    	[self decodeGIF: data];
        tempImageView = [self getAnimation];
        [imageQueue removeObjectAtIndex:0];
    }
    [self performSelectorOnMainThread:@selector(updateGif:) withObject:tempImageView waitUntilDone:NO];
/*	while ([imageQueue count] > 0)
    {
    	NSData *data = [NSData dataWithContentsOfURL: [(RNanimatedGifQueueObject *) [imageQueue objectAtIndex: 0] url]];
        imageView = [[imageQueue objectAtIndex: 0] uiv];
    	[self decodeGIF: data];
   	 	UIImageView *tempImageView = [self getAnimation];
   	 	[imageView setImage: [tempImageView image]];
    	[imageView sizeToFit];
    	[imageView setAnimationImages: [tempImageView animationImages]];
    	[imageView startAnimating];
        
        [imageQueue removeObjectAtIndex:0];
    }
    
    busyDecoding = NO;*/
}

- (void) addToQueue: (RNanimatedGifQueueObject *) agqo
{
    [imageQueue addObject: agqo];
}

- (id) init
{
    if (self = [super init])
    {
        imageQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

// the decoder
// decodes GIF image data into separate frames
// based on the Wikipedia Documentation at:
//
// http://en.wikipedia.org/wiki/Graphics_Interchange_Format#Example_.gif_file
// http://en.wikipedia.org/wiki/Graphics_Interchange_Format#Animated_.gif
//
- (void)decodeGIF:(NSData *)GIFData
{
	GIF_pointer = GIFData;
    
    if (GIF_buffer != nil)
    {
        [GIF_buffer release];
    }
    
    if (GIF_global != nil)
    {
        [GIF_global release];
    }
    
    if (GIF_screen != nil)
    {
        [GIF_screen release];
    }
        
	if (GIF_delays != nil)
    {
        [GIF_delays release];
    }
    
    if (GIF_framesData != nil)
    {
        [GIF_framesData release];
    }
    if (GIF_framesarea != nil) {
        [GIF_framesarea release];
    }
        
    GIF_buffer = [[NSMutableData alloc] init];
	GIF_global = [[NSMutableData alloc] init];
	GIF_screen = [[NSMutableData alloc] init];
	GIF_frameHeader = nil;
    
	GIF_delays = [[NSMutableArray alloc] init];
	GIF_framesData = [[NSMutableArray alloc] init];
	GIF_framesarea = [[NSMutableArray alloc] init];
    // Reset file counters to 0
	dataPointer = 0;
	
	[self GIFSkipBytes: 6]; // GIF89a, throw away
	[self GIFGetBytes: 7]; // Logical Screen Descriptor
	
    // Deep copy
	[GIF_screen setData: GIF_buffer];
	
    // Copy the read bytes into a local buffer on the stack
    // For easy byte access in the following lines.
    int length = [GIF_buffer length];
	unsigned char aBuffer[length];
	[GIF_buffer getBytes:aBuffer length:length];
	
	if (aBuffer[4] & 0x80) GIF_colorF = 1; else GIF_colorF = 0; 
	if (aBuffer[4] & 0x08) GIF_sorted = 1; else GIF_sorted = 0;
	GIF_colorC = (aBuffer[4] & 0x07);
	GIF_colorS = 2 << GIF_colorC;
	
	if (GIF_colorF == 1)
    {
		[self GIFGetBytes: (3 * GIF_colorS)];
        
        // Deep copy
		[GIF_global setData:GIF_buffer];
	}
	
	unsigned char bBuffer[1];
	while ([self GIFGetBytes:1] == YES)
    {
        [GIF_buffer getBytes:bBuffer length:1];
        
        if (bBuffer[0] == 0x3B)
        { // This is the end
            break;
        }
        
        switch (bBuffer[0])
        {
            case 0x21:
                // Graphic Control Extension (#n of n)
                [self GIFReadExtensions];
                break;
            case 0x2C:
                // Image Descriptor (#n of n)
                [self GIFReadDescriptor];
                break;
        }
	}
	
	// clean up stuff
	[GIF_buffer release];
    GIF_buffer = nil;
    
	[GIF_screen release];
    GIF_screen = nil;
        
	[GIF_global release];	
    GIF_global = nil;
}

// 
// Returns a subframe as NSMutableData.
// Returns nil when frame does not exist.
//
// Use this to write a subframe to the filesystems (cache etc);
- (NSMutableData*) getFrameAsDataAtIndex:(int)index
{
	if (index < [GIF_framesData count])
	{
		return [GIF_framesData objectAtIndex:index];
	}
	else
	{
		return nil;
	}
}

// 
// Returns a subframe as an autorelease UIImage.
// Returns nil when frame does not exist.
//
// Use this to put a subframe on your GUI.
- (UIImage*) getFrameAsImageAtIndex:(int)index
{
    NSData *frameData = [self getFrameAsDataAtIndex: index];
    UIImage *image = nil;
    
    if (frameData != nil)
    {
		image = [UIImage imageWithData:frameData];
    }
    
    return image;
}

//
// This method converts the arrays of GIF data to an animation, counting
// up all the seperate frame delays, and setting that to the total duration
// since the iPhone Cocoa framework does not allow you to set per frame
// delays.
//
// Returns nil when there are no frames present in the GIF, or
// an autorelease UIImageView* with the animation.
- (UIImageView*) getAnimation
{
	if ([GIF_frames count] > 0)
	{
        if (imageView != nil)
        {
            // This sets up the frame etc for the UIImageView by using the first frame.
            [imageView setImage:[self getFrameAsImageAtIndex:0]];
            [imageView sizeToFit];
        }
        else
        {
            imageView = [[UIImageView alloc] initWithImage:[self getFrameAsImageAtIndex:0]];
        }
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < [GIF_frames count]; i++)
        {		
            [array addObject: [self getFrameAsImageAtIndex:i]];
        }
        
        NSMutableArray *overlayArray = [[NSMutableArray alloc] init];
        UIImage *firstImage = [array objectAtIndex:0];
        CGSize size = firstImage.size;
        CGRect rect = CGRectZero;
        rect.size = size;
        
        UIGraphicsBeginImageContext(size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        int i = 0;
        for (UIImage *image in array)
        {
            RNanimatedGifFrame *frame = [GIF_frames objectAtIndex:i];
            
            // Initialize Flag
            UIImage *previousCanvas = nil;
            
            // Save Context
            CGContextSaveGState(ctx);
            // Change CTM
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CGContextTranslateCTM(ctx, 0.0, -size.height);
            
            // Check if lastFrame exists
            CGRect clipRect;
            
            // Disposal Method (Operations before draw frame)
            switch (frame.disposalMethod)
            {
                case 1: // Do not dispose (draw over context)
                    // Create Rect (y inverted) to clipping
                    clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
                    // Clip Context
                    CGContextClipToRect(ctx, clipRect);
                    break;
                case 2: // Restore to background the rect when the actual frame will go to be drawed
                    // Create Rect (y inverted) to clipping
                    clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
                    // Clip Context
                    CGContextClipToRect(ctx, clipRect);
                    break;
                case 3: // Restore to Previous
                    // Get Canvas
                    previousCanvas = UIGraphicsGetImageFromCurrentImageContext();
                    
                    // Create Rect (y inverted) to clipping
                    clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
                    // Clip Context
                    CGContextClipToRect(ctx, clipRect);
                    break;
            }
            
            // Draw Actual Frame
            CGContextDrawImage(ctx, rect, image.CGImage);
            // Restore State
            CGContextRestoreGState(ctx);
            
            //delay must larger than 0, the minimum delay in firefox is 10.
            if (frame.delay <= 0) {
                frame.delay = 10;
            }
            [overlayArray addObject:UIGraphicsGetImageFromCurrentImageContext()];
            
            
            // Disposal Method (Operations afte draw frame)
           
            switch (frame.disposalMethod)
            {
                case 2: // Restore to background color the zone of the actual frame
                    // Save Context
                    CGContextSaveGState(ctx);
                    // Change CTM
                    CGContextScaleCTM(ctx, 1.0, -1.0);
                    CGContextTranslateCTM(ctx, 0.0, -size.height);
                    // Clear Context
                    CGContextClearRect(ctx, clipRect);
                    // Restore Context
                    CGContextRestoreGState(ctx);
                    break;
                case 3: // Restore to Previous Canvas
                    // Save Context
                    CGContextSaveGState(ctx);
                    // Change CTM
                    CGContextScaleCTM(ctx, 1.0, -1.0);
                    CGContextTranslateCTM(ctx, 0.0, -size.height);
                    // Clear Context
                    CGContextClearRect(ctx, frame.area);
                    // Draw previous frame
                    CGContextDrawImage(ctx, rect, previousCanvas.CGImage);
                    // Restore State
                    CGContextRestoreGState(ctx);
                    break;
            }
            
            // Increment counter
            i++;
        }
        UIGraphicsEndImageContext();
        
        //[imageView setImage:[overlayArray objectAtIndex:0]];
		[imageView setAnimationImages:overlayArray];
        [overlayArray release];
        [array release];
		
		// Count up the total delay, since Cocoa doesn't do per frame delays.
		double total = 0;
        for (RNanimatedGifFrame *frame in GIF_frames) {
            total += frame.delay;
        }
		
		// GIFs store the delays as 1/100th of a second,
        // UIImageViews want it in seconds.
		[imageView setAnimationDuration:total/100];
		
		// Repeat infinite
		[imageView setAnimationRepeatCount:0];
		
        [imageView startAnimating];
        [imageView autorelease];
        
		return imageView;
	}
	else
	{
		return nil;
	}
}

- (void)GIFReadExtensions
{
	// 21! But we still could have an Application Extension,
	// so we want to check for the full signature.
	unsigned char cur[1], prev[1];
    [self GIFGetBytes:1];
    [GIF_buffer getBytes:cur length:1];
    
	while (cur[0] != 0x00)
    {
		
		// TODO: Known bug, the sequence F9 04 could occur in the Application Extension, we
		//       should check whether this combo follows directly after the 21.
		if (cur[0] == 0x04 && prev[0] == 0xF9)
		{
			[self GIFGetBytes:5];
            
            RNanimatedGifFrame *frame = [[RNanimatedGifFrame alloc] init];
            
			unsigned char buffer[5];
			[GIF_buffer getBytes:buffer length:5];
			// We save the delays for easy access.
            frame.delay = buffer[1] | buffer[2] << 8;
			frame.disposalMethod = (buffer[0] & 0x1c) >> 2;
            
	
            unsigned char board[8];
            board[0] = 0x21;
            board[1] = 0xF9;
            board[2] = 0x04;
            
            for(int i = 3, a = 0; a < 5; i++, a++)
            {
                board[i] = buffer[a];
            }
            
            frame.header = [NSMutableData dataWithBytes:board length:8];
			
            [GIF_frames addObject:frame];
			[frame release];
			break;
		}
		
		prev[0] = cur[0];
        [self GIFGetBytes:1];
		[GIF_buffer getBytes:cur length:1];
	}	
}

- (void) GIFReadDescriptor
{	
	[self GIFGetBytes:9];
    
    // Deep copy
	NSMutableData *GIF_screenTmp = [NSMutableData dataWithData:GIF_buffer];
	
	unsigned char aBuffer[9];
	[GIF_buffer getBytes:aBuffer length:9];
	
	CGRect rect;
	rect.origin.x = ((int)aBuffer[1] << 8) | aBuffer[0];
	rect.origin.y = ((int)aBuffer[3] << 8) | aBuffer[2];
	rect.size.width = ((int)aBuffer[5] << 8) | aBuffer[4];
	rect.size.height = ((int)aBuffer[7] << 8) | aBuffer[6];
    
	RNanimatedGifFrame *frame = [GIF_frames lastObject];
	frame.area = rect;
    
    
	if (aBuffer[8] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
	
	unsigned char GIF_code = GIF_colorC, GIF_sort = GIF_sorted;
	
	if (GIF_colorF == 1)
    {
		GIF_code = (aBuffer[8] & 0x07);
        
		if (aBuffer[8] & 0x20)
        {
            GIF_sort = 1;
        }
        else
        {
        	GIF_sort = 0;
        }
	}
	
	int GIF_size = (2 << GIF_code);
	
	size_t blength = [GIF_screen length];
	unsigned char bBuffer[blength];
	[GIF_screen getBytes:bBuffer length:blength];
	
	bBuffer[4] = (bBuffer[4] & 0x70);
	bBuffer[4] = (bBuffer[4] | 0x80);
	bBuffer[4] = (bBuffer[4] | GIF_code);
	
	if (GIF_sort)
    {
		bBuffer[4] |= 0x08;
	}
	
    NSMutableData *GIF_string = [NSMutableData dataWithData:[[NSString stringWithString:@"GIF89a"] dataUsingEncoding: NSUTF8StringEncoding]];
	[GIF_screen setData:[NSData dataWithBytes:bBuffer length:blength]];
    [GIF_string appendData: GIF_screen];
	
	
	if (GIF_colorF == 1)
    {
		[self GIFGetBytes:(3 * GIF_size)];
        [GIF_string appendData: GIF_buffer];
	}
    else
    {
        
		[GIF_string appendData: GIF_global];
	}
	
	// Add Graphic Control Extension Frame (for transparancy)
	[GIF_string appendData:GIF_frameHeader];
	
	char endC = 0x2c;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	size_t clength = [GIF_screenTmp length];
	unsigned char cBuffer[clength];
	[GIF_screenTmp getBytes:cBuffer length:clength];
	
	cBuffer[8] &= 0x40;
	
	[GIF_screenTmp setData:[NSData dataWithBytes:cBuffer length:clength]];
	
	[GIF_string appendData: GIF_screenTmp];
	[self GIFGetBytes:1];
	[GIF_string appendData: GIF_buffer];
	
	while (true)
    {
		[self GIFGetBytes:1];
		[GIF_string appendData: GIF_buffer];
		
		unsigned char dBuffer[1];
		[GIF_buffer getBytes:dBuffer length:1];
		
		long u = (long) dBuffer[0];
        
		if (u != 0x00)
        {
			[self GIFGetBytes:u];
			[GIF_string appendData: GIF_buffer];
        }
        else
        {
            break;
        }

	}
	
	endC = 0x3b;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	// save the frame into the array of frames
	[GIF_framesData addObject:[GIF_string copy]];
}

/* Puts (int) length into the GIF_buffer from file, returns whether read was succesfull */
- (bool) GIFGetBytes: (int) length
{
    if (GIF_buffer != nil)
    {
        [GIF_buffer release]; // Release old buffer
        GIF_buffer = nil;
    }
    
	if ([GIF_pointer length] >= dataPointer + length) // Don't read across the edge of the file..
    {
		//GIF_buffer = [[GIF_pointer subdataWithRange:NSMakeRange(dataPointer, length)] retain];
        GIF_buffer = [NSMutableData alloc];
        [GIF_buffer setData:[GIF_pointer subdataWithRange:NSMakeRange(dataPointer, length)]];
        dataPointer += length;
		return YES;
	}
    else
    {
        return NO;
	}
}

/* Skips (int) length bytes in the GIF, faster than reading them and throwing them away.. */
- (bool) GIFSkipBytes: (int) length
{
    if ([GIF_pointer length] >= dataPointer + length)
    {
        dataPointer += length;
        return YES;
    }
    else
    {
    	return NO;
    }

}

- (void) dealloc
{
    if (GIF_buffer != nil)
    {
	    [GIF_buffer release];
    }
    
    if (GIF_screen != nil)
    {
		[GIF_screen release];
    }
        
    if (GIF_global != nil)
    {
        [GIF_global release];
    }
    
    if (GIF_delays != nil)
    {
		[GIF_delays release];
    }
    
    if (GIF_framesData != nil)
    {
		[GIF_framesData release];
    }
    if (GIF_framesarea != nil) {
        [GIF_framesData release];
    }
	[super dealloc];
}
@end
