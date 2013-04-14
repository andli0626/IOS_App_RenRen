//
//  RNAtFriendsModel.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-1.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNAtFriendsModel.h"
#import "RCDataPersistenceAssistant.h"
#import "Pinyin.h"
#import "RNFriendsSectionInfo.h"

static NSInteger arrySortFuc(NSDictionary *oneDic, NSDictionary *otherDic, void *context) {
	Pinyin *pinyin = [Pinyin getInstance];
    NSString* oneName,* otherName;
    oneName = [oneDic objectForKey:@"user_name"];
    otherName = [otherDic objectForKey:@"user_name"];
    
	NSString *oneNamePinyin = [pinyin.map objectForKey:[oneName substringToIndex:1]];
	NSString *otherNamePinyin = [pinyin.map objectForKey:[otherName substringToIndex:1]];
	
	if (oneNamePinyin == nil) {
		oneNamePinyin = @"~";
	}
	if (otherNamePinyin == nil) {
		otherNamePinyin = @"~";
	}
	if ( [oneName length] > 1 && [otherName length] > 1) {
		NSString *oneFamilyName = [oneName substringToIndex:1];
		NSString *otherFamilyName = [otherName substringToIndex:1];
		NSString *oneNameNext = [pinyin.map objectForKey:[oneName substringWithRange:NSMakeRange(1, 1)]];
		NSString *otherNameNext = [pinyin.map objectForKey:[otherName substringWithRange:NSMakeRange(1, 1)]];
        
        if([oneFamilyName isEqualToString:otherFamilyName]){
			return [oneNameNext compare:otherNameNext options:NSStringEnumerationByWords];
		}else{
            if (NSOrderedSame == [oneNamePinyin compare:otherNamePinyin options:NSStringEnumerationByWords]) {
                return NSOrderedDescending;
            }
			return [oneNamePinyin compare:otherNamePinyin options:NSStringEnumerationByWords];
		}
        
        
	}else {
		return [oneNamePinyin compare:otherNamePinyin options:NSStringEnumerationByWords];
	}
}

@implementation RNAtFriendsModel

@synthesize nearlyatPersons=_nearlyatPersons;
//@synthesize nearlySectionPersons=_nearlySectionPersons;

@synthesize chatPersons = _chatPersons;
@synthesize chatSectionPersons = _chatSectionPersons;
@synthesize chatPersonsCount = _chatPersonsCount;
@synthesize fromCache = _fromCache;
//@synthesize sectionInfo = _sectionInfo;
@synthesize sectionCount = _sectionCount;
@synthesize friendsType = _friendsType;
@synthesize ownerId=_ownerId;
//公共主页数据
@synthesize pagePersons = _pagePersons;
@synthesize pageSectionPersons = _pageSectionPersons;
@synthesize searchData=_searchData;
@synthesize atFriendData=_atFriendData;

- (void) dealloc {
    TT_RELEASE_SAFELY(_chatPersons);
    TT_RELEASE_SAFELY(_chatSectionPersons);
    TT_RELEASE_SAFELY(_atFriendData);
    if (_ownerId) {
        [_ownerId release];
    }
	[super dealloc];
}
- (id)init{
	if (self = [super init]) {
        _chatPersons = nil;
        _chatSectionPersons = nil;
        _chatPersonsCount = 0;
        _sectionCount = 0;
        _fromCache = (0 != [self.chatPersons count]);
        _friendsType = ENormalFriendType;
        _atFriendData = [[NSMutableDictionary alloc] initWithCapacity:10];
        _searchData = [[NSMutableArray alloc] init];
        _ownerId =nil;
	}
	return self;
}

- (id)initWithUserId:(NSNumber *)userId {
    if (self = [self init]) {
        if(nil != userId){
            [_query setValue:userId forKey:@"userId"];
        }
        [_query setValue:[NSNumber numberWithInt:6000] forKey:@"pageSize"];
        [_query setValue:[NSNumber numberWithInt:1] forKey:@"hasNetwork"];
        [_query setValue:[NSNumber numberWithInt:20] forKey:@"count"];
    }
    return self;
}
//获得权限的时候的所有者id，用户获取公共好友
-(void)setOwnerId:(NSNumber *)ownerId{
    if (_ownerId) {
        [_ownerId release];
        _ownerId =nil;
    }
    _ownerId = [ownerId retain];
    [_query setValue:ownerId forKey:@"userId"];
    [_query setObject:[NSNumber numberWithInt:1] forKey:@"hasSharedFriendsCount"];
    [_query setObject:[NSNumber numberWithInt:1] forKey:@"hasIsFriend"];
    [_query setObject:[NSNumber numberWithInt:1] forKey:@"hasHeadImg"];
    [_query setObject:[NSNumber numberWithInt:1] forKey:@"hasGender"];
    [_query setObject:[NSNumber numberWithInt:1] forKey:@"hasOnline"];
    self.method = @"friends/getSharedFriends";
}
- (void)loadFromCache
{
    if(self.fromCache){
        /*        self.chatPersons = [NSMutableArray arrayWithArray:[RCDataPersistenceAssistant getFriendList]];
         if(self.chatPersons && [self.chatPersons count] > 0){
         [self addPinyinNameForFriends];
         [self.chatPersons sortUsingFunction:friendSortFuc context:nil];
         [self configChatSectionPersons];
         [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
         }
         else{
         [self load:NO];
         }*/
        [NSThread detachNewThreadSelector:@selector(loadCacheData) toTarget:self withObject:nil];
    }
}

- (void)loadCacheData
{
    self.chatPersons = [NSMutableArray arrayWithArray:[RCDataPersistenceAssistant getFriendList]];
    if(self.chatPersons && [self.chatPersons count] > 0){
        [self addPinyinName:self.chatPersons];
        [self performSelectorOnMainThread:@selector(didLoadCacheDataFinished) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(load:) withObject:NO waitUntilDone:YES];
    }
}

- (void)didLoadCacheDataFinished
{
    [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}


- (void)setFriendsType:(AtFriendType)friendsType
{
    _friendsType = friendsType;
    NSString* method = @"friends/getFriends";
    switch (_friendsType) {
        case ENearlyFriendType:
            method =  @"at/getFreqAtFriends";
            break;
        case ENormalFriendType:
            if (_ownerId == nil) {
                 method = @"friends/getFriends";
                
            }else {
                method = @"friends/getSharedFriends";
            }
           
            break;
        case EPublicFriendType:
            method = @"page/getList";
            break;
        default:
            break;
    }
    self.method = method;
}

- (void)search:(NSString*)text
{
    NSMutableArray *searchdatatmp ;
    if (_friendsType == EPublicFriendType) {
        searchdatatmp = self.pagePersons;
    }else {
        searchdatatmp = self.chatPersons;
    }
    
    if (text != nil && [text length] > 0){
		[self.searchData removeAllObjects];
		int total = [searchdatatmp count];
		
		for (int i = 0; i < total; ++i) {
			id object = [searchdatatmp objectAtIndex:i];
			if ([object isKindOfClass:[NSDictionary class]]) {
				
				NSDictionary *sectionObject = (NSDictionary *)object;
                NSDictionary *userDic = (NSDictionary *)sectionObject;
                NSString *userName = nil;
                if (_friendsType == EPublicFriendType) {
                    userName=[userDic objectForKey:@"page_name"];
                }else {
                    userName=[userDic objectForKey:@"user_name"];
                }
                NSString *userLetter = [userDic objectForKey:@"pinyin"];
                if ([userName rangeOfString:text].length != 0) {
                    [self.searchData addObject:userDic];
                }
                else if ([userLetter.lowercaseString rangeOfString:text.lowercaseString].length != 0){
                    [self.searchData addObject:userDic];
                }
			}
		}
        
        
        [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
    }
}

- (void)resetData:(BOOL)isPage
{
    if (isPage) {
        TT_RELEASE_SAFELY(_pagePersons);
        TT_RELEASE_SAFELY(_pageSectionPersons);
    }else {
        TT_RELEASE_SAFELY(_chatPersons);
        TT_RELEASE_SAFELY(_chatSectionPersons);
        _chatPersonsCount = 0;
        _sectionCount = 0;
        _fromCache = (0 != [self.chatPersons count]);
    }
}
-(NSMutableArray*) nearlyatPersons{
    if (!_nearlyatPersons) {
        _nearlyatPersons = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return _nearlyatPersons;
}
-(NSMutableArray*) chatPersons{
    if (!_chatPersons) {
        _chatPersons = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return _chatPersons;
}

-(NSMutableArray*) chatSectionPersons{
    if (!_chatSectionPersons) {
        _chatSectionPersons = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return _chatSectionPersons;
}

-(NSMutableArray*) pagePersons{
    if (!_pagePersons) {
        _pagePersons = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return _pagePersons;
}

-(NSMutableArray*) pageSectionPersons{
    if (!_pageSectionPersons) {
        _pageSectionPersons = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return _pageSectionPersons;
}
- (void)load:(BOOL)more {
    if(more){
        //
    }
    else {
        [super load:more];
    }
}
- (void)didFinishLoad:(id)result {
    NSDictionary *dics = (NSDictionary *)result;
    
    //self.chatPersonsCount = [[dics objectForKey:@"count"] intValue];

    if (_friendsType == EPublicFriendType) {
        [self resetData:YES];
        NSMutableArray *pagesArray = [dics objectForKey:@"page_list"];
        for(NSDictionary* page in pagesArray){
            NSMutableDictionary* temppage = [NSMutableDictionary dictionaryWithDictionary:page];
            if(![page objectForKey:@"page_name"] || [[page objectForKey:@"page_name"] length] == 0){
                [temppage setValue:NSLocalizedString(@"未知主页", @"未知主页") forKey:@"page_name"];
            }
            [self.pagePersons addObject:temppage];
        }
    }else if(_friendsType == ENearlyFriendType){
        TT_RELEASE_SAFELY(_nearlyatPersons);
        NSMutableArray *nearlyfriendsArray = [dics objectForKey:@"at_list"];
        
        for(NSDictionary* friend in nearlyfriendsArray){
            NSMutableDictionary* tempfriend = [NSMutableDictionary dictionaryWithDictionary:friend];
            if(![friend objectForKey:@"user_name"] || [[friend objectForKey:@"user_name"] length] == 0){
                [tempfriend setValue:NSLocalizedString(@"未知用户", @"未知用户") forKey:@"user_name"];
            }
            [self.nearlyatPersons addObject:tempfriend];
        }        
    }else {
        [self resetData:NO];
        NSMutableArray *friendsArray = [dics objectForKey:@"friend_list"];
        for(NSDictionary* friend in friendsArray){
            NSMutableDictionary* tempfriend = [NSMutableDictionary dictionaryWithDictionary:friend];
            if(![friend objectForKey:@"user_name"] || [[friend objectForKey:@"user_name"] length] == 0){
                [tempfriend setValue:NSLocalizedString(@"未知用户", @"未知用户") forKey:@"user_name"];
            }
            [self.chatPersons addObject:tempfriend];
        }
        if (_ownerId == nil ) {//如果是有权限的列表则不能去存缓存
            [RCDataPersistenceAssistant saveFriendList:self.chatPersons];
        }
        [self addPinyinName:self.chatPersons];
    }
    
    
    [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 以下是类的私有方法。
- (void)configChatSectionPersons:(NSMutableArray*)arrary{
	NSMutableArray *sectionedFriendArray = [NSMutableArray arrayWithCapacity:56];//(26+1+1)x2
	NSMutableArray *sectionArray = [NSMutableArray array];//存放好友数据
    NSMutableDictionary* sectionDicArray = [NSMutableDictionary dictionaryWithCapacity:5];
    
	Pinyin *py = [Pinyin getInstance];
    NSString *newSectionLetter = nil; // 循环时首字母
    NSString *familyName = nil;  // 姓
    int sectionIndex = 0;
    int rowIndex = 0;
    RNFriendsSectionInfo  *chatSectionInfo = [[RNFriendsSectionInfo alloc]init];
    //NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    
    for (int index = 0; index < [arrary count];++index) {
        NSDictionary *chatPersonDic = (NSDictionary*)[arrary objectAtIndex:index];
        NSString*  userName = [chatPersonDic objectForKey:@"user_name"]; 
        familyName = [userName substringToIndex:1];
        newSectionLetter = [[py.map objectForKey:familyName] substringToIndex:1];
		if (newSectionLetter == nil) {
			newSectionLetter = @"~";
		}
        // 如果首字母变化
        if (![newSectionLetter isEqualToString:chatSectionInfo.letter]
            && [sectionArray count] > 0) {
            [sectionDicArray setObject:sectionArray forKey:@"personsInfo"];
            [sectionDicArray setObject:chatSectionInfo forKey:@"sectionInfo"];
            [sectionedFriendArray addObject:sectionDicArray];
            
            // realloc
            [chatSectionInfo release];
            chatSectionInfo =nil;
            chatSectionInfo = [[RNFriendsSectionInfo alloc]init];
            chatSectionInfo.letter = [[newSectionLetter copy]autorelease];            
            sectionArray = [NSMutableArray array];// 重新创建一个存放好友数据的数组
            sectionDicArray = [NSMutableDictionary dictionaryWithCapacity:5];
            
            rowIndex = 0;
            ++sectionIndex;
        }
        // 添加姓
        //RRLOG_debug(@" ## familyName:[%@]", familyName);
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        RSFamilyNameInfo *familyNameInfo = [[RSFamilyNameInfo alloc]initWithName:familyName ofIndexPath:cellIndexPath];
        [chatSectionInfo addFamilyInfo:familyNameInfo];
        [familyNameInfo release];
        ++rowIndex;
        if (chatSectionInfo.letter == nil) {
            chatSectionInfo.letter = [[newSectionLetter copy]autorelease];
        }
        // 添加一个好友数据
		[sectionArray addObject:chatPersonDic];
        // 最后一个
        if (index == [arrary count]-1) { 
            [sectionDicArray setObject:sectionArray forKey:@"personsInfo"];
            [sectionDicArray setObject:chatSectionInfo forKey:@"sectionInfo"];
            [sectionedFriendArray addObject:sectionDicArray];
            [chatSectionInfo release];
            chatSectionInfo =nil;
        }	
    }
	self.chatSectionPersons = sectionedFriendArray;
    [chatSectionInfo release];
    chatSectionInfo =nil;
}

- (void)addPinyinName:(NSMutableArray*)arrary {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
	Pinyin *py = [Pinyin getInstance];
    if (py.map == nil) {
		[py loadMap];
	}
	while(py.map == nil) {//保证字典加载完毕
		[NSThread sleepForTimeInterval:0.5f];
	}
	if (_friendsType == EPublicFriendType) {
        
        
        
    }else {
        for (int i = 0 ;i < [arrary count]; i++) {
            NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithDictionary:[self.chatPersons objectAtIndex:i]];
            NSString *name = [userDic objectForKey:@"user_name"];
            
            NSMutableString *pinyinName = [NSMutableString stringWithCapacity:20];
            for (int i = 0; i < [name length]; i++) {
                NSString *c = [name substringWithRange:NSMakeRange(i, 1)];
                NSString *aPinyin = [py.map objectForKey:c];
                if (aPinyin == nil) {
                    aPinyin = c;
                }
                [pinyinName appendString:aPinyin];
            }
            [userDic setObject:pinyinName forKey:@"pinyin"];
            [arrary replaceObjectAtIndex:i withObject:userDic];
        }
    }

    [pool drain];
    [arrary sortUsingFunction:arrySortFuc context:nil];
    [self configChatSectionPersons:arrary];
}

-(BOOL)addAtFriendData:(id)keys value:(id)val{

    if ([_atFriendData count]>=10) {
        return NO;
    }
    [_atFriendData setObject:val forKey:keys];
    return YES;
}
-(void)removeAtFriendDataForKey:(id)key{
    [_atFriendData removeObjectForKey:key];
}
-(BOOL)findAtFriendDataForKey:(id)key{
    if ([_atFriendData objectForKey:key]) {
        return  YES;
    }
    return NO;
}
-(void)removeAtFriendDataForobj:(id)val{
    NSArray *keys =  [_atFriendData allKeysForObject:val];
    for (id key in keys) {
        [self removeAtFriendDataForKey:key];
    }
}

@end
