//
//  RNEmotion.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-12.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    Default_Emotions,// 默认表情
    Ali_Emotions,    // 阿里表情
    JJ_Emotions      //囧囧熊表情
}RSEmotionType;

typedef enum {
    InProjectResource,// 在工程的资源文件里面
    OnTheInternet     // 网络下载存放在Documents中
    
}RSEmotionPosition;

@interface RNEmotion : NSObject{
    /**
     * 表情的类型
     */
    RSEmotionType _emotionType;
    /**
     * 表情的位置
     */
    RSEmotionPosition _emotionPosition;
    /*
     *骠骑的url地址
     *如果不是网络表情则该字段为nil；
     */
    NSString *_netUrl;
    /**
     * 表示表情的图片地址。在本地表情文件存储文件名
     */
	NSString* _emotionPath;

    /**
     * 表情的转义字符
     */
    NSString* _escapeCode;
}
@property (nonatomic) RSEmotionType emotionType;
@property (nonatomic) RSEmotionPosition emotionPosition;
@property (nonatomic, copy) NSString* emotionPath;
@property (nonatomic, copy) NSString* escapeCode;
@property (nonatomic, copy) NSString* netUrl;

- (id) initWithDictionary:(NSDictionary*) dictionary;
@end
