//
//  RNFastAtFriendViewCellCell.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-26.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNFastAtFriendViewCellCell.h"
#import "RCFriendItem.h"
#import "UIImageView+RRWebImage.h"
@implementation RNFastAtFriendViewCellCell

@synthesize headImageView=_headImageView;
@synthesize nameLabel=_nameLabel;
@synthesize detailLabel=_detailLabel;



- (void) dealloc 
{
    RL_RELEASE_SAFELY(_headImageView);
    RL_RELEASE_SAFELY(_nameLabel);
    RL_RELEASE_SAFELY(_detailLabel);
	[super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier 
{
	
	self = [super initWithStyle:style reuseIdentifier:identifier];
	if (self) {		
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundView = [[[UIImageView alloc] initWithImage:[[RCResManager getInstance] imageForKey:@"rn_common_cell_bg"]] autorelease];
        self.backgroundView.userInteractionEnabled = YES;
        self.contentView.frame = self.backgroundView.frame;  	
        _nameLabel =[[UILabel alloc] init];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        _nameLabel.textColor = RGBCOLOR(1,1,1);
        _detailLabel =[[UILabel alloc] init];
        [_detailLabel setBackgroundColor:[UIColor clearColor]];
        _detailLabel.textColor = RGBCOLOR(176,176,176);
        _detailLabel.font = [UIFont systemFontOfSize:12];
        _headImageView =[[UIImageView alloc] init];
        [self addSubview:self.nameLabel];
        [self addSubview:self.headImageView];
        [self addSubview:self.detailLabel];
	}
	return self;
}


/**
 * 设置
 */
- (void)setObject: (id) itemObject {
    if (!itemObject) {
		return;
	}
    RCFriendItem* cellItem = ( RCFriendItem*)itemObject;
    self.nameLabel.text = cellItem.userName;
    self.detailLabel.text = cellItem.networkName;
    [self.headImageView setImageWithURL:[NSURL URLWithString:cellItem.headUrl] 
                       placeholderImage:[[RCResManager getInstance] imageForKey:@"main_head_profile"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
/**
 * 设置高亮状态
 */
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {  
        self.detailLabel.textColor = RGBCOLOR(1,1,1);
        self.backgroundView = [[[UIImageView alloc] initWithImage:[[RCResManager getInstance] imageForKey:@"rn_common_cell_select_bg"]] autorelease];
    }else{
        self.detailLabel.textColor = RGBCOLOR(176, 176, 176);
        self.backgroundView = [[[UIImageView alloc] initWithImage:[[RCResManager getInstance] imageForKey:@"rn_common_cell_bg"]] autorelease];
    }
}

/**
 * 布局视图
 */
- (void) layoutSubviews {
	[super layoutSubviews];
    
    CGFloat kCellSpan             = 5;      //控件之间间距
    CGFloat kCellLeftPadding      = 8;      // 左边距
    CGFloat kCellHeadImageHeight  = 41;     // 头像高度
    CGFloat kCellHeadImageWidth   = 41;     // 头宽度  
    CGFloat kCellTopPadding       = 3;      //文字上边距
    CGFloat kCellDetailMaxWidth   =PHONE_SCREEN_SIZE.width - 4*kCellSpan-kCellHeadImageWidth;     //描述文字最多140长度
    //头像
    CGFloat head_x = kCellLeftPadding;
    self.headImageView.frame = CGRectIntegral(CGRectMake(head_x, 
                                                         (self.frame.size.height-kCellHeadImageWidth)/2, 
                                                         kCellHeadImageWidth , 
                                                         kCellHeadImageWidth));
    
    //姓名
    self.nameLabel.frame = CGRectMake(head_x+kCellHeadImageWidth+kCellSpan,
                                      kCellTopPadding, 
                                      self.width-(head_x+kCellHeadImageWidth+kCellSpan), 
                                      kCellHeadImageHeight/2);
    
    CGRect iframe = self.nameLabel.frame;
    CGSize namelableautosize = [self.nameLabel.text sizeWithFont:self.nameLabel.font];
    iframe.size.width = namelableautosize.width;
    self.nameLabel.frame = iframe;
    
    //描述
    self.detailLabel.frame = CGRectMake(head_x+kCellHeadImageWidth+kCellSpan, 
                                        kCellTopPadding+kCellHeadImageHeight/2,
                                        self.width-(head_x+kCellHeadImageWidth+kCellSpan),
                                        kCellHeadImageHeight/2);
    CGSize detailLabelautosize = [self.detailLabel.text sizeWithFont:self.detailLabel.font];
    if (detailLabelautosize.width > kCellDetailMaxWidth) {
        detailLabelautosize.width=kCellDetailMaxWidth;
    }
    CGRect detaiframe = self.detailLabel.frame;
    detaiframe.size.width = detailLabelautosize.width;
    self.detailLabel.frame = detaiframe;
}
@end
