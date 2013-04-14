//
//  RNAtFriendsTableItemCell.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-31.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRImageView.h"
#import "RNAtFriendsModel.h"

@interface RNAtFriendsTableItemCell : UITableViewCell{
    /**
     * 选择框用于标记是否选中的
     */
    UIImageView *_selectImageView;

    /**
     * 头像图片
     */
    UIImageView *_headImageView;

    /**
     * 好友网络名标签
     */
    UILabel *_nameLabel;

    /**
     * 好友描述标签（如：所在区域等）
     */
    UILabel *_detailLabel;
    /*
     *公共主页分类
     */
    UILabel *_publicType;
    /*
     *公共主页名字后面的标记
     */
    UIImageView *_publicImage;
    
    AtFriendType _cellType;
}

@property (nonatomic, retain) UIImageView *selectImageView;

@property (nonatomic, retain) UIImageView *headImageView;

@property (nonatomic, retain) UILabel *nameLabel;

@property (nonatomic, retain) UILabel *detailLabel;

@property (nonatomic, retain) UILabel *publicType;

@property (nonatomic, retain) UIImageView *publicImage;

@property (nonatomic,assign) AtFriendType cellType;

/**
 * 设置
 */
- (void)setObject: (id) friendItemObject cellType:(AtFriendType)celltype;
@end
