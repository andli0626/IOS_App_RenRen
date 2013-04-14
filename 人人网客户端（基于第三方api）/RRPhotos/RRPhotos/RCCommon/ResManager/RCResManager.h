//
//  SkinManager.h
//  TestSkinProject
//
//  Created by 钟 声 on 11-11-4.
//  Copyright (c) 2011年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDAutozeroingArray.h"
@class RCResManager;
@class DDAutozeroingArray;

// 切换皮肤的方法
@protocol RCResChangeSkinProtocol <NSObject>

// 第一步：重置需要手动更新的素材
// 第二步：重新显示 [RSView setNeedLayout] && [RSViewController viewWillApear]
- (void)changeSkinAction:(id)sender;

@end


// 主题类型就先定2种，以后再扩展为读文件
typedef enum {
    SkinType_Defluat = 0,
    SkinType_Light , 
    SkinType_Night    
} SkinType;

@interface RCResManager : NSObject{
    
    SkinType _skinType;
    
    NSString *skinDicPath; // 皮肤目录
    
    BOOL _readFromDocument;
    BOOL _readFromBundle;

    NSDictionary* _colorAndFontInfoDic; // color和font
    
    NSBundle  *_skinInfoBundle;//皮肤信息的bundle
    DDAutozeroingArray *_resViewArray; // 所有需要换肤的view
    
    BOOL _isTempSkinType; // 是否是临时变化皮肤类型
}
@property (nonatomic, assign) BOOL isTempSkinType;
@property (nonatomic, assign) BOOL readFromDocument;
@property (nonatomic, assign) SkinType skinType;
@property (nonatomic, retain) NSBundle *skinInfoBundle;
@property (nonatomic, retain) NSDictionary *colorAndFontInfoDic; 

// 添加需要换肤的view
- (void)addSkinView:(id)view;
// 删除可能销毁的view
- (void)removeSkinView:(id)view;
// 换肤
- (void)changeSkin;
// 
+ (RCResManager*)getInstance;

/**  UIImage 
 <key>header</key>
 <string>testImage.png</string>
 */
- (UIImage *)imageForKey:(NSString*)key;
- (UIImage *)imageForKey:(NSString*)key withType:(SkinType)type;
- (UIImage *)rsImageNamed:(NSString*)name; // 提供一个直接获取UIImage方法

/**  UIFont
 <key>fontOfTitle</key>
 <dict>
    <key>name</key>
    <string>system</string>
    <key>size</key>
    <string>16.0</string>
 </dict>
 */
- (UIFont *)fontForKey:(NSString*)key;
- (UIFont *)fontForKey:(NSString*)key withType:(SkinType)type;

// color
/**  UIColor
 <key>colorOfHead</key>
 <dict>
    <key>red</key>
    <string>255.0/255.0</string>
    <key>green</key>
    <string>0.0</string>
    <key>blue</key>
    <string>0.0</string>
    <key>alpha</key>
    <string>1.0</string>
 </dict>
 */
- (UIColor *)colorForKey:(NSString*)key;
- (UIColor *)colorForKey:(NSString*)key withType:(SkinType)type;

- (BOOL)boolForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key withType:(SkinType)type;

- (NSString *)pathForKey:(NSString*)key;
- (NSString *)pathForKey:(NSString*)key withType:(SkinType)type;

- (NSArray *)stringArrayForKey:(NSString*)key;
- (NSArray *)stringArrayForKey:(NSString*)key withType:(SkinType)type;

//- (void) writeImage:(UIImage *)image forKey:(NSString*)key;
//- (NSArray *)skinTypes;
@end
