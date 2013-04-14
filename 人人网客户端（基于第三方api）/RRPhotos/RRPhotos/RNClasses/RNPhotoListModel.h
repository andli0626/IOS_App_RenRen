//
//  RNPhotoListModel.h
//  RRSpring
//
//  Created by sheng siglea on 4/5/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNPageModel.h"
#import "RNPhotoItem.h"

@interface RNPhotoListModel : RNPageModel{
    /**
     * 相册标题
     */
    NSString* _title;
    /**
     * 相册所有着
     */
	NSNumber *_userId;
    /**
     * 相册id
     */
    NSNumber *_albumId;
}

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSNumber* userId;
@property (nonatomic, copy) NSNumber* albumId;

-(id)initWithAid:(NSNumber *)aid withUid:(NSNumber *)uid;
-(RNPhotoItem *)photoItemForIndex:(NSUInteger)index;

@end