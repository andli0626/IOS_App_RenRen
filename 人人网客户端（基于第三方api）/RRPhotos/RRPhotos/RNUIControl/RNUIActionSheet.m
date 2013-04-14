//
//  RNUIActionSheet.m
//  RRSpring
//
//  Created by sheng siglea on 4/15/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNUIActionSheet.h"

@implementation RNUIActionSheet

- (id)initWithTitle:(NSString *)title{
    if (self = [super initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]) {
        _buttonActionHandler = [[NSMutableArray alloc] init];
        self.delegate = self;
    }
    return self;
}
- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle cancelButtonBlock:(RNUIActionSheetBlock)block{
    if(self = [super initWithTitle:title delegate:nil cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles:nil]){
        _buttonActionHandler = [[NSMutableArray alloc] init];
        self.delegate = self;
        [_buttonActionHandler insertObject:Block_copy(block) atIndex:self.cancelButtonIndex];
    }
    return self;
}
- (NSInteger)addButtonWithTitle:(NSString *)title withBlock:(RNUIActionSheetBlock)block{
    NSInteger index = [self addButtonWithTitle:title];
    [_buttonActionHandler insertObject:Block_copy(block) atIndex:index];
    return index;
}

#pragma UIActionSheetDelegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    RNUIActionSheetBlock block = [_buttonActionHandler objectAtIndex:buttonIndex];
    if (block) {
        block(buttonIndex);
    }
}




@end
