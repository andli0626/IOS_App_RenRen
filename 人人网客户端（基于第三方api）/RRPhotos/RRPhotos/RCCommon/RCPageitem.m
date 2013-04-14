//
//  RCPageitem.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-1.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCPageitem.h"

@implementation RCPageitem
@synthesize isSelected=_isSelected;

- (void) dealloc {
	[super dealloc];
}

-(id)initWithDicInfo:(NSDictionary *)pageDic
{
    if (self = [super init]) {
        
        [super initWithDictionary:pageDic];
        self.isSelected = NO;
    }
    return self;
}

+ (id)itemWithDicInfo:(NSDictionary *)friendDic {
	RCPageitem *item = [[RCPageitem alloc] initWithDicInfo:friendDic];
	return [item autorelease];
}

-(NSString*)description
{
	//NSLog(@"%@,%@", self.uid, self.headUrl);
	NSString *str = [[NSString alloc ] initWithFormat: 
					 @"pageid = %@ \nheadUrl = %@ \n pagename = %@ \n classiFication = %@ \n desc = %@\n isfan = %@\n isSelect=%d\n etc ....prepare to print\n",
					 self.pageId, self.headUrl, self.pageName,self.classiFication,self.desc,self.isFan,self.isSelected];
	return str;
	
}
@end
