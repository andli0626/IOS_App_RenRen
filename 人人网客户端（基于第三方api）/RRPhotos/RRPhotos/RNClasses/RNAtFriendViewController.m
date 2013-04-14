 //
//  RNAtFriendViewController.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-31.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNAtFriendViewController.h"
#import "RCFriendItem.h"
#import "RCPageitem.h"
//#import "RNFriendsSearchViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface RNAtFriendViewController ()

@end

@implementation RNAtFriendViewController
@synthesize inTopSection = _inTopSection;
@synthesize markedExtendSectionView = _markedExtendSectionView;
@synthesize atFrienddelete=_atFrienddelete;
@synthesize ownerId=_ownerId;


-(void)dealloc{
    [tabview release];
    if (_ownerId) {
        [_ownerId release];
    }
    [super dealloc];
}
-(void)showAlertWithMsg:(NSString*)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"确定", @"确定") 
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}
//重写为了向mode层重新设置参数和联网method
-(void)setOwnerId:(NSNumber *)ownerId{
    if(_ownerId){
        [_ownerId release];
        _ownerId=nil;
    }
    _ownerId = [ownerId retain];
    [(RNAtFriendsModel*)self.model setOwnerId:ownerId];
    
}
-(id)initWithOwnerId:(NSNumber*)ownerid{
    self = [super init];
    if (self) {
        if (ownerid) {
            self.ownerId = ownerid;
        }
        _isSearch=NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)loadView{
    [super loadView];
    self.accessoryBar.title = NSLocalizedString(@"点名", @"点名");
    self.accessoryBar.rightButtonEnable = YES;
    [self.accessoryBar.rightButton setImage:[[RCResManager getInstance] imageForKey:@"publsih_at_navBar_done_bg"] forState:UIControlStateNormal];
   // [self.accessoryBar.rightButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchDown];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // add searchBar
    CGFloat searchbar_h = 41;
    CGRect searchbarFram =CGRectMake(0, PHONE_NAVIGATIONBAR_HEIGHT, PHONE_SCREEN_SIZE.width, searchbar_h);
    searchbar = [[RNCustomText alloc] initWithPage:searchbarFram delegat:self];
//    searchbar.layer.borderWidth  =2;  
//    searchbar.layer.cornerRadius = 10;  
//    searchbar.layer.borderColor= [[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor];
    searchbar.myTextField.returnKeyType = UIReturnKeyDone;
    searchbar.myTextField.placeholder = NSLocalizedString(@"想用@提到谁?(最多10次)", @"想用@提到谁?(最多10次)");
    UILabel *searchleftview = [[UILabel alloc] initWithFrame:CGRectMake(0, (searchbar_h-30)/2, 50, 30)];
    searchleftview.textColor = RGBCOLOR(127, 127, 127);
    [searchleftview setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    searchleftview.text=NSLocalizedString(@"@好友:", @"@好友:");
    [searchleftview setBackgroundColor:[UIColor clearColor]];
    searchbar.leftview = searchleftview;
    [searchleftview release];
//    UIImage *btnnormal = [[RCResManager getInstance] imageForKey:@"atfriend_name_bg"];
//    
//    UIImage *btnhright = [[RCResManager getInstance] imageForKey:@"publsih_at_left_bg"];
//    
    searchbar.btnNomalImage = [UIImage middleStretchableImageWithKey:@"atfriend_name_bg"];
    //[btnnormal stretchableImageWithLeftCapWidth:btnnormal.size.width/2 topCapHeight:btnnormal.size.height/2];

    searchbar.btnHeightImage = [UIImage middleStretchableImageWithKey:@"atfriend_name_bg_sl"];
    //[btnhright stretchableImageWithLeftCapWidth:btnhright.size.width/2 topCapHeight:btnhright.size.height/2];
    
    UIImage *backimage = [[RCResManager getInstance] imageForKey:@"search_basemap"];
    
    searchbar.backgroundView = [[UIImageView alloc] initWithImage:[backimage stretchableImageWithLeftCapWidth:backimage.size.width/2 topCapHeight:backimage.size.height/2]];
   
    
    [self.view addSubview:searchbar];
    
    CGFloat tabview_h = 40;
    tabview = [[UIView alloc] initWithFrame:CGRectMake(0, 
                                                               PHONE_NAVIGATIONBAR_HEIGHT+searchbar_h,
                                                               PHONE_SCREEN_SIZE.width,
                                                               tabview_h)];

    UIImageView *tab_bg = [[UIImageView alloc] initWithImage:[[RCResManager getInstance] imageForKey:@"publish_at_tab_bg"]];
    tab_bg.frame = CGRectMake(0, 0, PHONE_SCREEN_SIZE.width, tabview_h+5);
    [tabview addSubview:tab_bg];
    [tab_bg release];
    
    float btn_w = 90;

    float btn_h = 35;
    float btn_left = (PHONE_SCREEN_SIZE.width-3*btn_w)/2;
    
    if (_ownerId){
        btn_w = 130;
        btn_left = (PHONE_SCREEN_SIZE.width-2*btn_w)/2;
    }
    
    UIButton *nearlyBtn = [[UIButton alloc] init];
    nearlyBtn.tag = 101;
    nearlyBtn.frame = CGRectMake(btn_left, (tabview_h-btn_h)/2, btn_w, btn_h);
    
    [nearlyBtn setBackgroundImage:[UIImage middleStretchableImageWithKey:@"publsih_at_left_bg"] forState:UIControlStateNormal];
    [nearlyBtn setBackgroundImage:[UIImage middleStretchableImageWithKey:@"publsih_at_left_bg_hl"] forState:UIControlStateHighlighted];
    [nearlyBtn setBackgroundImage:[UIImage middleStretchableImageWithKey:@"publsih_at_left_bg_hl"] forState:UIControlStateSelected];
    if (_ownerId) {
        [nearlyBtn setTitle:NSLocalizedString(@"好友", @"好友") forState:UIControlStateNormal];
        nearlyBtn.tag = 102;
    }else {
        [nearlyBtn setTitle:NSLocalizedString(@"常用", @"常用") forState:UIControlStateNormal];
    }
    
    [nearlyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    nearlyBtn.adjustsImageWhenHighlighted = NO;
    [tabview addSubview:nearlyBtn];
    [nearlyBtn release];
    [nearlyBtn addTarget:self action:@selector(tabBtnClick:) forControlEvents:UIControlEventTouchDown];
    
    if (_ownerId == nil) {
        UIButton *normalBtn = [[UIButton alloc] init];
        normalBtn.tag = 102;
        [normalBtn setBackgroundImage:[UIImage middleStretchableImageWithKey:@"publsih_at_mid_bg"] forState:UIControlStateNormal];
        [normalBtn setBackgroundImage:[UIImage middleStretchableImageWithKey:@"publsih_at_mid_bg_hl"] forState:UIControlStateHighlighted];
        [normalBtn setBackgroundImage:[UIImage middleStretchableImageWithKey:@"publsih_at_mid_bg_hl"] forState:UIControlStateSelected];
        [normalBtn setTitle:NSLocalizedString(@"好友", @"好友") forState:UIControlStateNormal];
        [normalBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        normalBtn.selected = YES;
        normalBtn.frame = CGRectMake(btn_left+btn_w, (tabview_h-btn_h)/2, btn_w, btn_h);
        normalBtn.adjustsImageWhenHighlighted = NO;
        [normalBtn addTarget:self action:@selector(tabBtnClick:) forControlEvents:UIControlEventTouchDown];
        [tabview addSubview:normalBtn];
        [normalBtn release];
    }
    
    UIButton *pageBtn = [[UIButton alloc] init];
    pageBtn.tag = 103;
    [pageBtn setBackgroundImage:[UIImage middleStretchableImageWithKey:@"publsih_at_right_bg"] forState:UIControlStateNormal];
    [pageBtn setBackgroundImage:[UIImage middleStretchableImageWithKey:@"publsih_at_right_bg_hl"] forState:UIControlStateHighlighted];
    [pageBtn setBackgroundImage:[UIImage middleStretchableImageWithKey:@"publsih_at_right_bg_hl"] forState:UIControlStateSelected];
    [pageBtn setTitle:NSLocalizedString(@"公共主页", @"公共主页") forState:UIControlStateNormal];
    pageBtn.adjustsImageWhenHighlighted = NO;
    [pageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (_ownerId==nil) {
        pageBtn.frame = CGRectMake(btn_left+btn_w*2, (tabview_h-btn_h)/2, btn_w, btn_h);
    }else {
        pageBtn.frame = CGRectMake(btn_left+btn_w, (tabview_h-btn_h)/2, btn_w, btn_h);
    }
    
//    CGRectMake(10+btnsize.width+norbtnsize.width,
//                                 (tabview_h-pagebtnsize.height)/2,
//                                 pagebtnsize.width, 
//                                 pagebtnsize.height);
    [pageBtn addTarget:self action:@selector(tabBtnClick:) forControlEvents:UIControlEventTouchDown];
    [tabview addSubview:pageBtn];
    [pageBtn release];
    [self.view addSubview:tabview];
    
    
    CGFloat tabview_y =PHONE_NAVIGATIONBAR_HEIGHT+searchbar_h + tabview_h;    
    self.tableView.frame =CGRectMake(0, 
                                     tabview_y, 
                                     PHONE_SCREEN_SIZE.width, 
                                     PHONE_SCREEN_SIZE.height - tabview_y);
    
    [(RNAtFriendsModel*)self.model setFriendsType:_currentAtType];
    if(_ownerId)
    {
        [self.model load:NO];
    }else {
        [(RNAtFriendsModel*)self.model loadCacheData];
    }
}
-(void)customTextDidChangeSize:(RNCustomText*)customText changeToSize:(CGSize)size{
    
    CGRect tabframe =  tabview.frame;
    tabframe.origin.y = PHONE_NAVIGATIONBAR_HEIGHT+size.height;
    tabview.frame = tabframe;
    if (_isSearch) {
        tabview.hidden = YES;
        CGRect tableviewframe = self.tableView.frame;
        tableviewframe.origin.y = PHONE_NAVIGATIONBAR_HEIGHT+size.height;
        tableviewframe.size.height = PHONE_SCREEN_SIZE.height-PHONE_NAVIGATIONBAR_HEIGHT+size.height;
        self.tableView.frame = tableviewframe;        
    }else {
        tabview.hidden = NO;
        float tabview_y =PHONE_NAVIGATIONBAR_HEIGHT+5+searchbar.frame.size.height + tabframe.size.height;
        CGRect tableviewframe = self.tableView.frame;
        tableviewframe.origin.y = tabview_y;
        tableviewframe.size.height = PHONE_SCREEN_SIZE.height-tabview_y;
        self.tableView.frame = tableviewframe;  
    }
}
-(void)customTextDiddelete:(NSString*)deleteText{
    [((RNAtFriendsModel*)self.model) removeAtFriendDataForobj:deleteText];
    [self.tableView reloadData];
}
- (void)customTextDidBeginEditing:(RNCustomText *)customText{
    tabview.hidden = YES;
    CGRect tabframe =  tabview.frame;
    tabframe.origin.y = PHONE_NAVIGATIONBAR_HEIGHT+customText.frame.size.height;
    tabview.frame = tabframe;
    CGRect tableviewframe = self.tableView.frame;
    tableviewframe.origin.y = PHONE_NAVIGATIONBAR_HEIGHT+customText.frame.size.height;
    tableviewframe.size.height = PHONE_SCREEN_SIZE.height-PHONE_NAVIGATIONBAR_HEIGHT+customText.frame.size.height;
    self.tableView.frame = tableviewframe; 
}

- (BOOL)customTextShouldReturn:(RNCustomText *)customText{
    if([[((RNAtFriendsModel*)self.model) searchData] count] <=0 || [customText.myTextField.text length]<=0 || [customText.myTextField.text isEqualToString:@" "]){
        _isSearch = NO;
        [customText clearNotMatchText];
        [self.tableView reloadData];
    }
    [self customTextDidChangeSize:customText changeToSize:customText.frame.size];

    return YES;
}

- (BOOL)customText:(RNCustomText *)customText shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text{
    if (text != nil && [text length] > 0){
        _isSearch = YES;
    }
    [((RNAtFriendsModel*)self.model) search:text];
    
    return YES;
}


-(void)tabBtnClick:(UIButton*)btn{
    NSInteger type = btn.tag%100-1;
    if (_currentAtType != type ) {
        [self.tableView reloadData];
        [(RNAtFriendsModel*)self.model setFriendsType:(AtFriendType)type];
        if ((AtFriendType)type == ENormalFriendType) {
            if ([((RNAtFriendsModel*)self.model).chatPersons count]>0) {
                _currentAtType = ((RNAtFriendsModel*)self.model).friendsType;
                [self.tableView reloadData];
            }else {
                [((RNAtFriendsModel*)self.model) loadCacheData];
            }
        }else if((AtFriendType)type == EPublicFriendType){
            if ([((RNAtFriendsModel*)self.model).pagePersons count]>0) {
                _currentAtType = ((RNAtFriendsModel*)self.model).friendsType;
                [self.tableView reloadData];
            }
            [self.model load:NO];
        }else if((AtFriendType)type == ENearlyFriendType){
            if ([((RNAtFriendsModel*)self.model).nearlyatPersons count]>0) {
                _currentAtType = ((RNAtFriendsModel*)self.model).friendsType;
                [self.tableView reloadData];
            }
            [self.model load:NO];
        }
    }
    
    for (id btn in [tabview subviews]) {
        if ([btn isKindOfClass:[UIButton class]]) {
            ((UIButton*)btn).selected = NO;
        }
    }
    btn.selected = YES;
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
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
    RNAtFriendsModel *model = [[RNAtFriendsModel alloc] initWithUserId:self.ownerId];
    _currentAtType = ENormalFriendType;
    [model setFriendsType:_currentAtType];
    self.model = model;
    RL_RELEASE_SAFELY(model);
   
}

- (void)modelDidStartLoad:(RNModel *)model
{
    
}

- (void)modelDidFinishLoad:(RNModel *)model{
    //    [super modelDidFinishLoad:model];
    _currentAtType = ((RNAtFriendsModel*)self.model).friendsType;
    [_tableView reloadData];
}

- (void)model:(id)model didFailLoadWithError:(NSError*)error {
    //[super model:model didFailLoadWithError:error];
    
}

- (void)modelDidCancelLoad:(RNModel *)model
{
    
}
/*
 * 点击左边取消按钮
 * 
 */
- (void)publisherAccessoryBarLeftButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
    
    [self dismissModalViewControllerAnimated:YES];
}
/*
 * 点击右边按钮//// 完成
 * 
 */
- (void)publisherAccessoryBarRightButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
    if (self.atFrienddelete) {
        if ([self.atFrienddelete respondsToSelector:@selector(atFriendFinished:)] ) {
            [self.atFrienddelete atFriendFinished:((RNAtFriendsModel*)self.model).atFriendData];
        }
    }
    [self dismissModalViewControllerAnimated:YES];
    //    RSAppDelegate *appDelegate = (RSAppDelegate *)[UIApplication sharedApplication].delegate;
    //    [appDelegate.rootNavViewController popToViewController:self animated:YES];

    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //return [[self.model.resultDic objectForKey:@"count"] intValue];
    if (_isSearch) {
        return 1;
    }
    if (_currentAtType !=ENormalFriendType) {
        return 1;
    }else {
        return [((RNAtFriendsModel*)self.model).chatSectionPersons count] ;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (_isSearch) {
        return [((RNAtFriendsModel*)self.model).searchData count];
    }
    if(_currentAtType == EPublicFriendType){
        return [((RNAtFriendsModel*)self.model).pagePersons count];
    }else if(_currentAtType == ENormalFriendType){
        NSMutableArray* sectionArray = [[((RNAtFriendsModel*)self.model).chatSectionPersons objectAtIndex:section] objectForKey:@"personsInfo"];
        return [sectionArray count];
    }else if(_currentAtType == ENearlyFriendType){
        return [((RNAtFriendsModel*)self.model).nearlyatPersons count];;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(_currentAtType != ENormalFriendType || _isSearch){
        return 0;
    }else {
        RNFriendsSectionInfo* sectionInfo = [[((RNAtFriendsModel*)self.model).chatSectionPersons objectAtIndex:section] objectForKey:@"sectionInfo"];
        return sectionInfo.letter;
    }

}
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView 
{

    //return nil;
    NSMutableArray *indices = [NSMutableArray array];
    if (_currentAtType != ENormalFriendType) {
        return indices;
    }
    //Add the magnifying glass as the first element in the indices array
    int count = [((RNAtFriendsModel*)self.model).chatSectionPersons count];
    for(int i=0;i<count;i++){
        if([[[((RNAtFriendsModel*)self.model).chatSectionPersons objectAtIndex:i] objectForKey:@"sectionInfo"] isKindOfClass:[RNFriendsSectionInfo class]]){
            RNFriendsSectionInfo* info = [[((RNAtFriendsModel*)self.model).chatSectionPersons objectAtIndex:i] objectForKey:@"sectionInfo"];
            [indices addObject:info.letter];
        }
    }
    return indices;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //section为0时,返回searchBar
    //if(section == 0)
    //    return self.searchBar;
    
    RNFriendsSectionInfo* sectionInfo = [[((RNAtFriendsModel*)self.model).chatSectionPersons objectAtIndex:section] objectForKey:@"sectionInfo"];
    NSMutableArray* dicArray = [[((RNAtFriendsModel*)self.model).chatSectionPersons objectAtIndex:section] objectForKey:@"personsInfo"];
    NSString *title = sectionInfo.letter;
    
    if(title.length > 0){
        RNFriendsSectionView* header = [[[RNFriendsSectionView alloc] initWithTitleArray:sectionInfo.familyArray] autorelease];
        [header setExpButtonTitle:title personCount:[dicArray count]];
        header.alpha = 1.0;
        header.delegate = self;
        return header;
    }
    return nil;
}
#pragma mark - custom section view delegate
-(void)sectionHeaderView:(RNFriendsSectionView*)sectionHeaderView viewWithActionByExtendButton:(RNFriendsSectionButton*)extBtn{
    
    // 记录当前的sectionview，为了后期能收起
    self.markedExtendSectionView = sectionHeaderView;
    
    CGRect frame = sectionHeaderView.frame;
    sectionHeaderView.frame = frame;
    
    // 点击字母就滑动到顶部
    // 如果已经在顶部了，就不滑动了
    if (sectionHeaderView.expButton.open) {
        if (self.inTopSection != sectionHeaderView.expButton.indexPath.section) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:sectionHeaderView.expButton.indexPath.row inSection:sectionHeaderView.expButton.indexPath.section]
                                  atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}
-(void)sectionHeaderView:(RNFriendsSectionView*)sectionHeaderView viewWithActionByTitleButton:(RNFriendsSectionButton*)titleBtn{
    // 移动到对应cell
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:titleBtn.indexPath.row inSection:titleBtn.indexPath.section]
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
    // 载入完毕后重新记录
    self.inTopSection = sectionHeaderView.expButton.indexPath.section;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //搜索
    //if(section == 0)
    //    return self.searchBar.height;
    
    //if([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]){
    
    NSString *title = [tableView.dataSource tableView:tableView 
                              titleForHeaderInSection:section];
    if (!title.length || [title isEqualToString:@"@"]) {
        return 0;
    }
    RNFriendsSectionView* headerView = (RNFriendsSectionView*)[tableView.delegate tableView:tableView viewForHeaderInSection:section];
    return headerView.frame.size.height>28?headerView.frame.size.height:28;//CONTACT_SECTION_HEIGHT;
}
#pragma mark - Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionIndex = [indexPath section];
    NSInteger rowIndex = [indexPath row];
    static NSString *CellIdentifier = @"atfriendsCell";
    
    RNAtFriendsTableItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[[RNAtFriendsTableItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    if (_isSearch) {
        if (_currentAtType == EPublicFriendType) {
            RCPageitem* dataItem = [RCPageitem itemWithDicInfo:[((RNAtFriendsModel*)self.model).searchData objectAtIndex:rowIndex]];
            if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.pageId]) {
                dataItem.isSelected = YES;
            }
            [cell setObject:dataItem cellType:_currentAtType];
        }else{// if(_currentAtType == ENormalFriendType)
            RCFriendItem* dataItem = [RCFriendItem itemWithDicInfo:[((RNAtFriendsModel*)self.model).searchData objectAtIndex:rowIndex]];
            
            if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.uid]) {
                dataItem.selected = YES;
            }
            [cell setObject:dataItem cellType:_currentAtType];
        }
//        }else if(_currentAtType == ENearlyFriendType){
//            RCFriendItem* dataItem = [RCFriendItem itemWithDicInfo:[((RNAtFriendsModel*)self.model).searchData objectAtIndex:rowIndex]];
//            
//            if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.uid]) {
//                dataItem.selected = YES;
//            }
//            [cell setObject:dataItem cellType:_currentAtType];
//        }
        return cell;
    }
    
    if (_currentAtType == EPublicFriendType) {
        RCPageitem* dataItem = [RCPageitem itemWithDicInfo:[((RNAtFriendsModel*)self.model).pagePersons objectAtIndex:rowIndex]];
        if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.pageId]) {
            dataItem.isSelected = YES;
        }
        [cell setObject:dataItem cellType:_currentAtType];
    }else if(_currentAtType == ENormalFriendType){
        NSMutableArray* dicArray = [[((RNAtFriendsModel*)self.model).chatSectionPersons objectAtIndex:sectionIndex] 
                                    objectForKey:@"personsInfo"];
        RCFriendItem* dataItem = [RCFriendItem itemWithDicInfo:[dicArray objectAtIndex:rowIndex]];
        
        if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.uid]) {
            dataItem.selected = YES;
        }
        [cell setObject:dataItem cellType:_currentAtType];
    }else if(_currentAtType == ENearlyFriendType){
        RCFriendItem* dataItem = [RCFriendItem itemWithDicInfo:[((RNAtFriendsModel*)self.model).nearlyatPersons objectAtIndex:rowIndex]];
        if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.uid]) {
            dataItem.selected = YES;
        }
        [cell setObject:dataItem cellType:_currentAtType];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionIndex = [indexPath section];
    NSInteger rowIndex = [indexPath row];
    if (_isSearch) {
         if(_currentAtType == EPublicFriendType){
             RCPageitem* dataItem = [RCPageitem itemWithDicInfo:[((RNAtFriendsModel*)self.model).searchData objectAtIndex:rowIndex]];
             if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.pageId]) {
                 [((RNAtFriendsModel*)self.model) removeAtFriendDataForKey:dataItem.pageId ];
                 [searchbar deleteItemWithText:dataItem.pageName];
                // [searchbar changeIt];
             }else {
                 if([((RNAtFriendsModel*)self.model) addAtFriendData:dataItem.pageId value:dataItem.pageName]){
                     [searchbar addItemWithText:dataItem.pageName canRepeat:NO];
                    // [searchbar changeIt];
                 }else {
                     [self showAlertWithMsg:NSLocalizedString(@"最多只能@十个好友哦。", @"最多只能@十个好友哦。")];
                 }
             } 

         }else {//if(_currentAtType == ENormalFriendType)
             RCFriendItem* dataItem = [RCFriendItem itemWithDicInfo:[((RNAtFriendsModel*)self.model).searchData objectAtIndex:rowIndex]];
             if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.uid]) {
                 [((RNAtFriendsModel*)self.model) removeAtFriendDataForKey:dataItem.uid ];
                 [searchbar deleteItemWithText:dataItem.userName];
             }else {
                 if([((RNAtFriendsModel*)self.model) addAtFriendData:dataItem.uid value:dataItem.userName]){
                     [searchbar addItemWithText:dataItem.userName canRepeat:NO];
                 }else {
                     [self showAlertWithMsg:NSLocalizedString(@"最多只能@十个好友哦。", @"最多只能@十个好友哦。")];
                 }
             }
         }
//         }else if(_currentAtType == ENearlyFriendType){
//             RCFriendItem* dataItem = [RCFriendItem itemWithDicInfo:[((RNAtFriendsModel*)self.model).searchData objectAtIndex:rowIndex]];
//             if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.uid]) {
//                 [((RNAtFriendsModel*)self.model) removeAtFriendDataForKey:dataItem.uid ];
//                 [searchbar deleteItemWithText:dataItem.userName];
//                 //[searchbar changeIt];
//             }else {
//                 if([((RNAtFriendsModel*)self.model) addAtFriendData:dataItem.uid value:dataItem.userName]){
//                     [searchbar addItemWithText:dataItem.userName canRepeat:NO];
//                     //   [searchbar changeIt]; 
//                 }else {
//                     [self showAlertWithMsg:NSLocalizedString(@"最多只能@十个好友哦。", @"最多只能@十个好友哦。")];
//                 }
//             }
//
//             
//         }
        if (_isSearch) {
            _isSearch = NO;
            [self customTextDidChangeSize:searchbar changeToSize:searchbar.frame.size];
            [((RNAtFriendsModel*)self.model).searchData removeAllObjects];
        }
        //[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        //- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
        
        [tableView reloadData];

        return;
    }
    if(_currentAtType == EPublicFriendType){
        RCPageitem* dataItem = [RCPageitem itemWithDicInfo:[((RNAtFriendsModel*)self.model).pagePersons objectAtIndex:rowIndex]];
        if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.pageId]) {
            [((RNAtFriendsModel*)self.model) removeAtFriendDataForKey:dataItem.pageId ];
            [searchbar deleteItemWithText:dataItem.pageName];
           // [searchbar changeIt];
        }else {
            if([((RNAtFriendsModel*)self.model) addAtFriendData:dataItem.pageId value:dataItem.pageName]){
                [searchbar addItemWithText:dataItem.pageName canRepeat:NO];
            //    [searchbar changeIt];
            }else {
                [self showAlertWithMsg:NSLocalizedString(@"最多只能@十个好友哦。", @"最多只能@十个好友哦。")];
            }
        } 
    }else if(_currentAtType == ENormalFriendType) {
        NSMutableArray* dicArray = [[((RNAtFriendsModel*)self.model).chatSectionPersons objectAtIndex:sectionIndex] 
                                    objectForKey:@"personsInfo"];
        RCFriendItem* dataItem = [RCFriendItem itemWithDicInfo:[dicArray objectAtIndex:rowIndex]];
        
        if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.uid]) {
            [((RNAtFriendsModel*)self.model) removeAtFriendDataForKey:dataItem.uid ];
            [searchbar deleteItemWithText:dataItem.userName];
          //  [searchbar changeIt];
        }else {
            if([((RNAtFriendsModel*)self.model) addAtFriendData:dataItem.uid value:dataItem.userName]){
                [searchbar addItemWithText:dataItem.userName canRepeat:NO];
            //    [searchbar changeIt];
            }else {
                [self showAlertWithMsg:NSLocalizedString(@"最多只能@十个好友哦。", @"最多只能@十个好友哦。")];
            }
        }
    }else if(_currentAtType == ENearlyFriendType ){
        RCFriendItem* dataItem = [RCFriendItem itemWithDicInfo:[((RNAtFriendsModel*)self.model).nearlyatPersons objectAtIndex:rowIndex]];
        if ([((RNAtFriendsModel*)self.model) findAtFriendDataForKey:dataItem.uid]) {
            [((RNAtFriendsModel*)self.model) removeAtFriendDataForKey:dataItem.uid ];
            [searchbar deleteItemWithText:dataItem.userName];
        }else {
            if([((RNAtFriendsModel*)self.model) addAtFriendData:dataItem.uid value:dataItem.userName]){
                [searchbar addItemWithText:dataItem.userName canRepeat:NO];
            }else {
                [self showAlertWithMsg:@"最多只能@十个好友哦。"];
            }
        }

        
    }
    [tableView reloadData];
//    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end









