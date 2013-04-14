//
//  RNWaterFlowView.m
//  RRSpring
//
//  Created by sheng siglea on 12-3-2.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNWaterFlowView.h"
#import <QuartzCore/QuartzCore.h>


@interface RNWaterFlowView (Private)

//初始化
- (void)didInit;
//构建cell
- (void)buildCells;
//计算cell坐标
- (CGPoint)calcCellPoint:(CGSize) cellSize;
//取指定array最小值元素的索引
- (NSInteger)minIdxFromArray:(NSArray *)arrNums;
//取数组中的最小值
- (NSInteger) minFromArray:(NSArray *)arrNums;
//取数组中的最大值
- (NSInteger) maxFromArray:(NSArray *)arrNums;
//页面变化
- (void)pageChanged;
//把可重用的cell 添加到重用队列
- (void)addCellToReuseQueue:(RNWaterFlowCell *)cell;
//移除不在显示区域的cell
- (void)removeCellOutofVisibleView;
//把可视区域的cell 添加到visibleQueue 并排序
- (void)addCellToVisibleQueue:(RNWaterFlowCell *)cell;
@end

@implementation RNWaterFlowView

@synthesize 
arrColumsMaxHeight = _arrColumsMaxHeight, 
arrVisibleCells = _arrVisibleCells,
dicReuseCells = _dicReuseCells, 
flowdelegate = _flowdelegate,
arrCellFrame = _arrCellFrame;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
        self.delegate = self;
    }
    return self;
}
- (void)scrollToCellAtIndex:(NSUInteger)index animated:(BOOL)animated{
    RNWaterFlowCell *cell = [self cellForIndex:index];
    if (cell) {
        if (self.contentSize.height <= self.height) {
            self.contentOffset = CGPointZero;
        }else {
            self.contentOffset = CGPointMake(0, cell.top + self.height >= self.contentSize.height ?
                                             self.contentSize.height - self.height :cell.top);
        }
    }
}
- (void)dealloc {
    self.arrColumsMaxHeight = nil;
    self.arrVisibleCells = nil;
    self.dicReuseCells = nil;
    self.arrCellFrame = nil;
    [super dealloc];
}

- (RNWaterFlowCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
	if(identifier == nil || identifier.length ==0)
	{
		return nil;
	}
	
	NSMutableArray *arrIndentifier = [self.dicReuseCells objectForKey:identifier];
	if(arrIndentifier && [arrIndentifier isKindOfClass:[NSArray class]] && arrIndentifier.count > 0)
	{
		//找到了重用的 
		RNWaterFlowCell *cell = [arrIndentifier lastObject];
		[cell retain];
		[arrIndentifier removeLastObject];
		return [cell	 autorelease];
	}
	return nil;
}

//将要移除屏幕的cell添加到可重用列表中
- (void)addCellToReuseQueue:(RNWaterFlowCell *)cell{
	if(cell.strReuseIndentifier.length == 0)
		return ;
	if(self.dicReuseCells == nil)
	{
		self.dicReuseCells = [NSMutableDictionary dictionaryWithCapacity:4];
	}
    NSMutableArray *arr = [self.dicReuseCells objectForKey:cell.strReuseIndentifier];
    //不在可视区域的cell index 为-1
    cell.index = -1;
    if(arr == nil)
    {
        arr = [NSMutableArray arrayWithObject:cell];
        [self.dicReuseCells setObject:arr forKey:cell.strReuseIndentifier];
    } else {
        [arr addObject:cell];
    }	
}
- (CGFloat)cellWidth{
    return _cellWidth;
}
- (void)reloadData
{
    if (self.arrVisibleCells) {
        for (int i = [self.arrVisibleCells count]-1; i>=0; i--) {
            @autoreleasepool {
                RNWaterFlowCell *cell = [self.arrVisibleCells objectAtIndex:i];
                [self addCellToReuseQueue:cell];
                [cell removeFromSuperview];
                [self.arrVisibleCells removeObject:cell];
            }
        }
    }	
	[self didInit];
}

- (void)didInit
{
    NSLog(@"-----%s-----%d",__FUNCTION__,__LINE__);
    _cellWidth = (self.frame.size.width - 
                  ([self.flowdelegate numberOfColumnsInFlowView:self] - 1)*[self.flowdelegate columsSpan:self])/
    [self.flowdelegate numberOfColumnsInFlowView:self];
	_nColumns = [_flowdelegate numberOfColumnsInFlowView:self];
    self.arrVisibleCells = [NSMutableArray arrayWithCapacity:20];
	//每列用一个数组保存高度
	self.arrColumsMaxHeight = [NSMutableArray arrayWithCapacity:_nColumns];
	//每列的高度
	for(int i = 0; i < _nColumns; i++)
	{
        [self.arrColumsMaxHeight insertObject:[NSNumber numberWithInt:0] atIndex:i];
    }
    //保存加载之前的offset,cellcount数据
    NSInteger cellCount = 0;
    CGPoint offset = self.contentOffset;
    CGSize size = self.contentSize;
    if (![NSObject isEmptyContainer:self.arrCellFrame]) {
        cellCount = [self.arrCellFrame count];
    }
    //初始化cells
    self.arrCellFrame = [NSMutableArray arrayWithCapacity:20];
    [self buildCells];
    //保持加载之前的offset
    if ([self.arrCellFrame count] > cellCount && (int)self.contentSize.height >= (int)size.height) {
        self.contentOffset = offset;
    }
}

- (void)buildCells{
    for (int i = 0; i<[self.flowdelegate numberofCellsInFlowView:self]; i++) {
        CGFloat height = _cellWidth/[self.flowdelegate flowView:self cellWHRateAtIndex:i];
        CGSize size = CGSizeMake(_cellWidth, height);
        if (size.height < kMinHeight) {
            size = CGSizeMake(_cellWidth, kMinHeight);
        }
        CGPoint point = [self calcCellPoint:size];
        CGRect gFrame = CGRectMake(point.x, point.y, size.width, size.height);
        [self.arrCellFrame insertObject:[NSValue valueWithCGRect:gFrame] atIndex:i];
    }
    [self pageChanged];
}

- (CGPoint)calcCellPoint:(CGSize) cellSize{
    NSInteger columIdx = [self minIdxFromArray:self.arrColumsMaxHeight];
    CGFloat x = columIdx*cellSize.width+columIdx*[self.flowdelegate columsSpan:self];
    CGFloat y = [[self.arrColumsMaxHeight objectAtIndex:columIdx] floatValue] + [self.flowdelegate rowSpan:self];
    [self.arrColumsMaxHeight replaceObjectAtIndex:columIdx withObject:[NSNumber numberWithFloat:(y + cellSize.height)]];
    //设置 self 的contentSize
    
    self.contentSize = CGSizeMake(self.frame.size.width, [self maxFromArray:self.arrColumsMaxHeight]);
    return CGPointMake(x, y);
}
// array中最小元素的索引，如果最小元素多于1个，取idx最小的索引
- (NSInteger)minIdxFromArray:(NSArray *)arrNums{
    int min = [self minFromArray:arrNums];
    NSMutableArray *idxArray = [NSMutableArray array];
    for (int i=0; i<[arrNums count]; i++) {
        if (min == [[arrNums objectAtIndex:i] intValue]) {
            [idxArray addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return [self minFromArray:idxArray];
}
- (NSInteger) minFromArray:(NSArray *)arrNums{
    if (arrNums && [arrNums count]>0) {
        int min = [[arrNums objectAtIndex:0] intValue];
        for (int i=0; i<[arrNums count]; i++) {
            if ([[arrNums objectAtIndex:i] intValue] < min) {
                min = [[arrNums objectAtIndex:i] intValue];
            }
        }
        return min;
    }
    @throw [NSException exceptionWithName:@"empty array" reason:@"array is nil or empty" userInfo:nil];
}
- (NSInteger) maxFromArray:(NSArray *)arrNums{
    if (arrNums && [arrNums count]>0) {
        int max = [[arrNums objectAtIndex:0] intValue];
        for (int i=0; i<[arrNums count]; i++) {
            if ([[arrNums objectAtIndex:i] intValue] > max) {
                max = [[arrNums objectAtIndex:i] intValue];
            }
        }
        return max;
    }
    @throw [NSException exceptionWithName:@"empty array" reason:@"array is nil or empty" userInfo:nil];

}
- (void)pageChanged{
    NSMutableArray *arrIndex = [self visibleCellsIndex];
    for (int idx=0; idx<[arrIndex count]; idx++) {
        @autoreleasepool {
            NSUInteger index = [[arrIndex objectAtIndex:idx] intValue];
            RNWaterFlowCell *cell = [self cellForIndex:index];
            if (cell) {
                continue;
            }
            cell = [self.flowdelegate flowView:self cellForIndex:index];
            CGRect gFrame = [[self.arrCellFrame objectAtIndex:index] CGRectValue];
            cell.frame = gFrame;
            [cell changeSubviewsFrame];
            [self addSubview:cell];
            [self addCellToVisibleQueue:cell];
        }
    }
}
- (void)removeCellOutofVisibleView{
    for (int i = [self.arrVisibleCells count]-1; i>=0; i--) {
        @autoreleasepool {
            RNWaterFlowCell *cell = [self.arrVisibleCells objectAtIndex:i];
            if ((cell.frame.origin.y + cell.frame.size.height <= self.contentOffset.y ||
                 cell.frame.origin.y >= self.contentOffset.y + self.frame.size.height) &&
                (self.contentOffset.y >= 0 && self.contentOffset.y <= self.contentSize.height)) {
                [self addCellToReuseQueue:cell];
                [cell removeFromSuperview];
                [self.arrVisibleCells removeObject:cell];
            }
        }
    }
}

- (NSMutableArray *)visibleCellsIndex{
    NSMutableArray *arrIndex = [NSMutableArray arrayWithCapacity:10];
    for (int i=0; i<[self.arrCellFrame count]; i++) {
        @autoreleasepool {
            CGRect frame = [[self.arrCellFrame objectAtIndex:i] CGRectValue];
            if ( ((int)frame.origin.y <= (int)self.contentOffset.y + (int)self.frame.size.height) &&
                ((int)frame.origin.y >= (int)self.contentOffset.y || (int)frame.origin.y + (int)frame.size.height >= (int)self.contentOffset.y)) {
                [arrIndex addObject:[NSNumber numberWithInt:i]];
            }
        }
    }
    return arrIndex;
}
- (RNWaterFlowCell *)cellForIndex:(NSUInteger)idx{
    if (idx >= [self.arrCellFrame count]) {
        return nil;
    }
    if (self.arrVisibleCells && [self.arrVisibleCells count] > 0) {
        CGRect gFrame = [[self.arrCellFrame objectAtIndex:idx] CGRectValue];
        
        //二分查找
        int start = 0;
        int end = [self.arrVisibleCells count] - 1;
        int index = -1;
        int ox = gFrame.origin.x;
        int oy = gFrame.origin.y;
        while (YES) {
            index = (start + end)/2;
            RNWaterFlowCell *cell = (RNWaterFlowCell *)[self.arrVisibleCells objectAtIndex:index];
            int cx = cell.frame.origin.x;
            int cy = cell.frame.origin.y;
            if (cx == ox && cy == oy) {
                return  cell;
            }else if(start > end){
                return nil;
            }else {
                if (cy > oy) {
                    end = index - 1;
                }else if (cy < oy) {
                    start = index + 1;
                }else {
                    if (cx > ox) {
                        end = index - 1;
                    }
                    if (cx < ox) {
                        start = index + 1;
                    }
                }
            }
        }
    }
    
    return nil;
}
/*
 添加cell并排序
 */
- (void)addCellToVisibleQueue:(RNWaterFlowCell *)cell{
    [self.arrVisibleCells addObject:cell];
    [self.arrVisibleCells sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CGRect frame1 = ((RNWaterFlowCell *)obj1).frame;
        CGRect frame2 = ((RNWaterFlowCell *)obj2).frame;
        if ((int)frame1.origin.y < (int)frame2.origin.y)
            return (NSComparisonResult)NSOrderedAscending;
        if ((int)frame1.origin.y > (int)frame2.origin.y)
            return (NSComparisonResult)NSOrderedDescending;
        if ((int)frame1.origin.x < (int)frame2.origin.x)
            return (NSComparisonResult)NSOrderedAscending;
        if ((int)frame1.origin.x > (int)frame2.origin.x)
            return (NSComparisonResult)NSOrderedDescending;
        return (NSComparisonResult)NSOrderedSame;
    }];
}
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self removeCellOutofVisibleView];
	if([_flowdelegate  conformsToProtocol:@protocol(UIScrollViewDelegate)]  && [_flowdelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
	{
		[(id<UIScrollViewDelegate>) _flowdelegate  scrollViewDidEndDecelerating:self];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self removeCellOutofVisibleView];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if([_flowdelegate  conformsToProtocol:@protocol(UIScrollViewDelegate)]  && [_flowdelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
	{
		[(id<UIScrollViewDelegate>) _flowdelegate scrollViewWillBeginDragging:self];
	}
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self removeCellOutofVisibleView];
    if([_flowdelegate  conformsToProtocol:@protocol(UIScrollViewDelegate)]  && [_flowdelegate respondsToSelector:@selector(scrollViewDidEndDragging: willDecelerate:)])
	{
		[(id<UIScrollViewDelegate>) _flowdelegate  scrollViewDidEndDragging:self willDecelerate:decelerate];
	}
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self removeCellOutofVisibleView];
	[self pageChanged];
	if([_flowdelegate  conformsToProtocol:@protocol(UIScrollViewDelegate)]  && [_flowdelegate respondsToSelector:@selector(scrollViewDidScroll:)])
	{
		[(id<UIScrollViewDelegate>) _flowdelegate  scrollViewDidScroll:self];
	}
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_flowdelegate) {
        [_flowdelegate touchesBegan:self];
    }
}

@end

//===============RNWaterFlowCell================
#pragma RNWaterFlowCell
@implementation RNWaterFlowCell
@synthesize index = _index;
@synthesize strReuseIndentifier = _strReuseIndentifier;
@synthesize imageView = _imageView;
@synthesize lableIndex = _lableIndex;

-(id)initWithIdentifier:(NSString *)indentifier
{
	if(self = [super init])
	{
        self.userInteractionEnabled = YES;
        self.image = [[[RCResManager getInstance] imageForKey:@"album_cell_bg"] stretchableImageWithLeftCapWidth:8.5 topCapHeight:8.5];
		_strReuseIndentifier = indentifier;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.layer.cornerRadius = 1.0;
        [self addSubview:_imageView];
        [_imageView release];
        
        _lableIndex = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        _lableIndex.hidden = YES;
        _lableIndex.font = [UIFont systemFontOfSize:14];
        _lableIndex.backgroundColor = [UIColor grayColor];
        _lableIndex.textColor = [UIColor blackColor];
        [self addSubview:_lableIndex];
        [_lableIndex release];

	}
    
	return self;
}
-(void)changeSubviewsFrame{
    _imageView.frame = CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10);
}
- (void)dealloc
{
    [_imageView release];
    [_lableIndex release];
	[super dealloc];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UIView *superview = [self superview];
    if (superview && [superview isKindOfClass:[RNWaterFlowView class]] && ((RNWaterFlowView *)superview).flowdelegate) {
        RNWaterFlowView *flowView = (RNWaterFlowView *)superview;
        [flowView.flowdelegate flowView:flowView didSelectCellAtIndex:self.index];
    }else {
        [self.nextResponder touchesBegan:touches withEvent:event];
    }
}
@end
