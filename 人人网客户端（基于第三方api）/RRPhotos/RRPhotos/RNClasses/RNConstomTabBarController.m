//
//  RNConstomTabBarController.m
//  RRPhotos
//
//  Created by yi chen on 12-3-28.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RNConstomTabBarController.h"

@implementation RNConstomTabBarController

@synthesize currentSelectedIndex;
@synthesize buttons;

- (void)viewDidAppear:(BOOL)animated{
	slideBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"publish_expression_sel@2x.png"]];
	[self hideRealTabBar];
	[self customTabBar];//显示自定义的TabBar
}

- (void)hideRealTabBar{
	for(UIView *view in self.view.subviews){
		if([view isKindOfClass:[UITabBar class]]){
			view.hidden = YES;
			break;
		}
	}
}

- (void)customTabBar{
	UIImageView *imgView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"main_cell_sel_bg.png"]];
//	imgView.frame = CGRectMake(0, 425, imgView.image.size.width, imgView.image.size.height);
	
	imgView.frame = CGRectMake(0, 425, imgView.image.size.width, imgView.image.size.height);
	[self.view addSubview:imgView];
	slideBg.frame = CGRectMake(-30, self.tabBar.frame.origin.y, slideBg.image.size.width, slideBg.image.size.height);
	
	//创建按钮
	int viewCount = self.viewControllers.count > 5 ? 5 : self.viewControllers.count;
	self.buttons = [NSMutableArray arrayWithCapacity:viewCount];
	double _width = 320 / viewCount;
	double _height = self.tabBar.frame.size.height;
	for (int i = 0; i < viewCount; i++) {
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = CGRectMake(i*_width,self.tabBar.frame.origin.y, _width, _height);
		[btn addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
		btn.tag = i;
		[self.buttons addObject:btn];
		[self.view  addSubview:btn];
		[btn release];
	}
	[self.view addSubview:slideBg];
	UIImageView *imgFront = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"publish_expression_sel@2x.png"]];
	imgFront.frame = imgView.frame;
	[self.view addSubview:imgFront];
	[imgFront release];
	[imgView release];
	[self selectedTab:[self.buttons objectAtIndex:0]];
	
}

- (void)selectedTab:(UIButton *)button{
	if (self.currentSelectedIndex == button.tag) {
		
	}
	self.currentSelectedIndex = button.tag;
	self.selectedIndex = self.currentSelectedIndex;
	[self performSelector:@selector(slideTabBg:) withObject:button];
}

- (void)slideTabBg:(UIButton *)btn{
	[UIView beginAnimations:nil context:nil];  
	[UIView setAnimationDuration:0.20];  
	[UIView setAnimationDelegate:self];
	slideBg.frame = CGRectMake(btn.frame.origin.x - 30, btn.frame.origin.y, slideBg.image.size.width, slideBg.image.size.height);
	[UIView commitAnimations];
}

- (void) dealloc{
	[slideBg release];
	[buttons release];
	[super dealloc];
}
@end