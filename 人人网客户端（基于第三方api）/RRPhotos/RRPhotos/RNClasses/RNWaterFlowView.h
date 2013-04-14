//
//  RNWaterFlowView.h
//  RRSpring
//
//  Created by sheng siglea on 12-3-2.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//
#import <UIKit/UIKit.h>
#define kWidth 320
#define kBufferHeight 20
#define kConOperationCount 3

#define kMinHeight 35
@protocol RNWaterFlowViewDelegate;
@class RNWaterFlowCell;

@interface RNWaterFlowView : UIScrollView<UIScrollViewDelegate>{
    NSUInteger _nColumns ; // 列数
    CGFloat _cellWidth; //cell宽度
	NSMutableArray *_arrColumsMaxHeight; //每列的最高高度
    NSMutableArray *_arrCellFrame; //每个cell 的frame
	NSMutableArray *_arrVisibleCells; // 当前可见的cell
	NSMutableDictionary *_dicReuseCells; //重用的cell
	//flowdelegate
	id <RNWaterFlowViewDelegate> _flowdelegate;
}

@property (nonatomic, retain) NSMutableArray *arrColumsMaxHeight;
@property (nonatomic, retain) NSMutableArray *arrCellFrame;
@property (nonatomic, retain) NSMutableArray *arrVisibleCells;
@property (nonatomic, retain) NSMutableDictionary *dicReuseCells;
@property (nonatomic, assign) id <RNWaterFlowViewDelegate> flowdelegate;

// 数据重新加载
- (void)reloadData;
// 可重用的cell
- (RNWaterFlowCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
//计算当前可视cell的索引
- (NSMutableArray *)visibleCellsIndex;
//给定索引的cell  // returns nil if cell is not visible or index path is out of range
- (RNWaterFlowCell *)cellForIndex:(NSUInteger)index;
// 滚动到指定的索引cell
- (void)scrollToCellAtIndex:(NSUInteger)index animated:(BOOL)animated;
//cell宽度
- (CGFloat)cellWidth;
@end

@protocol RNWaterFlowViewDelegate<NSObject>

@required
/*
 列数
 */
- (NSUInteger)numberOfColumnsInFlowView:(RNWaterFlowView *)flowView;
/*
 列间隙
 */
- (NSUInteger)columsSpan:(RNWaterFlowView *)flowView;
/*
 行间隙
 */
- (NSUInteger)rowSpan:(RNWaterFlowView *)flowView;
/*
 总cell数
 */
- (NSUInteger)numberofCellsInFlowView:(RNWaterFlowView *)flowView;
/*
 索引所对应的cell
 */
- (RNWaterFlowCell *)flowView:(RNWaterFlowView *)flowView cellForIndex:(NSUInteger)index;
/*
 选中cell
 */
- (void)flowView:(RNWaterFlowView *)flowView didSelectCellAtIndex:(NSUInteger)index;
/*
 cell的宽高比
 */
- (CGFloat)flowView:(RNWaterFlowView *)flowView cellWHRateAtIndex:(NSUInteger)index;

- (void)touchesBegan:(RNWaterFlowView *)flowView;

@end



@interface RNWaterFlowCell:UIImageView
{
	NSInteger _index; //序列
	NSString *_strReuseIndentifier; //重用标识
    UIImageView *_imageView;
    UILabel *_lableIndex;
}

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy,readonly) NSString *strReuseIndentifier;
@property (nonatomic, retain,readonly) UIImageView *imageView;
@property (nonatomic, retain,readonly) UILabel *lableIndex;

-(id)initWithIdentifier:(NSString *)indentifier;
-(void)changeSubviewsFrame;

@end
