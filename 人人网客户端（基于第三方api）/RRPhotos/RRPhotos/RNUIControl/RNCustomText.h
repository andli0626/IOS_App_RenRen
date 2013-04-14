//
//  RNCustomText.h
//  SYPProject
//
//  Created by 玉平 孙 on 12-1-3.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RNCustomTextDelegate;

@interface RNCustomText : UIScrollView <UITextFieldDelegate>{
    UIImageView         *   _backgroundView;
    UITextField         *   myTextField;
    id                      mainDelegate;

    NSMutableArray      *   myTextArray;
    NSMutableArray      *   myButtonArray;
    NSString            *   stringOfSelectionBut;
    UIView              *   leftview;
    
    float   changeIt_Height;
    float   changeIt_Width;
    CGRect  scrollFrame;
    
    BOOL    isDeleteButton;
    BOOL    isShouldBeDelete;
    //控件的最大高度，不设置默认为不遮挡键盘
    float   _maxHeight;
    id<RNCustomTextDelegate> _textdelegate;
    UIImage *btnNomalImage;
    UIImage *btnHeightImage;
}

@property (nonatomic, retain) UIImage           *btnNomalImage;
@property (nonatomic, retain) UIImage           *btnHeightImage;

@property (nonatomic, retain) UIImageView       *  backgroundView;
@property (nonatomic, retain) UIView            *  leftview;
@property (nonatomic, retain) UITextField       *  myTextField;
@property (nonatomic, retain) NSMutableArray    *  myTextArray;
@property (nonatomic, retain) NSMutableArray    *  myButtonArray;
@property (nonatomic, retain) NSString          *  stringOfSelectionBut;
@property (nonatomic,assign)  float             maxHeight;
@property (nonatomic, assign) BOOL  isDeleteButton;
@property (nonatomic, assign) BOOL  isShouldBeDelete;
@property (nonatomic, readwrite) CGRect scrollFrame;
@property (nonatomic, assign) id<RNCustomTextDelegate> textdelegate;

- (id)initWithPage:(CGRect)frame delegat:(id)delegate;
- (void) changeIt;
- (void) resumeScrollView;
- (void) restoreSelectionButtonStat;
- (void) resResponderAct;

/*
 *添加单个联系人
 * @pram:text显示的文本
 * @pram:canrepeat，true表示可以重复添加，false表示需要去重
 */
-(void)addItemWithText:(NSString*)text canRepeat:(BOOL)canrepeat;
/*
 *删除单个联系人
 * @pram:text显示的文本
 * @return: 返回是否删除，false表示没有找到
 */
-(BOOL)deleteItemWithText:(NSString*)text;
/*
 *清空为匹配的文字
 */
-(void)clearNotMatchText;

@end
/*
 * 导航条代理
 */
@protocol RNCustomTextDelegate <NSObject>

@optional
/*
 *输入框变动大小通知
 *@pram: size将要变化到的大小
 *@pram:customText,文本框本身
 */
-(void)customTextDidChangeSize:(RNCustomText*)customText changeToSize:(CGSize)size;
/*
 *输入框删除联系人对外通知
 *@pram: deleteText删除的联系人名字
 */
-(void)customTextDiddelete:(NSString*)deleteText ;

- (void)customTextDidBeginEditing:(RNCustomText *)customText;

- (BOOL)customTextShouldReturn:(RNCustomText *)customText;

- (BOOL)customText:(RNCustomText *)customText shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text;




@end