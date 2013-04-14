//
//  RNAlbumListViewController.m
//  RRSpring
//
//  Created by sheng siglea on 4/11/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNAlbumListViewController.h"

@implementation RNAlbumListViewController

- (void)dealloc{
    [super dealloc];
    [_arrAlbums release];
}
- (void)loadView
{
    [super loadView];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 
															   0, 
                                                               320, 460 - CONTENT_NAVIGATIONBAR_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _arrAlbums = [[NSMutableArray alloc] initWithCapacity:10];
    [self.view addSubview:_tableView];
    [_tableView release];
    
//    [self.navBar addExtendButtonWithTarget:self
//                     touchUpInSideSelector:@selector(reqAlbums)
//                               normalImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_more"]
//                          highlightedImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_more"]];

}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self performSelectorInBackground:@selector(reqAlbums) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];

}

#pragma mark - reqAlbums
- (void)reqAlbums{
    NSLog(@"_____%s------%d",__FUNCTION__,__LINE__);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    RCMainUser *_userInfo = [RCMainUser getInstance];
    if (_userInfo.sessionKey) {
        NSMutableDictionary* dics = [NSMutableDictionary dictionary];
        [dics setObject:_userInfo.sessionKey forKey:@"session_key"];
        [dics setObject:_userInfo.userId forKey:@"uid"];//439643362
//        [dics setObject:@"439643362" forKey:@"uid"];
        [dics setObject:[NSNumber numberWithInt:160] forKey:@"page_size"];
        RCGeneralRequestAssistant *mReqAssistant = [RCGeneralRequestAssistant requestAssistant];
        mReqAssistant.onCompletion = ^(NSDictionary* result){
            NSLog(@"albums ... %@",result);
            if (result) {
                [_arrAlbums removeAllObjects];
                [_arrAlbums addObjectsFromArray:[result objectForKey:@"album_list"]];
                [_tableView reloadData];
            }
        };
        mReqAssistant.onError = ^(RCError* error) {
            NSLog(@"req error :%@",error);
        };
        [mReqAssistant sendQuery:dics withMethod:@"photos/getAlbums"];
    }
    [pool release];
}
#pragma tableviewdelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *aid = [[_arrAlbums objectAtIndex:indexPath.row] objectForKey:@"id"];
    NSString *uid = [[_arrAlbums objectAtIndex:indexPath.row] objectForKey:@"user_id"];
    RNAlbumWaterViewController *aw = indexPath.row % 2 == 0 ?[[RNAlbumWaterViewController alloc] initWithUid:(NSNumber *)uid albumId:(NSNumber *)aid]:
    [[RNAlbumWaterViewController alloc] initWithUid:uid albumId:aid shareId:nil shareUid:nil];
	aw.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:aw animated:YES];
    [aw release];
    RN_DEBUG_LOG;
     NSLog(@"------%d---%@",aw.retainCount,self.navigationController);
//    TestViewController *tc = [[TestViewController alloc] initWithUid:(NSNumber *)uid albumId:(NSNumber *)aid];
//    [self.navigationController pushViewController:tc animated:YES];
//    [tc release];
//    RN_DEBUG_LOG;
//     NSLog(@"------%d---%@",tc.retainCount,self.navigationController);
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrAlbums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"albumcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	} 
    cell.textLabel.text = [NSString stringWithFormat:@"%@_%@_%@",
                           [[_arrAlbums objectAtIndex:indexPath.row] objectForKey:@"size"],
                           [[_arrAlbums objectAtIndex:indexPath.row] objectForKey:@"title"],
                           [[_arrAlbums objectAtIndex:indexPath.row] objectForKey:@"visible"]];
    if ( [[[_arrAlbums objectAtIndex:indexPath.row] objectForKey:@"has_password"] intValue] == 1) {
        cell.textLabel.textColor = [UIColor redColor];
    }else {
        cell.textLabel.textColor = [UIColor blackColor];           
    }

    
    return cell;
}
@end
