//
//  RCUser.m
//  RRSpring
//
//  Created by yusheng.wu on 12-2-20.
//  Copyright (c) 2012年 Renn. All rights reserved.
//

#import "RCUser.h"

@implementation RCUser

@synthesize userId = _userId;
@synthesize userName;
@synthesize pinyinName;
@synthesize headurl = _headurl;
@synthesize tinyurl = _tinyurl;
@synthesize mainurl = _mainurl;
@synthesize networkName;

@synthesize gossipCount, albumCount, blogCount,friendCount,shareFriendsCount;
@synthesize star;
@synthesize online;
@synthesize dirty;
@synthesize lockName = _lockName;
@synthesize usererror;
@synthesize isChecked;
@synthesize apiType = _apiType;


- (void) setHeadurl:(NSString*)newUrl
{
	if ((NSNull*)newUrl == [NSNull null])
	{
		TT_RELEASE_SAFELY(_headurl);
		_headurl = [newUrl copy];
		self.dirty = YES;
		return;
	}
	
	if (![_headurl isEqualToString:newUrl]) {
		NSString* temp = [newUrl copy];
		[_headurl release];
		_headurl = temp;
		
		self.dirty = YES;
	}
}


- (void) setNetworkName:(NSString*)newNetworkName
{
	if ((NSNull*)newNetworkName == [NSNull null])
	{
		[networkName release];
		networkName = nil;
		self.dirty = YES;
		return;
	}
	
	if (![newNetworkName isEqualToString:networkName])
	{
		NSString* temp = [newNetworkName copy];
		[networkName release];
		networkName = temp;
		
		self.dirty = YES;
	}
}


//+ (XNUser*) getUser:(NSNumber*)uid
//{
//	return [[XNUserManager getManager] getUser:uid];
//}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id) init {
	
	if (self = [super init]) {
		self.isChecked = FALSE;
	}
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id) initWithUserId:(NSNumber*)userId
{
	if (self = [self init])
	{
		self.userId = userId;
		self.dirty = YES;
		self.lockName = FALSE;
	}
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fillWithArrayForBatchRun:(NSArray*)info {
	if (!info) {
		return;
	}
	
	if (RRApiRROpenPlatform == self.apiType) {
		
		// 解析profile.getInfo
		if (info.count > 0) {
			NSDictionary* profileInfo = [[info objectAtIndex:0] objectForKey:@"profile.getInfo"];
			[self fillWithDictionaryForProfileGetInfo:profileInfo];
		}
		
		// 解析users.getInfo
		if (info.count > 1) {
			NSArray* usersInfos = [[info objectAtIndex:1] objectForKey:@"users.getInfo"];
			if (usersInfos && usersInfos.count > 0) {
				NSDictionary* usersInfo = [usersInfos objectAtIndex:0];
				[self fillWithDictionaryForUsersGetInfo:usersInfo];
			}
		}
		
		// 解析friends.areFriends
		if (info.count > 2) {
			NSArray* areFriendsInfo = [[info objectAtIndex:2] objectForKey:@"friends.areFriends"];
			if (areFriendsInfo.count > 0) {
				//NSDictionary* relation = [areFriendsInfo objectAtIndex:0];
				//self.isFriend = [[relation objectForKey:@"are_friends"] intValue];
			}
		}
	} else if (RRApiRR3G == self.apiType) {
		if (info.count > 0) {
			NSDictionary *profileDic = [[info objectAtIndex:0] objectForKey:@"profile.getInfo"];
			[self fillWithDictionaryForProfileGetInfo:profileDic];
		}
		if (info.count > 1) {
			NSArray *areFriendsArray = [[[info objectAtIndex:1] 
                                         objectForKey:@"friends.areFriends"] 
										objectForKey:@"friend_info_list"];
			if (areFriendsArray.count > 0) {
				NSDictionary *areFriends = [areFriendsArray objectAtIndex:0];
				if ([[areFriends objectForKey:@"are_friends"] boolValue]) {
					//self.isFriend = RRFriendRelationYes;
				} else {
					//self.isFriend = RRFriendRelationNo;
				}
                
			}
		}
	}
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) fillWithDictionaryForProfileGetInfo:(NSDictionary*)dictionary {
	
	// 状态
	//self.curStatus = [RRStatus statusWithDictionaryAtPageProfile:[dictionary objectForKey:@"status"]];
	self.networkName = [dictionary objectForKey:@"network_name"];
	
	if (RRApiRR3G == self.apiType) {
		NSArray *networkArray = [dictionary objectForKey:@"network"];
		self.tinyurl = [dictionary objectForKey:@"tiny_url"];
		self.headurl = [dictionary objectForKey:@"head_url"];
		self.networkName = [networkArray componentsJoinedByString:@","];
		
		// 解析生日.
		//self.birthday = [RRBirthday birthdayWithDictionary:[dictionary objectForKey:@"birth"]];
		
		// 解析家乡信息.
		//self.hometown = [RRHometown hometownWithProvince:[dictionary objectForKey:@"hometown_province"] 
//												    city:[dictionary objectForKey:@"hometown_city"]];
        self.friendCount = [[dictionary objectForKey:@"friend_count"] intValue];
        self.shareFriendsCount = [[dictionary objectForKey:@"share_friend_count"] intValue];
        if ([[dictionary objectForKey:@"is_friend"] intValue] == 1) 
        {
            //self.isFriend = RRFriendRelationYes;
        }else{
            //self.isFriend = RRFriendRelationNo;
        }
		
		if([dictionary objectForKey:@"gender"]){
			//self.gender = [[dictionary objectForKey:@"gender"] intValue];
		} else {
			//self.gender = -1;//表示性别为空
		}
		self.userName = [dictionary objectForKey:@"user_name"];
		self.usererror = [dictionary objectForKey:@"error_code"];
		RRLOG_debug(@"&&&&&&---- %@",self.usererror);
		
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) fillWithDictionaryForGetProfile:(NSDictionary*)dictionary {
	
    
	self.userId = [dictionary objectForKey:@"user_id"];
	
	// 状态
//	self.curStatus = [RRStatus statusWithDictionaryAtPageProfile:[dictionary objectForKey:@"status"]];
	
	self.userName = [dictionary objectForKey:@"name"];
	
	self.networkName = [dictionary objectForKey:@"network_name"];
	
	
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) fillWithDictionaryForUsersGetInfo:(NSDictionary*)dict {
	
	self.tinyurl = [dict objectForKey:@"tinyurl"];
	self.headurl = [dict objectForKey:@"headurl"];
	self.mainurl = [dict objectForKey:@"mainurl"];
	
	// 解析生日.
//	self.birthday = [RRBirthday birthdayWithString:[dict objectForKey:@"birthday"]];
//	
//	// 解析家乡信息.
//	self.hometown = [RRHometown hometownWithDictionaryAtPersonProfile:[dict objectForKey:@"hometown_location"]];
//	
//	if([dict objectForKey:@"gender"]){
//		self.gender = [[dict objectForKey:@"gender"] intValue];
//	} else {
//		self.gender = -1;
//	}
	self.userName = [dict objectForKey:@"name"];
    
	
}




- (void) dealloc
{
	TT_RELEASE_SAFELY(_userId);
	[userName release];
	[pinyinName release];
	TT_RELEASE_SAFELY(_tinyurl);
	TT_RELEASE_SAFELY(_headurl);
	TT_RELEASE_SAFELY(_mainurl);
	[networkName release];
//	TT_RELEASE_SAFELY(_curStatus);
//	TT_RELEASE_SAFELY(_birthday);
//	TT_RELEASE_SAFELY(_hometown);
	
	[super dealloc];
}


- (void) didReceiveMemoryWarning
{
	
}


- (BOOL) isMainUser
{
	return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)sexName {
//	switch (_gender) {
//		case RRGenderMale:
//			return @"男";
//		case RRGenderFemale:
//			return @"女";
//		case RRGenderUnknow:
//			return @"未知";
//		default:
//			return @"";
//	}
    return nil;
}
#pragma mark -
#pragma mark NSCoding methods
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [self init]) {
		self.userId = [decoder decodeObjectForKey:@"userId"];
		self.userName = [decoder decodeObjectForKey:@"userName"];
		self.pinyinName = [decoder decodeObjectForKey:@"pinyinName"];
		self.tinyurl = [decoder decodeObjectForKey:@"tinyurl"];
		self.headurl = [decoder decodeObjectForKey:@"headUrl"];
		self.mainurl = [decoder decodeObjectForKey:@"mainurl"];
		self.networkName = [decoder decodeObjectForKey:@"networkName"];
	}
	return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.userId forKey:@"userId"];
	[encoder encodeObject:self.userName forKey:@"userName"];
	[encoder encodeObject:self.pinyinName forKey:@"pinyinName"];
	[encoder encodeObject:self.tinyurl forKey:@"tinyurl"];
	[encoder encodeObject:self.headurl forKey:@"headUrl"];
	[encoder encodeObject:self.mainurl forKey:@"mainurl"];
	[encoder encodeObject:self.networkName forKey:@"networkName"];
}

#pragma mark -
#pragma mark TTModel methods
///////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
//    //[super load:cachePolicy more:more];
//	if (!self.isLoading) {
//		
//		if (RRApiRROpenPlatform == self.apiType) {
//			
//			// 批处理接口参数数组.
//			NSMutableArray* batchQuery = [NSMutableArray arrayWithCapacity:3];
//			
//			RRMainUser *mainUser = [RRMainUser getInstance];
//			// 第一个接口.profile.getInfo,用于取用户的当前状态和网络.
//			NSMutableDictionary* profileQuery = [NSMutableDictionary dictionaryWithCapacity:0];
//			[profileQuery setObject:[self.configDelegate opApiKey] forKey:@"api_key"];
//            
//            [profileQuery setObject:[self.configDelegate clientInfoJSONString] forKey:@"client_info"];
//			[profileQuery setObject:@"profile.getInfo" forKey:@"method"];
//			[profileQuery setObject:@"1.0" forKey:@"v"];
//			[profileQuery setObject:mainUser.sessionKey forKey:@"session_key"];
//			[profileQuery setObject:@"json" forKey:@"format"];
//			[profileQuery setObject:[self.userId stringValue] forKey:@"uid"];
//			[profileQuery setObject:@"status" forKey:@"fields"];
//			[batchQuery addObject:profileQuery];
//			
//			/*
//			 // 第二个接口friends.areFriends,用于判断与登录用户是否存在好友关系.
//			 dicQuery = [NSMutableDictionary dictionaryWithCapacity:0];
//			 [dicQuery setObject:[self.configDelegate opApiKey] forKey:@"api_key"];
//			 [dicQuery setObject:@"friends.areFriends" forKey:@"method"];
//			 [dicQuery setObject:@"1.0" forKey:@"v"];
//			 [dicQuery setObject:mainUser.sessionKey forKey:@"session_key"];
//			 [dicQuery setObject:@"json" forKey:@"format"];
//			 [dicQuery setObject:[self.userId stringValue] forKey:@"uids1"];
//			 [dicQuery setObject:[mainUser.userId stringValue] forKey:@"uids2"];
//			 //[dicQuery setObject:@"compression" forKey:@"data_type"];
//			 [batchQuery addObject:dicQuery];
//			 //*/
//			
//			// 第三个接口users.getInfo,用于取得用户信息.
//			NSMutableDictionary *userInfoQuery = [NSMutableDictionary dictionaryWithCapacity:0];
//			[userInfoQuery setObject:[self.configDelegate opApiKey] forKey:@"api_key"];
//			[userInfoQuery setObject:@"users.getInfo" forKey:@"method"];
//			[userInfoQuery setObject:@"1.0" forKey:@"v"];
//			[userInfoQuery setObject:mainUser.sessionKey forKey:@"session_key"];
//			[userInfoQuery setObject:@"json" forKey:@"format"];
//			[userInfoQuery setObject:[self.userId stringValue] forKey:@"uids"];
//			[userInfoQuery setObject:@"name,sex,star,birthday,tinyurl,headurl,mainurl,hometown_location,hs_history,university_history,work_history,contact_info" forKey:@"fields"];
//			//[dicQuery setObject:@"compression" forKey:@"data_type"];
//			[batchQuery addObject:userInfoQuery];
//			
//			
//			self.batchQuery = batchQuery;
//			
//			[self sendRequest:cachePolicy 
//						 more:more 
//					  urlPath:[self.configDelegate opApiUrl] 
//				  opSecretKey:[self.configDelegate opSecretKey]];
//		} else if (RRApiRR3G == self.apiType) {
//			// 批处理接口参数数组.
//			NSMutableArray* batchQuery = [NSMutableArray arrayWithCapacity:2];
//			RRMainUser *mainUser = [RRMainUser getInstance];
//			
//			// profile query
//			NSMutableDictionary* profileQuery = [NSMutableDictionary dictionaryWithCapacity:0];
//			[profileQuery setObject:[self.configDelegate opApiKey] forKey:@"api_key"];
//			[profileQuery setObject:@"profile.getInfo" forKey:@"method"];
//            [profileQuery setObject:[self.configDelegate clientInfoJSONString] forKey:@"client_info"];
//			[profileQuery setObject:@"1.0" forKey:@"v"];
//			if (mainUser.msessionKey) {
//				[profileQuery setObject:mainUser.msessionKey forKey:@"session_key"];
//			}
//			[profileQuery setObject:@"json" forKey:@"format"];
//			[profileQuery setObject:[self.userId stringValue] forKey:@"uid"];
//			NSNumber *profileGetInfoType = [NSNumber numberWithInt:(RRProfileGetInfoTypeNetwork +
//                                                                    RRProfileGetInfoTypeGender +
//                                                                    RRProfileGetInfoTypeBirth +
//                                                                    RRProfileGetInfoTypeHometownProvince +
//                                                                    RRProfileGetInfoTypeHometownCity +
//                                                                    RRProfileGetInfoTypeStatus +
//                                                                    RRProfileGetInfoTypeIsFriend +
//                                                                    RRProfileGetInfoTypeFriendCount +
//                                                                    RRProfileGetInfoTypeShareFriendCount)];
//            
//			[profileQuery setObject:profileGetInfoType forKey:@"type"];
//			[batchQuery addObject:profileQuery];
//			
//			// are friends query
//			if (NSOrderedSame != [self.userId compare:mainUser.userId]) {
//				
//				NSMutableDictionary *areFriendsQuery = [NSMutableDictionary dictionaryWithCapacity:0];
//				[areFriendsQuery setObject:[self.configDelegate opApiKey] forKey:@"api_key"];
//                [areFriendsQuery setObject:[self.configDelegate clientInfoJSONString] forKey:@"client_info"];
//				[areFriendsQuery setObject:@"friends.areFriends" forKey:@"method"];
//				[areFriendsQuery setObject:@"1.0" forKey:@"v"];
//				if (mainUser.msessionKey) {
//					[areFriendsQuery setObject:mainUser.msessionKey forKey:@"session_key"];
//				}
//				[areFriendsQuery setObject:@"json" forKey:@"format"];
//				[areFriendsQuery setObject:[self.userId stringValue] forKey:@"user_id_list_1"];
//				[areFriendsQuery setObject:[mainUser.userId stringValue] forKey:@"user_id_list_2"];
//				
//				[batchQuery addObject:areFriendsQuery];
//			}
//			
//			self.batchQuery = batchQuery;
//			
//			[self sendRequest:TTURLRequestCachePolicyNetwork 
//						 more:more 
//					  urlPath:[self.configDelegate mApiUrl] 
//				  opSecretKey:mainUser.mprivateSecretKey];
//		}
//        
//	}
//}



///////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)requestDidFinishLoad:(TTURLRequest*)request {
//	[self processResponse:request];
//	[super requestDidFinishLoad:request];
//    
//}

///////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)processResponse:(TTURLRequest*)request {
//	
//	RRURLJSONResponse* response = request.response;
//	TTDASSERT([response.rootObject isKindOfClass:[NSArray class]]);
//	
//	NSArray* info = response.rootObject;
//	if (info) {
//		[self fillWithArrayForBatchRun:info];
//	}
//	
//}

+ (BOOL)isPageUser:(NSNumber*)uid {
	NSNumber* myUid;
	if ([uid isKindOfClass:[NSString class]]) {
		myUid = [((NSString*)uid) stringToNumber];
	} else {
		myUid = uid;
	}
    
	long min = 600000000L;
	long max = 700000000L;
	long lUid = [myUid longLongValue];
	if(lUid >= min && lUid < max) {
		return YES;
	} else {
		return NO;
	}	
}

@end
