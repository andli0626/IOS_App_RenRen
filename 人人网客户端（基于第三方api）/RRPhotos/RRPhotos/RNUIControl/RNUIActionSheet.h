//
//  RNUIActionSheet.h
//  RRSpring
//
//  Created by sheng siglea on 4/15/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//
typedef void (^RNUIActionSheetBlock)(NSInteger index);
#import <UIKit/UIKit.h>

@interface RNUIActionSheet : UIActionSheet<UIActionSheetDelegate>{
    NSMutableArray *_buttonActionHandler;
}

- (id)initWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle cancelButtonBlock:(RNUIActionSheetBlock)block;
- (NSInteger)addButtonWithTitle:(NSString *)title withBlock:(RNUIActionSheetBlock)block;
@end
