//
//  RNBaseViewController.m
//  RRSpring
//
//  Created by hai zhang on 2/20/12.
//  Copyright (c) 2012 Renn. All rights reserved.
//

#import "RNBaseViewController.h"

@implementation RNBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    
    return self;
}

- (void)changeSkinAction:(id)sender {
    // 子类去实现
}

@end
