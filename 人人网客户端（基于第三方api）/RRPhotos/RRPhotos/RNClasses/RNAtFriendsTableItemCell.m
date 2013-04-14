//
//  RNAtFriendsTableItemCell.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-31.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNAtFriendsTableItemCell.h"
#import "RCPageitem.h"
#import "RCFriendItem.h"
#import "UIImageView+RRWebImage.h"

@implementation RNAtFriendsTableItemCell

@synthesize selectImageView=_selectImageView;
@synthesize headImageView=_headImageView;
@synthesize nameLabel=_nameLabel;
@synthesize detailLabel=_detailLabel;
@synthesize publicType=_publicType;
@synthesize publicImage=_publicImage;
@synthesize cellType=_cellType;





- (void) dealloc 
{
    RL_RELEASE_SAFELY(_selectImageView);
    RL_RELEASE_SAFELY(_headImageView);
    RL_RELEASE_SAFELY(_nameLabel);
    RL_RELEASE_SAFELY(_detailLabel);
    RL_RELEASE_SAFELY(_publicType);
    RL_RELEASE_SAFELY(_publicImage);
	[super dealloc];
}

- (void)prepareForReuse 
{
    [super prepareForReuse];
//    RL_RELEASE_SAFELY(_selectImageView);
//    RL_RELEASE_SAFELY(_headImageView);
//    RL_RELEASE_SAFELY(_nameLabel);
//    RL_RELEASE_SAFELY(_detailLabel);
//    RL_RELEASE_SAFELY(_publicType);
//    RL_RELEASE_SAFELY(_publicImage);
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
        _publicType  =[[UILabel alloc]init];
        [_publicType setBackgroundColor:[UIColor clearColor]];
        _publicType.font = [UIFont systemFontOfSize:12];
        //[_publicType setTextAlignment:UITextAlignmentRight];
        _publicType.textColor = RGBCOLOR(176,176,176);
        _headImageView=[[UIImageView alloc] init];
        _publicImage = [[UIImageView alloc] initWithImage:[[RCResManager getInstance] imageForKey:@"publish_at_page"]];
        _selectImageView =[[UIImageView alloc] initWithImage:[[RCResManager getInstance] imageForKey:@"publish_at_round_check"]];
        
        [self addSubview:self.publicImage];
        [self addSubview:self.selectImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.headImageView];
        [self addSubview:self.publicType];
        [self addSubview:self.detailLabel];
	}
	return self;
}


/**
 * 设置
 */
- (void)setObject: (id) itemObject cellType:(AtFriendType)celltype{
    if (!celltype) {
        self.cellType = ENormalFriendType;
    }else {
        self.cellType = celltype;
    }
    
    if (!itemObject) {
		return;
	}
    if (self.cellType == EPublicFriendType) {
        RCPageitem* cellItem = ( RCPageitem*)itemObject;
        self.nameLabel.text = cellItem.pageName;
        self.detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"好友:%@", @"好友:%@"),cellItem.fansNumber];
        self.publicType.text = [NSString stringWithFormat:NSLocalizedString(@"类型:%@", @"类型:%@"),cellItem.classiFication];
        
        [self.headImageView setImageWithURL:[NSURL URLWithString:cellItem.headUrl] 
                           placeholderImage:[[RCResManager getInstance] imageForKey:@"main_head_profile"]];
        self.publicImage.hidden = NO;
        self.publicType.hidden = NO;
        if (cellItem.isSelected) {
            [self.selectImageView setImage:[[RCResManager getInstance] imageForKey:@"publish_at_round_check_sel"]];
        }else {
            [self.selectImageView setImage:[[RCResManager getInstance] imageForKey:@"publish_at_round_check"]];
        }

    }else {
        RCFriendItem* cellItem = ( RCFriendItem*)itemObject;
        self.nameLabel.text = cellItem.userName;
        self.detailLabel.text = cellItem.networkName;
        self.publicType.text = @"";
        [self.headImageView setImageWithURL:[NSURL URLWithString:cellItem.headUrl] 
                           placeholderImage:[[RCResManager getInstance] imageForKey:@"main_head_profile"]];
        
        self.publicImage.hidden = YES;
        self.publicType.hidden = YES;
        if (cellItem.selected) {
            [self.selectImageView setImage:[[RCResManager getInstance] imageForKey:@"publish_at_round_check_sel"]];
        }else {
            [self.selectImageView setImage:[[RCResManager getInstance] imageForKey:@"publish_at_round_check"]];
        }
    }
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
    CGFloat kCellSelectImageWidth = 30;     //选择框大小
    CGFloat kCellTopPadding       = 9;      //文字上边距
    CGFloat kCellDetailMaxWidth   =120;     //描述文字最多140长度
    //选择框
    self.selectImageView.frame =CGRectMake(kCellLeftPadding, 
                                           (self.frame.size.height-kCellSelectImageWidth)/2,
                                           kCellSelectImageWidth, 
                                           kCellSelectImageWidth);
 
    
    //头像
    CGFloat head_x = self.selectImageView.frame.origin.x+kCellSelectImageWidth+kCellSpan;
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
    //如果是公共主页需要添加公共主页标记和公共主页类型
    if (self.cellType == EPublicFriendType) {
        CGRect page_picframe = self.publicImage.frame;    
        if(page_picframe.origin.x > self.size.width - page_picframe.size.width - 3*kCellSpan){
            page_picframe.origin.x = self.size.width - page_picframe.size.width - 3*kCellSpan;
            iframe.size.width = iframe.size.width - page_picframe.size.width - 3*kCellSpan;
            self.nameLabel.frame = iframe;
        }
        page_picframe.origin.x = iframe.origin.x + iframe.size.width +5;
        page_picframe.origin.y = iframe.origin.y;
        self.publicImage.frame=page_picframe;
    
        CGRect page_typeframe = self.publicType.frame;
        page_typeframe.origin.x = detaiframe.origin.x + kCellDetailMaxWidth+kCellSpan;
        page_typeframe.origin.y = detaiframe.origin.y;
        page_typeframe.size.width = self.size.width - 5*kCellSpan - kCellSelectImageWidth - kCellHeadImageWidth-kCellDetailMaxWidth;
        page_typeframe.size.height = kCellHeadImageHeight/2;
        self.publicType.frame = page_typeframe;
    }
    
}
@end
