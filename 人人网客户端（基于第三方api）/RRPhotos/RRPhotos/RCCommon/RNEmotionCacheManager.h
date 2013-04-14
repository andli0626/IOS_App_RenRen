//
//  RNEmotionCacheManager.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-11.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCBaseRequest.h"
#import "RNEmotion.h"
#import "RNEmotionMap.h"
#import "RNEmojeDownLoad.h"
#import "RCError.h"
@protocol RCEmotionListManagerDelegate;
@interface RNEmotionCacheManager : NSObject<RNEmotionDownloadDelegate>{
    RCBaseRequest *_emojiRequest;//获取表情列表网络
    RNEmotionMap *_emotionMap;
    RNEmojeDownLoad *_emotionDownLoad;//表情下载类
    NSMutableArray *_downLoadList;
    id<RCEmotionListManagerDelegate> _delegate;
}
@property (nonatomic ,readonly) RNEmotionMap *emotionMap;
@property (nonatomic ,assign ) id<RCEmotionListManagerDelegate> delegate;
+ (RNEmotionCacheManager *)getInstance;
-(void)upEmotionList;

- (void)initNetEmotionsData:(NSDictionary*)emotionList;
- (void)initLocalEmotionsData;
@end
@protocol RCEmotionListManagerDelegate <NSObject>

- (void)emotionListManagerDidUpdateSuccess:(RNEmotionCacheManager *)manager;
- (void)emotionListManager:(RNEmotionCacheManager *)manager didUpdateError:(RCError *)error;

@end