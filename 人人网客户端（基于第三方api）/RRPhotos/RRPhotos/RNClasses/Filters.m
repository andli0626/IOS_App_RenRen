//
//  Filters.m
//  Cngram
//
//  Created by yi chen on 12-4-8.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "Filters.h"
#import "SBJSON.h"

@interface Filters () {
	
}
@end

@implementation Filters
@synthesize object = _object;

- (void)dealloc
{
	self.object = nil;
	[super dealloc];
}

- (id) init {
    self = [super init];
    if (self) {
        NSString * filePath = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"json"];  
        NSString * jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        self.object = [[[SBJsonParser alloc] init] objectWithString:jsonString];
    }
    return self;
}

- (NSInteger) count {
    return self.object.count;
}

- (NSString *) nameForIndex:(NSInteger)index {
//	NSLog(@"filter = %@",self);
    return [[self.object objectAtIndex:index] valueForKey:@"filterName"];
}

- (NSString *) methodForIndex:(NSInteger) index {
    return [[self.object objectAtIndex:index] valueForKey:@"filterAction"];
}

- (NSString *) iconForIndex:(NSInteger) index {
    return [[self.object objectAtIndex:index] valueForKey:@"previewImage"];
}

- (NSString *)description{

	NSString *string = [NSString stringWithFormat:@"%@",[self.object description]];
	return string;
}
@end
