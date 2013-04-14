//
//  RNCustomText.m
//  SYPProject
//
//  Created by 玉平 孙 on 12-1-3.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNCustomText.h"
#import <QuartzCore/QuartzCore.h>

#define BASE_FONT               15

#define TField_X                6
#define TField_Y                6
#define TField_InitWidth        300
#define TField_InitHeight       26


@implementation RNCustomText
@synthesize btnNomalImage;
@synthesize btnHeightImage;

@synthesize backgroundView=_backgroundView;
@synthesize leftview;
@synthesize myTextField;
@synthesize myTextArray,stringOfSelectionBut,myButtonArray;
@synthesize isDeleteButton,isShouldBeDelete;
@synthesize scrollFrame;
@synthesize textdelegate;
@synthesize maxHeight=_maxHeight;

#pragma mark - initWithPage
- (id)initWithPage:(CGRect)frame delegat:(id)delegate
{
    self = [super initWithFrame:frame];
    self.scrollFrame = frame;
    if (self) {
        // Initialization code
        
        changeIt_Width  = TField_X;
        changeIt_Height = TField_Y;
        
        self.showsHorizontalScrollIndicator = NO;
        self.isDeleteButton = NO;
        
        self.myTextArray          = [[NSMutableArray alloc] init];
        self.myButtonArray        = [[NSMutableArray alloc] init];
        self.stringOfSelectionBut = [[NSString alloc] init];
        
       // [self setBackgroundColor:[UIColor whiteColor]];
        self.myTextField = [[UITextField alloc] 
                                    initWithFrame:CGRectMake(TField_X,TField_Y, TField_InitWidth, TField_InitHeight)];
        [self.myTextField setBackgroundColor:[UIColor clearColor]];
        [self.myTextField setDelegate:self];
        self.myTextField.clipsToBounds = NO;
        self.myTextField.leftView = nil;
        [self addSubview:self.myTextField];
        self.textdelegate = delegate;
        self.maxHeight = PHONE_SCREEN_SIZE.height- 250-frame.origin.y;//250表示中文输入法的高度
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setBackgroundView:(UIImageView *)backgroundView{
    if (backgroundView == nil) {
        if (_backgroundView) {
            [_backgroundView removeFromSuperview];
            [_backgroundView release];
        }
        return;
    }
    if (_backgroundView == backgroundView) {
        return;
    }
    if (_backgroundView) {
        [_backgroundView removeFromSuperview];
        [_backgroundView release];
    }
    _backgroundView = [backgroundView retain];
    [self insertSubview:self.backgroundView atIndex:0];
    [self changeBackground:CGSizeMake(self.frame.size.width, self.frame.size.height)];
}
-(void)changeBackground:(CGSize)changetosize{
    CGRect backFrame = self.backgroundView.frame;
    backFrame.size.width = changetosize.width;
    backFrame.size.height = changetosize.height;
    self.backgroundView.frame = backFrame;
}


#pragma mark - create a Button for resignResponder event

- (void) resResponderAct{
    [self.myTextField resignFirstResponder];
}

#pragma mark - changeIt
- (void) changeIt {
    //ScroView clear
    [self resumeScrollView];
    NSString * tmpStr = nil;
    if ( 0 < [self.stringOfSelectionBut length] ) { 
        NSInteger tmpIndex = [self.myTextArray indexOfObject:self.stringOfSelectionBut] ;
        tmpStr = [self.myTextArray objectAtIndex:tmpIndex];
    }
    
    if ( self.isShouldBeDelete ) {//current selection of button is not null.
        self.isShouldBeDelete = NO;
        //通知外部删除联系人
        if (textdelegate) {//customTextDidChangeSize:(RNCustomText*)customText changeToSize:(CGSize)size
            if ([textdelegate respondsToSelector:@selector(customTextDiddelete:)] ) {
                [textdelegate customTextDiddelete:self.stringOfSelectionBut ];
            }
        }
        [self.myTextArray removeObject:self.stringOfSelectionBut]; 
        self.stringOfSelectionBut = @"";
    }
    
    [self.myButtonArray removeAllObjects];
    [self.leftview removeFromSuperview];
    if ([self.myTextArray count]>0) {
        changeIt_Width = TField_X + self.leftview.frame.size.width;
        [self addSubview:self.leftview];
    }else {
        changeIt_Width = TField_X;
    }
    
    
    for (int i = 0 ; i < self.myTextArray.count; i++) {
        NSString * butItemText = [self.myTextArray objectAtIndex:i];
        UIFont *baseFone     = [UIFont systemFontOfSize:BASE_FONT];
        CGSize size = [butItemText sizeWithFont:baseFone constrainedToSize:CGSizeMake(200, 1000) lineBreakMode:UILineBreakModeWordWrap];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button setTitle:butItemText forState:UIControlStateNormal];
        [button setBackgroundImage:self.btnNomalImage forState:UIControlStateNormal];
        [button setBackgroundImage:self.btnHeightImage forState:UIControlStateHighlighted];
        [button setBackgroundImage:self.btnHeightImage forState:UIControlStateSelected];
        if ( [button.titleLabel.text isEqualToString:tmpStr] ) {
            button.selected = YES;
        } else {
            //button.backgroundColor = [UIColor colorWithRed:0.4549 green:0.7176 blue:0.9373 alpha:1];
            button.selected = NO;
        }
        button.layer.cornerRadius = 10;
        button.clipsToBounds = YES;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        button.titleLabel.font = [UIFont systemFontOfSize:BASE_FONT];
        [button addTarget:self action:@selector(deleteButton:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //set frame for Button
		if (changeIt_Width + size.width+10>= 300/*275*/) {
			changeIt_Width = TField_X;
            changeIt_Height = (15.0f > size.height) ? changeIt_Height+size.height+18 : changeIt_Height+15+18;
		}
        button.frame = CGRectMake(changeIt_Width, changeIt_Height, size.width+18, TField_InitHeight);
        
        [self addSubview:button];
        [self.myButtonArray addObject:button];
        
		changeIt_Width += size.width+23;
		
        //set frame for TextField.
        if ( i == [self.myTextArray count]-1 ) {
            float tfX = button.frame.origin.x + button.frame.size.width + 5 ;
            //FullText width is 195+105.
            if ( 300 <= button.frame.origin.x || 0 >= 300 - tfX ) {
                changeIt_Height = (15.0f > size.height) ? changeIt_Height+size.height+18 : changeIt_Height+15+18;
                [self.myTextField setFrame:CGRectMake(TField_X,changeIt_Height, TField_InitWidth, TField_InitHeight)];
            } else {
                [self.myTextField setFrame:CGRectMake(tfX, changeIt_Height, TField_InitWidth-tfX, TField_InitHeight)];
            }
        }
    }
    
    if ( 0 == [self.myTextArray count] ) {
        [self.myTextField setFrame:CGRectMake(TField_X,changeIt_Height, TField_InitWidth, TField_InitHeight)];
    }
    
    //receiver: 输入的字符串
    self.myTextField.text = @" ";
    //    self.stringOfSelectionBut = @"";
    self.scrollEnabled = NO;
    //定义scrollview高度
//    self.frame = CGRectMake(5, 55, 315, changeIt_Height +32);
    self.frame = CGRectMake(self.scrollFrame.origin.x, self.scrollFrame.origin.y, self.scrollFrame.size.width, changeIt_Height+32);
    if (self.frame.size.height >= self.maxHeight/*NextController's height*/) {
        CGRect myfram = self.frame;
        myfram.size.height = self.maxHeight;
        self.frame =myfram;// CGRectMake(TField_X, 0, TField_InitWidth, 199-30);
        self.scrollEnabled = YES;
        self.showsVerticalScrollIndicator = YES;
        [self setContentOffset:CGPointMake(0, changeIt_Height-138)];
    }
    self.contentSize = CGSizeMake(320, changeIt_Height+35);
    [self addSubview:self.myTextField];
    //通知外部自身大小变化
    if (textdelegate) {//customTextDidChangeSize:(RNCustomText*)customText changeToSize:(CGSize)size
        if ([textdelegate respondsToSelector:@selector(customTextDidChangeSize: changeToSize:)] ) {
            [textdelegate customTextDidChangeSize:self changeToSize:CGSizeMake(self.frame.size.width, changeIt_Height+35)];
        }
    }
    [self changeBackground:CGSizeMake(self.frame.size.width, changeIt_Height+35)];

}

#pragma mark - resumeScrollView
- (void) resumeScrollView {
    self.frame = CGRectMake(self.scrollFrame.origin.x, self.scrollFrame.origin.y, self.scrollFrame.size.width, changeIt_Height+32);
	changeIt_Width = 6;
	changeIt_Height = 6;
	for(UIView *subview in [self subviews]){
		if([[subview class] isSubclassOfClass:UIButton.class]){
			UIButton *tipsButton = (UIButton *)subview;
			[tipsButton removeFromSuperview];
		}
	}
}

#pragma mark - delete the custom button
-(IBAction)deleteButton:(id)sender{
	
    self.isDeleteButton   = YES;
    self.isShouldBeDelete = YES;
    
    // Restore all of button status.
    [self restoreSelectionButtonStat];
    
    UIButton * button = (UIButton *)sender;
	//Set Enabled of selection button is False and set BGColor to SelectionColorBlueColor.
   button.selected = YES;
    
	//Delete string info of selection button.
	for (int i = 0 ; i < self.myTextArray.count; i++) {
		if ( button.tag == i ) {
            self.stringOfSelectionBut = [self.myTextArray objectAtIndex:i];
           // button.backgroundColor = [UIColor blueColor];
            if ( 1 < [self.myTextField.text length] ) {
                self.isShouldBeDelete = NO;
            }
        }
	}
    
    if ( 1 < [self.myTextField.text length] && [self.myTextField.text isEqualToString:@"  "] == NO ) {
        [self.myTextArray addObject:self.myTextField.text];
       // button.backgroundColor = [UIColor blueColor];
        button.selected = YES;
        [self changeIt];
    }
    
    //---------- test -----------
    [button setEnabled:NO];
    
    [self.myTextField removeFromSuperview];
    [self addSubview:self.myTextField];
    
    UITextField *hiddenTF = [[UITextField alloc] 
                             initWithFrame:CGRectMake(10, 490, 260, 28)];
    hiddenTF.backgroundColor = [UIColor clearColor];
    hiddenTF.tag = 1024;
    [hiddenTF setHidden:YES];
    hiddenTF.returnKeyType =self.myTextField.returnKeyType;
   
    hiddenTF.text = [NSString stringWithFormat:@"  "];
    hiddenTF.delegate = self;
    [self addSubview:hiddenTF];
    [hiddenTF becomeFirstResponder];
    [hiddenTF release];
    
}

#pragma mark - Restitution of seleced button.
- (void) restoreSelectionButtonStat {
    //Restitution of seleced button.(Enabled and BackGroundColor)
	for(UIView *subview in [self subviews]){
		if([[subview class] isSubclassOfClass:UIButton.class]){
			UIButton *tipsButton = (UIButton *)subview;
            [tipsButton setEnabled:YES];
            
            //[tipsButton setBackgroundColor:[UIColor colorWithRed:0.4549 green:0.7176 blue:0.9373 alpha:1]];
		}
	}
    
    for ( UIView *hiddenView in [self subviews] ) {
        if ( [[hiddenView class] isSubclassOfClass:UITextField.class] && 1024 ==hiddenView.tag ) {
            [hiddenView removeFromSuperview];
        }
    }
}

#pragma mark - textField Delegate Method.
- (void)textFieldDidBeginEditing:(UITextField *)_textField
{    
    //    [self changeIt]; // ann
    if ( 1024 != _textField.tag ) {
        [self restoreSelectionButtonStat];
        self.stringOfSelectionBut = @"";
        [self changeIt];
    }
    //通知外部
    if (textdelegate) {//customTextDidChangeSize:(RNCustomText*)customText changeToSize:(CGSize)size
        if ([textdelegate respondsToSelector:@selector(customTextDidBeginEditing:)] ) {
            [textdelegate customTextDidBeginEditing:self];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)_textField {
    
    [_textField resignFirstResponder];
    
    BOOL result = YES;
    //通知外部
    if (textdelegate) {//customTextDidChangeSize:(RNCustomText*)customText changeToSize:(CGSize)size
        if ([textdelegate respondsToSelector:@selector(customTextShouldReturn:)] ) {
           result = [textdelegate customTextShouldReturn:self];
        }
    }
    
    return result;
    
}

- (BOOL)textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text
{
    BOOL resBool = YES;
    //Handel the hidden textField. (hiddenTextField.tag = 1024)
    if ( 1024 == _textField.tag ) {
        if ( [text isEqualToString:@""] ) { //Delete selected button.
            resBool = NO;
        } else {
            resBool = YES;
        }
        if ( self.isDeleteButton ) {
            self.isShouldBeDelete = YES;
            [self changeIt];
            self.isDeleteButton = NO;
        } else { //Travers selected button reverse order.
            [self deleteButton:[self.myButtonArray lastObject]];  
        }
        //Set firstResponder to self.myTextField.
        [self.myTextField becomeFirstResponder];
        return resBool;
    } else {
        if ( [text isEqualToString:@""] && [self.myTextField.text isEqualToString:@" "] ) {
            //selecte the last button.
            [self deleteButton:[self.myButtonArray lastObject]];
            for(UIView *subview in [self subviews]){
                if( [[subview class] isSubclassOfClass:UITextField.class] && 1024 == subview.tag ){
                    [subview becomeFirstResponder];
                    break;
                }
            }
        }
    }
    BOOL result = YES;
    //通知外部
    if (textdelegate) {//customTextDidChangeSize:(RNCustomText*)customText changeToSize:(CGSize)size
        if ([textdelegate respondsToSelector:@selector(customText: shouldChangeCharactersInRange: replacementString:)] ) {
            result = [textdelegate customText:self shouldChangeCharactersInRange:range replacementString:text];
        }
    }
    
	return YES;
}
-(NSInteger)findItem:(NSString*)text{
    NSInteger index = -1;
    NSInteger arrcount = [self.myTextArray count];
    for (int i=0;i<arrcount ;i++) {
        if ([[self.myTextArray objectAtIndex:i] isEqualToString:text]) {
            index = i;
            break;
        }
    }
    return index;
}
-(void)addItemWithText:(NSString*)text canRepeat:(BOOL)canrepeat{
    if (!canrepeat) {
        if ([self findItem:text] != -1) {
            return;
        }
    }
    [self.myTextArray addObject:text];
    [self changeIt];
    
}
-(BOOL)deleteItemWithText:(NSString*)text{
    if ([self findItem:text] != -1) {
        [self.myTextArray removeObject:text];
        [self changeIt];
        [self clearNotMatchText];
        return YES;
    }
    return NO;
}
-(void)clearNotMatchText{
    if ([self.myButtonArray count]<=0) {
        self.myTextField.text = [NSString stringWithFormat:@""];
    }else {
        self.myTextField.text = [NSString stringWithFormat:@"  "];
    }
}

- (void)dealloc
{
    [self.myTextField release];
    [self.myTextArray release];
    [self.myButtonArray release];
    [self.stringOfSelectionBut release];
    [super dealloc];
}

@end
