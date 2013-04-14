//
//  RSChatSectionInfo.m
//  RenrenSixin
//
//  Created by 陶宁 on 11-11-10.
//  Copyright (c) 2011年 renren. All rights reserved.
//

#import "RNFriendsSectionInfo.h"

@implementation RSFamilyNameInfo
@synthesize name;
@synthesize indexPath;

-(void)dealloc{
    self.name = nil;
    self.indexPath = nil;
    [super dealloc];
}

- (id)initWithName:(NSString *)n ofIndexPath:(NSIndexPath*)ip{
    self = [super init];
    if (self) {
        self.name = n;
        self.indexPath = [NSIndexPath indexPathForRow:ip.row inSection:ip.section];
    }
    return self;
    
}
#pragma mark - NSCoding methods
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder{
	if (self) {
		self.name = [decoder decodeObjectForKey:@"familyName"];
		self.indexPath = [decoder decodeObjectForKey:@"familyIndexPath"];
	}
	return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.name forKey:@"familyName"];
	[encoder encodeObject:self.indexPath forKey:@"familyIndexPath"];
}
@end

@implementation RNFriendsSectionInfo
@synthesize letter = _letter;
@synthesize familyArray = _familyArray;


- (void)dealloc{
    self.letter = nil;
    self.familyArray = nil;
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _letter = nil;
//        _familyArray = [[NSMutableArray alloc]init]; // 在addFamilyInfo中会初始化，导致在initCoder中泄漏
    }
    return self;
}
#pragma mark - NSCoding methods
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder {
	if (self) {
		self.letter = [decoder decodeObjectForKey:@"sectionLetter"];
		self.familyArray = [decoder decodeObjectForKey:@"sectionFamilyArray"];
	}
	return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.letter forKey:@"sectionLetter"];
	[encoder encodeObject:self.familyArray forKey:@"sectionFamilyArray"];
}

#pragma mark - Public method
- (NSArray*)familyNameArrayForLetter:(NSString*)letter{
    return nil;
}
- (NSIndexPath*)indexPathOfFamilyName:(NSString *)name{
    
    for (RSFamilyNameInfo *info in _familyArray) {
        if (![info.name isEqualToString:name]) {
            return info.indexPath;
        }
    }
    return 0;
}
/*
 { name:index }
 */
- (BOOL)addFamilyInfo:(RSFamilyNameInfo*)familyNameInfo{
    if (!_familyArray) {
        _familyArray = [[NSMutableArray alloc]init];
    }
    // 如果有相同姓的就不添加了
    for (RSFamilyNameInfo *info in _familyArray) {
        if ([info.name isEqualToString:familyNameInfo.name]) {
            return NO;
        }
    }
    
    [_familyArray addObject:familyNameInfo];
    
    return YES;
}

@end
