//
//  TestViewController.m
//  RRSpring
//
//  Created by sheng siglea on 4/21/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "TestViewController.h"
#import "RNPhotoListModel.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithUid:(NSNumber *)uid albumId:(NSNumber *)aid{
    if (self = [self init]) {
        _userId = [uid copy];
        _albumId = [aid copy];
                _mainUser = [RCMainUser getInstance];
    }
    return self;
}
- (void)loadView{
    RN_DEBUG_LOG;
    NSLog(@"------%d---%@",self.retainCount,self.navigationController);

    [super loadView];
    button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
    [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(btn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self requestAlbumInfo];
}
#pragma request album info
- (void)requestAlbumInfo{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableDictionary* dics = [NSMutableDictionary dictionary];
    [dics setObject:_mainUser.sessionKey forKey:@"session_key"];
    [dics setObject:_albumId forKey:@"aid"];
    [dics setObject:_userId forKey:@"uid"];
    mReqAssistant = [[RCGeneralRequestAssistant alloc] init];
    __block typeof(self) bself = self;

    mReqAssistant.onCompletion = ^(NSDictionary* result){
        if (result) {
            NSLog(@".....%d",bself.retainCount);
            [bself->button setTitle:[NSString stringWithFormat:@"x%@",result] forState:UIControlStateNormal];
        }

    };
    mReqAssistant.onError = ^(RCError* error) {
        NSLog(@"error....%@",error.titleForError);
    };
    [mReqAssistant sendQuery:dics withMethod:@"photos/getAlbums"];
    [pool release];
}
- (void)btn:(id)sender{
    RN_DEBUG_LOG;
    NSLog(@"------%d---%@",self.retainCount,self.navigationController);
    [mReqAssistant release];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc{
    RN_DEBUG_LOG;
        [button release];
    NSLog(@"------%d---%@",self.retainCount,self.navigationController);
    [super dealloc];
}
//- (void)createModel {
//    RNPhotoListModel *model = [[RNPhotoListModel alloc] initWithAid:[NSNumber numberWithInt:0]  withUid:[NSNumber numberWithInt:0]];
//    self.model = model;
//    RL_RELEASE_SAFELY(model);
//}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
