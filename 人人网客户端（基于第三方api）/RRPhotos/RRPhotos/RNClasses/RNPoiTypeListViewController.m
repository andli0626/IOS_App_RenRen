//
//  RNPoiTypeListViewController.m
//  RRSpring
//
//  Created by yi chen on 12-4-19.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPoiTypeListViewController.h"

@interface RNPoiTypeListViewController ()

@end

@implementation RNPoiTypeListViewController
@synthesize poiTypeArray = _poiTypeArray;
@synthesize poiTypeNameArray = _poiTypeNameArray;
@synthesize delegate = _delegate;

- (void)dealloc{
	self.poiTypeArray = nil;
	self.poiTypeNameArray = nil;
	self.delegate = nil;
	
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.poiTypeNameArray = [NSMutableArray arrayWithObjects:
								 NSLocalizedString(@"私人地点(家/床/宿舍等)", @"私人地点(家/床/宿舍等)"),
								 NSLocalizedString(@"移动交通工具上(公交/地铁等)", @"移动交通工具上(公交/地铁等)"),
								 NSLocalizedString(@"非真实存在的地点", @"非真实存在的地点"),
								 NSLocalizedString(@"真实固定的公共场所", @"真实固定的公共场所"),
								 NSLocalizedString(@"其他", @"其他"),nil];
		self.poiTypeArray = [NSMutableArray array];
		for (int i = 0; i < [self.poiTypeNameArray count]; i ++) {
			NSNumber *number = [NSNumber numberWithInt:i];
			[self.poiTypeArray addObject:number];
		}
    }
    return self;
}

- (void)loadView {
	[super loadView];
	if (self.tableView) {
		self.tableView.frame  = CGRectMake(0, 
										   CONTENT_NAVIGATIONBAR_HEIGHT,
										   PHONE_SCREEN_SIZE.width,
										   PHONE_SCREEN_SIZE.height - CONTENT_NAVIGATIONBAR_HEIGHT);

		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

		//设置标题
		self.accessoryBar.title =NSLocalizedString( @"请分类选择",  @"请分类选择");
		self.accessoryBar.rightButtonEnable = NO;
		
	}
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.poiTypeArray = nil;
	self.poiTypeNameArray = nil;
	self.delegate = nil;
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	
	return 1;
}// Default is 1 if not implemented

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (self.delegate) {
		if ([self.delegate respondsToSelector:@selector(didSelectedType:poiTypeName:)]) {
			[self.delegate didSelectedType:[self.poiTypeArray objectAtIndex:indexPath.row]
							   poiTypeName:[self.poiTypeNameArray objectAtIndex: indexPath.row]];
		}
	}
	[self dismissModalViewControllerAnimated:YES];

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [self.poiTypeNameArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	static NSString * cellIdentifier = @"poiTypeListIdentifier";
	UITableViewCell *cell = [ tableView dequeueReusableCellWithIdentifier: cellIdentifier];
	if (!cell) {
		
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault 
									 reuseIdentifier:cellIdentifier]; 
		cell.selectionStyle =  UITableViewCellSelectionStyleNone; 
	}
	cell.textLabel.text = [self.poiTypeNameArray objectAtIndex:indexPath.row];
	
	return cell;
}


/*
 * 点击左边取消按钮
 * 
 */
- (void)publisherAccessoryBarLeftButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
	[self dismissModalViewControllerAnimated:YES];
}
@end
