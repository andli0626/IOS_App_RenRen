//
//  RRFriendItem.m
//  RRSpring
//
//  Created by yi chen on 12-2-27.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCFriendItem.h"
//#import "NSDate+NSDateExt.h"

//好友列表item
@implementation RCFriendItem

@synthesize headUrl = _headUrl;
@synthesize networkName = _networkName;
@synthesize userName = _userName;
@synthesize onLine = _onLine;
@synthesize uid = _uid;
@synthesize group = _group;
@synthesize isFriend = _isFriend;
@synthesize alreadyAdd = _alreadyAdd;
@synthesize gender = _gender;
@synthesize status = _status;
@synthesize fromAt = _fromAt;
@synthesize selected = _selected;

- (void) dealloc {
	[_headUrl release];
	[_networkName release];
	[_userName release];
	[_uid release];
	[_group release];
    [_gender release];
    [_status release];
	[super dealloc];
}

-(id)initWithDicInfo:(NSDictionary *)friendDic
{
    if (self = [super init]) {
        
        if ([friendDic objectForKey:@"head_url"]!= nil) {
            self.headUrl = [friendDic objectForKey:@"head_url"];
        } else if([friendDic objectForKey:@"user_head"]!= nil) {
            self.headUrl = [friendDic objectForKey:@"user_head"];        
        }
        
        self.networkName = [friendDic objectForKey:@"network"];
        self.userName = [friendDic objectForKey:@"user_name"];
        self.uid = [friendDic objectForKey:@"user_id"];
        self.group = [friendDic objectForKey:@"group"];
        self.gender = [friendDic objectForKey:@"gender"];
        self.status = [friendDic objectForKey:@"status"];
        if ([[friendDic objectForKey:@"is_online"] intValue] != 0 || 
            [[friendDic objectForKey:@"online"] intValue] != 0||
            [[friendDic objectForKey:@"wap_online"] intValue] != 0) {
            self.onLine = YES;
        }
        if ([[friendDic objectForKey:@"is_friend"] intValue] != 0) {
            self.isFriend = YES;
        }
        self.alreadyAdd = NO; 
    }
    return self;
}

+ (id)itemWithDicInfo:(NSDictionary *)friendDic {
	RCFriendItem *item = [[RCFriendItem alloc] initWithDicInfo:friendDic];
	return [item autorelease];
}

-(NSString*)description
{
	//NSLog(@"%@,%@", self.uid, self.headUrl);
	NSString *str = [[[NSString alloc ] initWithFormat: 
					 @"uid = %@ \nheadUrl = %@ \nuserName = %@ \n 性别 = %@ \nstate = %@\nfromAt = %@\n  etc ....prepare to print\n",
					 self.uid, self.headUrl, self.userName,self.gender,self.status,self.fromAt] autorelease];
	return str;
	
}
@end
