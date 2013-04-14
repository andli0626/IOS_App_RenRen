//
//  RCPublishPost.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-27.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCPublishPost.h"
#import "RCMainUser.h"
#import "RCLBSCacheManager.h"
//#import "UIImage+RNAdditions.h"

static NSInteger compareString(id str1, id str2, void *context)
{
	return [((NSString*)str1) compare:str2 options:NSLiteralSearch];
}

@implementation RCPublishPost
@synthesize  photoData = _photoData;
@synthesize isPhoto=_isPhoto;
@synthesize pair=_pair;
@synthesize isLocation = _isLocation;

- (void)dealloc
{
    RL_RELEASE_SAFELY(_pair);
    RL_RELEASE_SAFELY(_photoData);
	[super dealloc];
}

- (id)init
{
	if (self = [super init]) {
		self.photoData = nil;
        self.isPhoto = NO;
        self.isLocation = NO;
	}
	return self;
}
/**
 * 发送请求
 */
- (void)sendQuery:(NSMutableDictionary *)query withMethod:(NSString*)method
{
	RCConfig *config = [RCConfig globalConfig]; 
    NSString *loginUrl = config.apiUrl;
	
    NSString* hostname = [NSString stringWithFormat:@"%@/%@", loginUrl, method];
	
	[self initWithURLString:hostname params:query httpMethod:@"POST"];
		
	RCMainSendQueue *mainSendQueue = [RCMainSendQueue sharedMainQueue];
	
	[mainSendQueue addToLinearQueue: self];// 加入到发送队列里面
}
/**
 *计算它是由当前请求参数和SecretKey的一个MD5值
 */
- (NSString *) getRR3GSig:(NSArray*)unsorted 
{
	NSArray *sortedArray = [unsorted
							sortedArrayUsingFunction:compareString context:NULL];
	
	NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:0];
	
	NSEnumerator *i = [sortedArray objectEnumerator];
	
	id theObject;
	
    while (theObject = [i nextObject]) {
        [buffer appendString:theObject];
	}
	
	[buffer appendString:[RCMainUser getInstance].userSecretKey];
	
	NSString* ret = [buffer md5];
	
	[buffer release];
	
	return ret;
}

- (void)publishPostWith:(UIImage *)photoImage
		   paramDic:(NSDictionary *)paramDic
		 withMethod:(NSString*)method{
	
	if(!paramDic)
	{
		return;
	}
    if(photoImage){
		self.photoData = UIImagePNGRepresentation(photoImage);//导入照片数据,此处可以兼容png，jpg,gif的UIImage
        self.isPhoto = YES;
        self.postState.thumbnails = [UIImage scaleImage:photoImage scaleToSize:CGSizeMake(35, 35)];
        NSString *aid = [paramDic objectForKey:@"aid"];
        if (aid == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"PublishPhotoId"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:aid forKey:@"PublishPhotoId"];
        }
        
        
	}else {
        self.photoData=nil;
        self.isPhoto = NO;
    }
    
    if(_pair ==nil)
        _pair = [[NSMutableDictionary alloc] init];
    
	/* 参数对初始化　*/
	[_pair setDictionary:paramDic];
    NSString *callId = [[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] stringValue];
    self.postState.sendTime = callId;
	RCConfig *config = [RCConfig globalConfig];
	RCMainUser *mainUser = [RCMainUser getInstance];
	[_pair setObject:config.apiKey forKey:@"api_key"];
	[_pair setObject:callId forKey:@"call_id"];
	[_pair setObject:config.clientInfo forKey:@"client_info"];
	[_pair setObject:@"1.0" forKey:@"v"]; 
	[_pair setObject:mainUser.sessionKey forKey:@"session_key"];
	[_pair setObject:@"json" forKey:@"format"];
	
	/***** 计算sig *****/
	NSEnumerator *e = [_pair keyEnumerator];
	NSString* theKey; 
	NSMutableArray *unsorted = [[NSMutableArray alloc] initWithCapacity:0];
	while (theKey = [e nextObject]) {
		
		NSString *value = [_pair objectForKey:theKey];
		if (value 
			&& [value isKindOfClass:[NSString class]] 
			&& value.length > 50) {
			
			value = [value substringToIndex:50];
		}
		NSString *aPair = [NSString stringWithFormat:@"%@=%@", theKey, value];
		[unsorted addObject:aPair];//逐个加入参数对
	}
	NSString *sig = [self getRR3GSig: unsorted];
    [unsorted release];
	[_pair setObject:sig forKey:@"sig"]; //参数对中加入sig
    
	[self sendQuery: _pair withMethod:method];//multipart方式上传
    
}
/**
 * 重载父类MKNetWorkOperation,以实现数据的multipart封装
 */
- (NSData*) bodyData 
{
    if (self.isPhoto == NO) {
        return [super bodyData];
    }
	NSString *boundary = @"FlPm4LpSXsE";//Multipart 分割字段
	
	NSMutableDictionary *thePair = _pair;
	if (thePair != nil)
	{
		NSEnumerator *e = [thePair keyEnumerator];
		NSString* theKey;
		NSMutableString *stringBuffer=[[NSMutableString alloc]initWithCapacity:0];
		e = [thePair keyEnumerator];
		while (theKey = [e nextObject]) {
			[stringBuffer appendFormat:@"--"];
			[stringBuffer appendFormat:boundary];
			[stringBuffer appendFormat:@"\r\n"];
			[stringBuffer appendFormat:@"Content-Disposition: form-data; name=\"" ];
			[stringBuffer appendFormat:theKey];
			[stringBuffer appendFormat:@"\"\r\n\r\n"];
			NSObject* value = [thePair objectForKey:theKey];
            [stringBuffer appendFormat:@"%@",value];
			[stringBuffer appendFormat:@"\r\n"];
		}//加入参数对信息
		[stringBuffer appendFormat:@"--"];
		[stringBuffer appendFormat:boundary];
		[stringBuffer appendFormat:@"\r\n"];
		[stringBuffer appendFormat:@"Content-Disposition: form-data; name=\"data\";filename=\""];
		[stringBuffer appendFormat:@"tmp_filename"];
		[stringBuffer appendFormat:@".jpg\"\r\n"];
		[stringBuffer appendFormat:@"Content-Type: image/jpg\r\n\r\n"];
		
		NSMutableData *tempData=[[NSMutableData alloc]initWithLength:0];
		[tempData appendData: [stringBuffer dataUsingEncoding:NSUTF8StringEncoding]];
		[stringBuffer release];
		
		if (self.photoData) {
		    [tempData appendData: self.photoData];//加入照片数据
		}
		
		NSMutableString *mutString=[[NSMutableString alloc]initWithCapacity:0];
		[mutString appendString:@"\r\n--"];//加入multipart结束符
		[mutString appendString:boundary];
		[mutString appendString:@"--\r\n"];
		[tempData appendData:[mutString dataUsingEncoding:NSUTF8StringEncoding]];
		
		[mutString release];
		//设置发送请求的头部信息
		[self.operationRequest setValue:@"multipart/form-data; charset=UTF-8; boundary=FlPm4LpSXsE" forHTTPHeaderField:@"Content-Type"];			       
		NSString *reqStr = [NSString stringWithFormat:@"%d",[tempData length]];
		[self.operationRequest setValue:reqStr forHTTPHeaderField:@"Content-Length"];
		
		return  tempData;	
	}
	
	return  nil;
	
}
//todo: 如果包含lbs相关数据则需要回调lbs
-(void)operationSucceeded
{
//    [super operationSucceeded];
//    if (self.isLocation) {
//        RCLBSCacheManager* manager = [RCLBSCacheManager sharedInstance];
//        if(manager){
//            [manager dealPublisherDataResponse:self postData:_pair isPostPhoto:_isPhoto];
//        }
//    }
//    if (self.isPhoto) {
//        NSString* thaid = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"PublishPhotoId"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kUploadPhotoSuccessNotification object:thaid];
//    }

}
-(void)operationFailedWithError:(NSError *)error
{
    NSLog(@"syp===");
}
 - (void)encodeWithCoder:(NSCoder *)encoder 
 {
     [super encodeWithCoder:encoder];
     [encoder encodeObject:self.pair forKey:@"publishParameter"];
     [encoder encodeBool:self.isPhoto forKey:@"publsihIsPhoto"];
     [encoder encodeObject:self.photoData forKey:@"publishPhotoData"];
 }
 
 - (id)initWithCoder:(NSCoder *)decoder 
 {
     self = [super initWithCoder:decoder];
     if (self) {
         self.pair = [decoder decodeObjectForKey:@"publishParameter"];
         
         self.isPhoto=[decoder decodeBoolForKey:@"publsihIsPhoto"];
         self.photoData = [decoder decodeObjectForKey:@"publishPhotoData"];
     }
     return self;
 }
 
 - (id)copyWithZone:(NSZone *)zone
 {
     RCPublishPost *theCopy = [super copyWithZone:zone];  // use designated initializer
     
     [theCopy setPair:[self.pair copy]];
     [theCopy setIsPhoto:self.isPhoto];
     [theCopy setIsLocation:self.isLocation];
     [theCopy setPhotoData:[self.photoData copy]];

     return theCopy;
 }

@end
