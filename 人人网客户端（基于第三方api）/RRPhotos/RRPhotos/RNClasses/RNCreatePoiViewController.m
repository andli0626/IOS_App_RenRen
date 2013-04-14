//
//  RNCreatePoiViewController.m
//  RRSpring
//
//  Created by yi chen on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNCreatePoiViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreFoundation/CoreFoundation.h>
//每个输入框之间的间隙

#define kLabelTextColor ( RGBCOLOR(51, 51, 51))

static const CGFloat kSpaceBetweenFields = 10;

static const CGFloat kFieldPaddingLeft = 75;
static const CGFloat kFieldPaddingRight = 20;
static const CGFloat kFieldWidth = 233;
static const CGFloat kFieldHeight = 41;

static const CGFloat kFieldFontSize = 16;

static const CGFloat kLabelFontSize  = 19;

static const CGFloat kLabelWidth = 75;
static const CGFloat kLabelHeight = 41;
static const CGFloat kLabelLeft = 9;
static const CGFloat kLabelTop = 20 + CONTENT_NAVIGATIONBAR_HEIGHT;
static const CGFloat kSpaceBetweenLabels = 10;
//最大的poi名字长度
static const NSInteger kPoiNameLengthMax = 15;
static const NSInteger kAlertCancelCreateTag = 1000;

@interface RNCreatePoiViewController ()

@end

@implementation RNCreatePoiViewController

@synthesize poiNameField = _poiNameField;
@synthesize poiAddressField = _poiAddressField;
@synthesize poiTypeField = _poiTypeField;
@synthesize poiName = _poiName;
@synthesize poiAddress = _poiAddress;
@synthesize poiType = _poiType;
@synthesize baseRequest = _baseRequest;
@synthesize query = _query;
- (void)dealloc{
	
	self.poiNameField = nil;
	self.poiAddressField = nil;
	self.poiTypeField = nil;
	self.poiName = nil;
	self.poiAddress = nil;
	self.poiType = nil;
	self.baseRequest = nil;
	self.query = nil;
	
	[super dealloc];
}

/*
 初始化信息
 @PoiInfoDic :
 request:
 name	 string	 POI的名字
 optional:
 address	 string	 POI的地址
 type	 string	 POI的类型
 lat_gps	 long	 gps纬度，缺省值为0
 lon_gps	 long	 gps经度，缺省值为0
 d	     int	 使用的是否是真实经纬度，若是，则设1，若已经使用的是偏转过的经纬度，则设为0
 */

- (id)initWithPoiInfoDic:(NSMutableDictionary *)poiInfoDic;
{
	if (self = [self init]) {
		if (poiInfoDic) {
			self.query = poiInfoDic;
		}
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		//网络请求
				
		RCBaseRequest *request = [[RCBaseRequest alloc]init];
		request.onCompletion = ^(NSDictionary * result){
			NSLog(@"%@",result);
			[self.navigationController popViewControllerAnimated:YES];
		};
		request.onError = ^(RCError *error){
			NSLog(@"%@",error.titleForError);
			[self.navigationController popViewControllerAnimated:YES];
			
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle: error.titleForError 
														   message:nil
														  delegate:nil 
												 cancelButtonTitle:NSLocalizedString(@"确定", @"确定")  
												 otherButtonTitles: nil];
			[alert show];
			[alert release];
		};
		self.baseRequest = request;
		TT_RELEASE_SAFELY(request);
    }
    return self;
}

#pragma mark - view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)loadView{
	[super loadView];
	self.view.userInteractionEnabled = YES;

	[self.view addSubview:self.poiNameField];
	[self.view addSubview:self.poiAddressField];
	[self.view addSubview:self.poiTypeField];
	
	self.accessoryBar.title = NSLocalizedString(@"创建地点", @"创建地点") ;
	[self.accessoryBar.rightButton setTitle:NSLocalizedString(@"创建", @"创建")  forState:UIControlStateNormal];
	self.accessoryBar.rightButton.enabled = NO;

	//加载自己的页面元素
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.poiNameField = nil;
	self.poiAddressField = nil;
	self.poiTypeField = nil;
	self.poiName = nil;
	self.poiAddress = nil;
	self.poiType = nil;
	self.baseRequest = nil;
	self.query = nil;
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
	地点名称输入框
 */
- (UITextField *) poiNameField{
	
	if (!_poiNameField) {
		_poiNameField = [[UITextField alloc]initWithFrame:CGRectMake(kFieldPaddingLeft,
																	20 + CONTENT_NAVIGATIONBAR_HEIGHT, 
																	kFieldWidth, 
																	kFieldHeight)];
		_poiNameField.delegate = self;
		_poiNameField.textColor = kLabelTextColor;
		_poiNameField.font = [UIFont fontWithName:MED_HEITI_FONT size:kFieldFontSize];
		_poiNameField.background = [[RCResManager getInstance]imageForKey:@"textfield_border"];
		_poiNameField.placeholder = NSLocalizedString(@"如:北京大学图书馆", @"如:北京大学图书馆") ;
		_poiNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_poiNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_poiNameField.returnKeyType = UIReturnKeyNext;
		_poiNameField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, kFieldHeight)];
		_poiNameField.leftViewMode = UITextFieldViewModeAlways;
		
		CGRect rect = CGRectMake(kLabelLeft,kLabelTop, kLabelWidth,kLabelHeight);
		UILabel *nameLabel = [[UILabel alloc]initWithFrame:rect];
		nameLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:kLabelFontSize];
		nameLabel.textColor = kLabelTextColor;
		nameLabel.shadowOffset = CGSizeMake(0, 1);
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.text = NSLocalizedString(@"名称", @"名称") ;
		[self.view addSubview:nameLabel];

		TT_RELEASE_SAFELY(nameLabel);
	}
	return _poiNameField;
}

- (UITextField *)poiAddressField{
	
	if (!_poiAddressField) {
		_poiAddressField = [[UITextField alloc]initWithFrame:CGRectMake(kFieldPaddingLeft,
																     self.poiNameField.bottom + kSpaceBetweenFields, 
																	 kFieldWidth, 
																	 kFieldHeight)];
		_poiAddressField.delegate = self;
		
		_poiAddressField.textColor = kLabelTextColor;
		_poiAddressField.font = [UIFont fontWithName:MED_HEITI_FONT size:kFieldFontSize];
		_poiAddressField.background = [[RCResManager getInstance]imageForKey:@"textfield_border"];
		_poiAddressField.returnKeyType = UIReturnKeyDone;
		_poiAddressField.placeholder = NSLocalizedString(@"如:北京市海淀区北京大学院内", @"如:北京市海淀区北京大学院内") ;
		_poiAddressField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_poiAddressField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_poiAddressField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, kFieldHeight)];
		_poiAddressField.leftViewMode = UITextFieldViewModeAlways;
		CGRect rect = CGRectMake(kLabelLeft,kLabelTop + kLabelHeight + kSpaceBetweenLabels, kLabelWidth,kLabelHeight);
		UILabel *nameLabel = [[UILabel alloc]initWithFrame:rect];
		nameLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:kLabelFontSize];
		nameLabel.textColor = kLabelTextColor;
		nameLabel.shadowOffset = CGSizeMake(0, 1);
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.text = NSLocalizedString(@"地址", @"地址") ;
		[self.view addSubview:nameLabel];
		
		TT_RELEASE_SAFELY(nameLabel);
	}
	return _poiAddressField;
}

- (UITextField *)poiTypeField{
	
	if (!_poiTypeField) {
		_poiTypeField = [[UITextField alloc]initWithFrame:CGRectMake(kFieldPaddingLeft,
																		self.poiAddressField.bottom + kSpaceBetweenFields, 
																		kFieldWidth, 
																		kFieldHeight)];

		_poiTypeField.background = [[RCResManager getInstance]imageForKey:@"textfield_border"];

		_poiTypeField.textColor = kLabelTextColor;
		_poiTypeField.font = [UIFont fontWithName:MED_HEITI_FONT size:kFieldFontSize];
		_poiTypeField.userInteractionEnabled = YES;
		_poiTypeField.delegate = self;//设置代理
		
		[_poiTypeField addTarget:self action:@selector(tapTypeField) forControlEvents:UIControlEventTouchDown];
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self
																					action:@selector(tapTypeField)];
		[tapGesture setNumberOfTapsRequired:1];
		[_poiTypeField addGestureRecognizer:tapGesture];
		TT_RELEASE_SAFELY(tapGesture);
		
		_poiTypeField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, kFieldHeight)];
		_poiTypeField.leftViewMode = UITextFieldViewModeAlways;

		_poiTypeField.text = NSLocalizedString(@"选择地点分类(选填)", @"选择地点分类(选填)") ;
		_poiTypeField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
		CGRect rect = CGRectMake(kLabelLeft,kLabelTop + kLabelHeight * 2 + kSpaceBetweenLabels * 2, kLabelWidth,kLabelHeight);
		UILabel *nameLabel = [[UILabel alloc]initWithFrame:rect];
		nameLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:kLabelFontSize];
		nameLabel.textColor = kLabelTextColor;
		nameLabel.shadowOffset = CGSizeMake(0, 1);
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.text = NSLocalizedString(@"分类", @"分类") ;
		[self.view addSubview:nameLabel];
		
		
		//下拉箭头
		UIImageView *arrowView = [[UIImageView alloc]initWithImage:[[RCResManager getInstance]imageForKey:@"textfield_arrow"]];
		arrowView.frame = CGRectMake(200, 6, arrowView.image.size.width, arrowView.image.size.height);
		arrowView.userInteractionEnabled = YES;
		
		[_poiTypeField addSubview:arrowView];
		TT_RELEASE_SAFELY(arrowView);
		TT_RELEASE_SAFELY(nameLabel);
	}
	return _poiTypeField;
}
#pragma mark - 点击poi分类输入框
- (void)tapTypeField{
	NSLog(@"cy --------poi类型输入框被点击了");
	[self.poiNameField resignFirstResponder];
	[self.poiAddressField resignFirstResponder];
	[self.poiTypeField resignFirstResponder];
	
	RNPoiTypeListViewController *rnPoiTypeController = [[RNPoiTypeListViewController alloc]init];
	[self presentModalViewController:rnPoiTypeController animated:YES];
	rnPoiTypeController.delegate = self;
	
	TT_RELEASE_SAFELY(rnPoiTypeController);
	
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	if (self.poiTypeField == textField) {
		return NO;
	}
	
	return YES;
}// return NO to disallow editing.

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	if (textField == _poiNameField) {
		if (self.poiNameField.text) {
			//过滤换行空格
			NSString *temp = [self.poiNameField.text  stringByTrimmingCharactersInSet: 
							  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if ([temp length] > 0) {
				self.accessoryBar.rightButton.enabled = YES;
			}else {
				self.accessoryBar.rightButton.enabled = NO;
			}
		}
		
	}
	return YES;
}// return NO to not change text

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	if (textField == self.poiNameField) {
		[self.poiAddressField becomeFirstResponder];
		[textField resignFirstResponder];
	}
	if (textField == self.poiAddressField) {
		[self.poiAddressField resignFirstResponder];
	}
	return YES;
}// called when 'return' key pressed. return NO to ignore.


#pragma mark - 左右按钮点击
- (void)publisherAccessoryBarLeftButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
    // 子类实现
	if ([self.poiNameField.text length] > 0) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"确定放弃创建地点吗？", @"确定放弃创建地点吗？") 
													   message:nil 
													  delegate:self
											 cancelButtonTitle:NSLocalizedString(@"取消", @"取消") 
											 otherButtonTitles:NSLocalizedString(@"确定", @"确定") ,nil];
		alert.delegate = self;
		alert.tag = kAlertCancelCreateTag;
		[alert show];
		TT_RELEASE_SAFELY(alert);
		return;
	}
	[self dismissModalViewControllerAnimated:YES];
}

/*
 * 点击右边按钮
 * 
 */
- (void)publisherAccessoryBarRightButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
    // 子类实现
	NSLog(@"cy----------创建poi");
	
	if ([self.poiNameField.text length] > kPoiNameLengthMax) {
		NSString *title = [NSString stringWithFormat:NSLocalizedString(@"名称的长度不能超过%d", @"名称的长度不能超过%d") ,kPoiNameLengthMax];
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
													   message:nil 
													  delegate:nil
											 cancelButtonTitle:NSLocalizedString(@"确定", @"确定")  
											 otherButtonTitles: nil];
		[alert show];
		TT_RELEASE_SAFELY(alert);
		return;
	}
	
	if (self.query) {
		RCMainUser *mainUser = [RCMainUser getInstance];
		[self.query setObject:self.poiNameField.text forKey:@"name"];
		[self.query setObject:mainUser.sessionKey forKey:@"session_key"];
		
		[self.baseRequest sendQuery:self.query withMethod:@"place/addPoi"];
	}
	
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (kAlertCancelCreateTag == alertView.tag) { //取消创建
		if (1 == buttonIndex) {
			[self dismissModalViewControllerAnimated: YES];
		}
	}
}

#pragma mark -  RNPoiTypeListDelegate 

- (void)didSelectedType :(NSNumber* )poiType poiTypeName : (NSString *)poiTypeName{
	self.poiTypeField.text = poiTypeName;
	self.poiType = poiType;
}
@end
