//
//  RNPublishBaseViewController.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBaseViewController.h"

@interface RNPublishBaseViewController ()

@end

@implementation RNPublishBaseViewController
@synthesize model = _model;
@synthesize tableView = _tableView;
@synthesize accessoryBar=_accessoryBar;
- (void)dealloc {
    //self.navBar = nil;
    self.tableView = nil;
    [_model.delegates removeObject:self];
    RL_RELEASE_SAFELY(_model);
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self createModel];
        //[self.view setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)loadView {
    [super loadView];
    //初始化title
    CGRect viewframe = CGRectMake(0, 
                                  0,
                                  PHONE_SCREEN_SIZE.width,
                                  CONTENT_NAVIGATIONBAR_HEIGHT);
    // 设置navigationBar 
    RNPublisherAccessoryBar * titlebar = [[RNPublisherAccessoryBar alloc] initWithFrame:viewframe];
    [self.view addSubview:titlebar];
    self.accessoryBar = titlebar;
    [titlebar release];
    self.accessoryBar.publisherBarDelegate = self;
    //初始化tableView
    CGRect rect = CGRectMake(0, CONTENT_NAVIGATIONBAR_HEIGHT, 320, PHONE_SCREEN_SIZE.height - CONTENT_NAVIGATIONBAR_HEIGHT);
    UITableView *tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [tableView release];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    return 60.0;
}

// 加载数据
- (void)load:(BOOL)more {
    [_model load:more];
}

// 创建Model，子类必须实现
- (void)createModel {
    //子类实现
}

// 重写set方法
- (void)setModel:(RNModel *)model {
    if (_model == model) {
        return;
    }
    
    if (_model != nil) {
        [_model.delegates removeObject:self];
        RL_RELEASE_SAFELY(_model);
    }
    
    _model = [model retain];
    [_model.delegates addObject:self];
}

#pragma mark - RNModelDelegate
// 开始
- (void)modelDidStartLoad:(RNModel *)model {
    // 子类实现
}

// 完成
- (void)modelDidFinishLoad:(RNModel *)model {
    // 子类实现
}

// 错误处理
- (void)model:(RNModel *)model didFailLoadWithError:(RCError *)error {
    // 子类实现
}

// 取消
- (void)modelDidCancelLoad:(RNModel *)model {
    // 子类实现
}
/*
 * 点击左边取消按钮
 * 
 */
- (void)publisherAccessoryBarLeftButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
    // 子类实现
}
/*
 * 点击右边按钮
 * 
 */
- (void)publisherAccessoryBarRightButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
    // 子类实现
}

@end
