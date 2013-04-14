//
//  ImageProcessingViewController.m
//  ImageProcessing
//
//  Created by yi chen on 12-3-27.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "ImageProcessingViewController.h"
#import "ImageUtil.h"

@implementation ProcessingImageView
@synthesize delegate;


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([(NSObject*)delegate respondsToSelector:@selector(tapOnCallback:)])
	{
		[delegate tapOnCallback:self];
	}
}
@end

#pragma mark -

@implementation ImageProcessingViewController
@synthesize startItem,segc,saveItem,imageV,toolbar,navBar;
@synthesize currentImage;
@synthesize pickPhotoHelper = _pickPhotoHelper;
- (void)dealloc 
{
	self.startItem = nil;
	self.segc = nil;
	self.imageV = nil;
	self.toolbar = nil;
	self.navBar = nil;
	self.currentImage = nil;
	
	[super dealloc];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder])
	{
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		
	}
	return self;
}

- (void)loadView{
	[super loadView];
	
	startItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"publisher_photo.png"]
												style: UIBarButtonItemStyleBordered target:self action:@selector(begin:)];
	[self.navigationItem setLeftBarButtonItem:startItem];
	
	saveItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navigation_extend_icon.png"]
											   style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
	[self.navigationItem setRightBarButtonItem:saveItem];
	
	toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 33)];

	NSArray *toolNames = [NSArray arrayWithObjects:@"正常", @"黑白",@"漫画",@"波普",@"复古", @"扫描线",nil];
	segc = [[UISegmentedControl alloc]initWithItems:toolNames];
	segc.segmentedControlStyle = UISegmentedControlStyleBar;//set style
	[segc addTarget:self action:@selector(effectChange:) forControlEvents:UIControlEventValueChanged];
	// wrap the UISegmentedControl in a UIBarButtonItem before dropping onto a UIToolbar
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:segc];
	
	[toolbar setItems:[NSArray arrayWithObjects:buttonItem, nil]];
	
	imageV = [[ProcessingImageView alloc]initWithFrame://当前操作的照片
			CGRectMake(0, -64, self.view.size.width,  self.view.size.height)];
	[imageV setBackgroundColor:[UIColor blueColor]];
	[self.view addSubview:imageV];
	[self.view addSubview:toolbar]; //工具栏盖在图片上方
	
	RNPickPhotoHelper *help = [[RNPickPhotoHelper alloc]init];
	self.pickPhotoHelper = help;
	TT_RELEASE_SAFELY(help);
}


-(void)viewDidLoad
{	
	[super viewDidLoad];
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
	imageV.delegate = self;
	imageV.userInteractionEnabled = YES;
	show = YES;
}

- (void)viewDidUnLoad 
{
	self.startItem = nil;
	self.segc = nil;
	self.imageV = nil;
	self.toolbar = nil;
	self.navBar = nil;
	[super viewDidLoad];
}


#pragma mark - start button action
-(void)begin:(id)sender
{
	UIActionSheet *ac = nil;
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{//如果存在相机,则可以拍照
		ac = [[UIActionSheet alloc] initWithTitle:@"- 照片选择 -" delegate:self cancelButtonTitle:@"取消"
								destructiveButtonTitle:nil otherButtonTitles:@"照片库",@"拍照",nil];
	}
	else 
	{//如果不存在相机，则照片只能从相片库里面选取
		ac = [[UIActionSheet alloc] initWithTitle:@"- 照片选择 -" delegate:self cancelButtonTitle:@"取消" 
											 destructiveButtonTitle:nil otherButtonTitles:@"照片库",nil];
	}
	ac.actionSheetStyle = UIActionSheetStyleDefault;
	

	[ac showInView:self.view.window];//用window 否则最后一个取消按钮会被tabbar 挡住
	[ac release];
}

#pragma mark image effect change delegate
-(void)effectChange:(id)sender
{
	UISegmentedControl *sg = (UISegmentedControl*)sender;
	if(currentImage)
	{
		UIImage *outImage = nil;
		if(sg.selectedSegmentIndex == 0)
		{
			self.imageV.image = currentImage;
		}
		
		if(sg.selectedSegmentIndex == 1)
		{
			outImage = [ImageUtil blackWhite:currentImage];
		}
		if(sg.selectedSegmentIndex == 2)
		{
			outImage = [ImageUtil cartoon:currentImage];
		}
		if(sg.selectedSegmentIndex == 3)
		{
			outImage = [ImageUtil bopo:currentImage];
		}
		if(sg.selectedSegmentIndex == 4)
		{
			outImage = [ImageUtil memory:currentImage];
		}
		if(sg.selectedSegmentIndex == 5)
		{
			outImage = [ImageUtil scanLine:currentImage];
		}
		if(outImage)
		{
			self.imageV.image = outImage;
		}
	}
}

- (void) image: (UIImage *)image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo;
{
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:@"保存成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
	[al show];
	[al release];
	self.saveItem.enabled = YES;
}

-(void)save:(id)sender
{
	if(self.imageV.image)
	{
		self.saveItem.enabled = NO;
		UIImageWriteToSavedPhotosAlbum(self.imageV.image, self,@selector(image:didFinishSavingWithError:contextInfo:),NULL); 
	}
}

-(void)snap:(id)sender
{
	if(imagePickerController)
	{
		[imagePickerController takePicture];
	}
}

-(void)close:(id)sender
{
	if(imagePickerController)
	{
		[self dismissModalViewControllerAnimated:YES];
		[imagePickerController release];
	}
}
#pragma mark - 接触图片 隐藏工具栏和导航栏
-(void)tapOnCallback:(ProcessingImageView*)imageView
{
	[UIView beginAnimations:@"aa" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	if(show)
	{
		self.toolbar.alpha = 0.0;

		self.navigationController.navigationBar.hidden = YES;
	}
	else 
	{
		self.toolbar.alpha = 1.0;
		
		self.navigationController.navigationBar.hidden = NO;
	}
	[UIView commitAnimations];
	show = !show;
}

#pragma mark - sheet对应操作，拍照，取照片
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//	imagePickerController = [[UIImagePickerController alloc] init];
//	imagePickerController.delegate = self;
//	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//	{ //如果存在相机
//		if(buttonIndex == 0)
//		{
//			imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//			[self presentModalViewController:imagePickerController animated:YES];
//		}
//		if(buttonIndex == 1) 
//		{
//			UIView *cameraView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 400)];
//			cameraView.backgroundColor = [UIColor clearColor];
//			cameraView.autoresizesSubviews = YES;
//			
//			UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, cameraView.frame.size.height-50, cameraView.frame.size.width, 50)];
//			bottomBar.backgroundColor = [UIColor whiteColor];
//			bottomBar.autoresizesSubviews = YES;
//			
//			UIButton *snapBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//			[snapBtn setTitle:@"拍照xx" forState:UIControlStateNormal];
//			snapBtn.frame = CGRectMake(cameraView.frame.size.width / 2 - 30,9.0 , 60.0, 33.0);
//			[snapBtn addTarget:self action:@selector(snap:) forControlEvents:UIControlEventTouchUpInside];
//			
//			UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//			[closeBtn setTitle:@"取消xx" forState:UIControlStateNormal];
//			closeBtn.frame = CGRectMake(bottomBar.frame.size.width-60.0-5.0, 9.0, 60.0, 33.0);
//			[closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
//			
//			[bottomBar addSubview:snapBtn]; 
//			[bottomBar addSubview:closeBtn];
//			[cameraView addSubview:bottomBar];
//			[bottomBar release];
//			
//			imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//			imagePickerController.showsCameraControls = NO; //是否显示标准的拍照界面
//			imagePickerController.cameraOverlayView = cameraView;
//			[cameraView release];
//			
//			[self presentModalViewController:imagePickerController animated:YES];
//		}
//	}
//	else 
//	{
//		if(buttonIndex == 0)
//		{
//			imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//			[self presentModalViewController:imagePickerController animated:YES];
//		}
//	}
	
	
		if(buttonIndex == 0)
		{
			[self.pickPhotoHelper pickPhotoWithSoureType:UIImagePickerControllerSourceTypePhotoLibrary];
		}
		if(buttonIndex == 1) 
		{
			[self.pickPhotoHelper pickPhotoWithSoureType:UIImagePickerControllerSourceTypeCamera];
		}
	
	
}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:@"public.image"])
	{
		UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
		NSLog(@"found an image");
		
		UIImage *resizedImg = [ImageUtil image:image fitInSize:CGSizeMake(320.0, 480.0)];
		currentImage = [resizedImg retain];
		self.imageV.image = resizedImg;
	}
	//picker.cameraViewTransform = CGAffineTransformIdentity;
	[picker release];
	[self.segc setSelectedSegmentIndex:0];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker release];
	[self dismissModalViewControllerAnimated:YES];
}
@end
