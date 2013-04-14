//
//  RNFastAtFriendView.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-26.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNFastAtFriendView.h"
#import "Pinyin.h"
#import "RCDataPersistenceAssistant.h"
#import "RCFriendItem.h"
#import "RNFastAtFriendViewCellCell.h"


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
@implementation RNFastAtFriendView
@synthesize friendData=_friendData;
@synthesize searchData=_searchData;
@synthesize tableView=_tableView;
@synthesize parentview=_parentview;
@synthesize deldgate=_deldgate;

- (void)addPinyinName:(NSMutableArray*)arrary {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
	Pinyin *py = [Pinyin getInstance];
    if (py.map == nil) {
		[py loadMap];
	}
	while(py.map == nil) {//保证字典加载完毕
		[NSThread sleepForTimeInterval:0.5f];
	}

    for (int i = 0 ;i < [arrary count]; i++) {
        NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithDictionary:[self.friendData objectAtIndex:i]];
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
    
    [pool drain];
    [arrary sortUsingFunction:arrySortFuc context:nil];

}
- (void)search:(NSString*)text{
    NSMutableArray *searchdatatmp = self.friendData;    
    NSMutableArray *resultdata = [NSMutableArray arrayWithCapacity:10];
    if (text != nil && [text length] > 0){
		int total = [searchdatatmp count];
		for (int i = 0; i < total; ++i) {
			id object = [searchdatatmp objectAtIndex:i];
			if ([object isKindOfClass:[NSDictionary class]]) {
				NSDictionary *sectionObject = (NSDictionary *)object;
                NSDictionary *userDic = (NSDictionary *)sectionObject;
                NSString *userName = [userDic objectForKey:@"user_name"];
                NSString *userLetter = [userDic objectForKey:@"pinyin"];
                if ([userName rangeOfString:text].length != 0) {
                    [resultdata addObject:userDic];
                }
                else if ([userLetter.lowercaseString rangeOfString:text.lowercaseString].length != 0){
                    [resultdata addObject:userDic];
                }
			}
		}
    }
    if ([resultdata count]>0) {
        [self.searchData setArray:resultdata];
        [self.tableView reloadData];
    }
}
-(BOOL)getFriendListFromCache{
    self.friendData = [NSMutableArray arrayWithArray:[RCDataPersistenceAssistant getFriendList]];
    if(self.friendData && [self.friendData count] > 0){
        [self addPinyinName:self.friendData];
        return YES;
    }
    return NO;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //初始化tableView
        UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [self addSubview:tableView];
        self.tableView = tableView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [tableView release];
        CGRect tabviewframe = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.tableView.frame = tabviewframe;
       // [self setBackgroundColor:[UIColor redColor]];
        [self getFriendListFromCache];
        self.searchData = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}
-(void)layoutSubviews{
    
    CGRect tabviewframe = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.tableView.frame = tabviewframe;
    
}
-(RNFastAtFriendView*)initWithParent:(CGRect)frame parent:(UIView*)parentview{
    self = [self initWithFrame:frame];
    self.parentview = parentview;
    return self;
}
-(BOOL)showFastAtFriendView:(CGPoint)point searchText:(NSString*)searchtext{
    
    [self search:searchtext];
    if (self.searchData && [self.searchData count]>0) {
        if(self.superview == nil && self.parentview){
            [self.parentview addSubview:self];
        }
        [self.parentview bringSubviewToFront:self];
        return YES;
    }
    if(self.superview ){
        [self removeFromSuperview];
    }
    return NO;
}
-(void)hideFastAtFriendView{
    if(self.superview ){
        [self removeFromSuperview];
        [self.searchData removeAllObjects];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.searchData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = [indexPath row];
    static NSString *CellIdentifier = @"FastCell";
    RNFastAtFriendViewCellCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RNFastAtFriendViewCellCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    RCFriendItem* dataItem = [RCFriendItem itemWithDicInfo:[self.searchData objectAtIndex:rowIndex]];
    [cell setObject:dataItem];
    return cell;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     RCFriendItem* dataItem = [RCFriendItem itemWithDicInfo:[self.searchData objectAtIndex:[indexPath row]]];
    NSString *result = [NSString stringWithFormat:@"@%@(%@)",dataItem.userName,dataItem.uid];
    NSLog(@"syp==%@",result);
    if (self.deldgate) {//-(void)didSelectUser:(NSString*)atuserinfo;
        if ([self.deldgate respondsToSelector:@selector(didSelectUser:)] ) {
            [self.deldgate didSelectUser:result];
        }
    }
    [self hideFastAtFriendView];
}
@end
