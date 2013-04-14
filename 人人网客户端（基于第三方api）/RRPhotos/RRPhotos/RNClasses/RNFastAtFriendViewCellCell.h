//
//  RNFastAtFriendViewCellCell.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-26.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RNFastAtFriendViewCellCell : UITableViewCell{
    
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
}
@property (nonatomic, retain) UIImageView *headImageView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *detailLabel;

/**
 * 设置
 */
- (void)setObject: (id) friendItemObject;
@end
