//
//  Filters.h
//  Cngram
//
//  Created by yi chen on 12-4-8.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Filters : NSObject
{
	NSArray * _object;
}
@property(nonatomic,retain)NSArray *object;

- (NSInteger) count;

- (NSString *) nameForIndex: (NSInteger) index;

- (NSString *) methodForIndex: (NSInteger) index;

- (NSString *) iconForIndex: (NSInteger) index;

@end
