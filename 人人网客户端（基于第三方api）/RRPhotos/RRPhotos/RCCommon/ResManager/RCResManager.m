//
//  SkinManager.m
//  TestSkinProject
//
//  Created by 钟 声 on 11-11-4.
//  Copyright (c) 2011年 renren. All rights reserved.
//

#import "RCResManager.h"
//定义bundle里面的plist文件名
#define COLOR_AND_FONT    @"color_font"

//白天bundle的名字
#define SKINTYPE_LIGHT  @"/skintype_light.bundle"
//夜晚bundle的名字
#define SKINTYPE_NIGHT  @"/skintype_night.bundle"

@interface RCResManager(Private)
//- (NSDictionary *)readSkinInfoBySourceName:(NSString *)srcName withDirPath:(NSString *)path;
- (NSBundle *)readSkinInfoBySourceName:(NSString *)type;
- (NSDictionary *)getSkinDicByType:(SkinType)type;
- (NSBundle *)getSkinInfoBundleByType:(SkinType)typ;
- (NSDictionary *) getColorAndFontInfoWithType:(SkinType)type;
@end


@implementation RCResManager

static RCResManager *_instance = nil;// 单例

@synthesize isTempSkinType = _isTempSkinType;
@synthesize readFromDocument = _readFromDocument;
@synthesize skinType = _skinType;
@synthesize skinInfoBundle=_skinInfoBundle;
@synthesize colorAndFontInfoDic=_colorAndFontInfoDic;

#pragma mark - for change theme
- (void)addSkinView:(id)view{
    if (!_resViewArray) {
        _resViewArray = [[DDAutozeroingArray alloc] initAutozeroingArray];
    }
    if (![_resViewArray containsObject:view]) {
        [_resViewArray addObject:view];
    }
    
}
- (void)removeSkinView:(id)view{
    if ([_resViewArray containsObject:view]) {

        [_resViewArray removeObject:view];
    }
    
}
- (void)changeSkin{
    // 当前支持以下父类换皮肤
//    RRLOG_debug(@" ## resViewArray：%@",_resViewArray);
//    RRLOG_debug(@" ## resViewArrayCount：%d",[_resViewArray count]);
    
    for (int i=0; i < [_resViewArray count];i++) {
//        id view = [_resViewArray objectAtIndex:i];
//        if ([view respondsToSelector:@selector(changeSkinAction:)]) {
//            [view changeSkinAction:self];
//            if ([view isKindOfClass:[RSView class]] || 
//                [view isKindOfClass:[RSTableHeaderView class]] || 
//                [view isKindOfClass:[RSTableHeaderDragRefreshView class]]) {
//                [view setNeedsLayout];
//            }else if([view isKindOfClass:[RSViewController class]]){
//                [view viewWillAppear:NO];
//            }else if ([view isKindOfClass:[RSTableViewController class]]){
//                [view viewWillAppear:NO];
//                RSTableViewController *tableviewController = (RSTableViewController*)view;
//                [tableviewController.tableView reloadData];
//            }
//        }
    }
}
#pragma mark - 通过key获取各种资源
/////////////////////////////////////////////////////////////////////////////////
- (UIImage *)imageForKey:(NSString *)key{
    return [self imageForKey:key withType:_skinType];
}

- (UIImage *)imageForKey:(NSString *)key withType:(SkinType)type{
    
    NSBundle     *bundleWithType=[self getSkinInfoBundleByType:type];
    NSString     *imagePath = [bundleWithType pathForResource:key ofType:@"png"];
    UIImage      *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    return [image autorelease];
}

- (UIImage *)rsImageNamed:(NSString*)name{
    // 容错
    if ([name rangeOfString:@".png"].length==0) {
        name = [NSString stringWithFormat:@"%@.png",name];
    }
    return [UIImage imageNamed:name];
}

/////////////////////////////////////////////////////////////////////////////////
- (UIFont *)fontForKey:(NSString*)key{
    return [self fontForKey:key withType:_skinType];
}

- (UIFont *)fontForKey:(NSString*)key withType:(SkinType)type{
    NSDictionary *skinDic = [self getColorAndFontInfoWithType:type];
    NSDictionary *fontDic = [skinDic objectForKey:key];
    NSString *fontName = [fontDic objectForKey:@"name"];
    NSNumber *fontSize = [fontDic objectForKey:@"size"];
    return [UIFont fontWithName:fontName size:[fontSize floatValue]];
}

/////////////////////////////////////////////////////////////////////////////////
- (UIColor *)colorForKey:(NSString*)key{
    return [self colorForKey:key withType:_skinType];
}

- (UIColor *)colorForKey:(NSString*)key withType:(SkinType)type{
    NSDictionary *skinDic = [self getColorAndFontInfoWithType:type];
    NSDictionary *colorDic = [skinDic objectForKey:key];
    NSNumber *redValue = [colorDic objectForKey:@"red"];
    NSNumber *greenValue = [colorDic objectForKey:@"green"];
    NSNumber *blueValue = [colorDic objectForKey:@"blue"];
    NSNumber *alphaValue = [colorDic objectForKey:@"alpha"];
    if ([alphaValue floatValue]<=0.0f) {
        return [UIColor clearColor];
    }
    return [UIColor colorWithRed:[redValue floatValue]/255.0f 
                           green:[greenValue floatValue]/255.0f
                            blue:[blueValue floatValue]/255.0f
                           alpha:[alphaValue floatValue]];
}

/////////////////////////////////////////////////////////////////////////////////
- (BOOL)boolForKey:(NSString*)key{
    return [self boolForKey:key withType:_skinType];
}

- (BOOL)boolForKey:(NSString*)key withType:(SkinType)type{
    NSDictionary *skinDic = [self getColorAndFontInfoWithType:type];
    return [[skinDic objectForKey:key] boolValue];
}

- (NSString *)pathForKey:(NSString*)key{
    return [self pathForKey:key withType:_skinType];
}

- (NSString *)pathForKey:(NSString*)key withType:(SkinType)type{
    NSDictionary *skinDic = [self getSkinDicByType:type];
    return [NSString stringWithString:[skinDic objectForKey:key]];
}


/////////////////////////////////////////////////////////////////////////////////
- (NSArray *)stringArrayForKey:(NSString*)key{
    return [self stringArrayForKey:key withType:_skinType];
}

- (NSArray *)stringArrayForKey:(NSString*)key withType:(SkinType)type{
    NSDictionary *skinDic = [self getSkinDicByType:type];
    return [skinDic objectForKey:key];
}
/////////////////////////////////////////////////////////////////////////////////



//根据皮肤类型加载不同的bundle
- (NSBundle*)getSkinInfoBundleByType:(SkinType)type{
    
    NSBundle *skinBundle;
    
    if (_isTempSkinType && type == _skinType) {
        self.skinInfoBundle = nil;
    }
    // 如果不是当前主题类型，就是临时类型 
    if (type != _skinType && !_isTempSkinType) {
        _isTempSkinType = YES;
        self.skinInfoBundle = nil;
    }else{
        _isTempSkinType = NO;
    }
    switch (type) {
        case SkinType_Defluat://默认为Skintype_Light
        case SkinType_Light:
            skinBundle = [self readSkinInfoBySourceName:SKINTYPE_LIGHT];
            break;
        case SkinType_Night:
            skinBundle = [self readSkinInfoBySourceName:SKINTYPE_NIGHT];
            break;
        default:
            break;
    }
    
    return skinBundle;

}

- (NSBundle *)readSkinInfoBySourceName:(NSString *)srcName {
    // 如果bundle还没读出或者因为临时皮肤销毁了bundle，则重新读出
    if (!_skinInfoBundle) {
        NSString *skinBundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:srcName];
        _skinInfoBundle = [[NSBundle alloc] initWithPath:skinBundlePath];
  
        NSString *plistPath=[_skinInfoBundle pathForResource:COLOR_AND_FONT ofType:@"plist"];
        NSDictionary *tmpColorAndFontDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        self.colorAndFontInfoDic = tmpColorAndFontDic;
        [tmpColorAndFontDic release];
        
    }
    
    return _skinInfoBundle;
}


// 加载bundle里面的plist的color和font的信息
- (NSDictionary *)getColorAndFontInfoWithType:(SkinType)type{ 
    // 根据皮肤刷新下_skinInfoBundle和_colorAndFontInfoDic
    [self getSkinInfoBundleByType:type];
    
    return self.colorAndFontInfoDic;
}

#pragma mark - private methods

- (void)dealloc{
    self.skinInfoBundle = nil;
    if (_resViewArray) {
        [_resViewArray release];
    }
    [super dealloc];
}
- (id)init{
    self = [super init];
    if (self) {
        _skinType =  SkinType_Light; // 默认
        _isTempSkinType = NO;        

    }
    return self;
}
+ (RCResManager*)getInstance{
    @synchronized(self) { // 防止同步问题
		if (_instance == nil) {
            [[RCResManager alloc] init];
		}
	}
	return _instance; 
}

+ (id) allocWithZone:(NSZone*) zone {
	@synchronized(self) { 
		if (_instance == nil) {
			_instance = [super allocWithZone:zone];  // assignment and return on first allocation
			return _instance;
		}
	}
	return nil;
}

- (id) copyWithZone:(NSZone*) zone {
	return _instance;
}

- (id) retain {
	return _instance;
}

- (unsigned) retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (id) autorelease {
	return self;
}

@end