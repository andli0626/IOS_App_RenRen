//
//  RNPhotoListModel.m
//  RRSpring
//
//  Created by sheng siglea on 4/5/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNPhotoListModel.h"

@implementation RNPhotoListModel

@synthesize title = _title;
@synthesize userId = _userId;
@synthesize albumId = _albumId;

-(id)init{
    if (self = [super init]) {
        self.method = @"photos/get";
    }
    return self;
}
-(id)initWithAid:(NSNumber *)aid withUid:(NSNumber *)uid{
    if (self = [self init]) {
        self.albumId = aid;
        self.userId = uid;
    }
    return self;
}
-(RNPhotoItem *)photoItemForIndex:(NSUInteger)index{
    if (![NSObject isEmptyContainer:self.items] 
        && index < [self.items count] ) {
        return (RNPhotoItem *)[self.items objectAtIndex:index];
    } 
    return nil;
}
- (void)load:(BOOL)more {
    [_query setObject:self.userId forKey:@"uid"];
    [_query setObject:self.albumId forKey:@"aid"];
    [_query setObject:[NSNumber numberWithInt:self.pageSize] forKey:@"page_size"]; 
    [_query setObject:[NSNumber numberWithInt:1] forKey:@"with_lbs"];
    [super load:more];
}
- (void)dealloc{
    self.title = nil;
    self.userId = nil;
    self.albumId = nil;
    [super dealloc];
}
#pragma mark - 网络回调
- (void)didStartLoad {
    [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
}

- (void)didFinishLoad:(id)result {
    [super didFinishLoad:result];
    self.result = result;
    self.totalItem = [result intForKey:@"count" withDefault:0];
    self.title = [result stringForKey:@"album_name" withDefault:@""];
    _totalPage = (self.totalItem + self.pageSize - 1)/self.pageSize;   
    NSArray *photoArr = [result objectForKey:@"photo_list"];
    for (NSDictionary *dict in photoArr) {
        RNPhotoItem *item = [[RNPhotoItem alloc] initWithDictionary:dict];
        [self.items addObject:item];
        [item release];
    }
    if ([self.items count] >= self.totalItem) {
        self.currentPageIdx = _totalPage;
    }
    [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}


- (void)didFailLoadWithError:(RCError *)error {
    [_delegates perform:@selector(model:didFailLoadWithError:) withObject:self
             withObject:error];
}

- (void)didCancelLoad {
    [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}
@end
