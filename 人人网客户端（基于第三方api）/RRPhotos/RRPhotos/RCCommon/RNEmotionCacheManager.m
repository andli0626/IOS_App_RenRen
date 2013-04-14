//
//  RNEmotionCacheManager.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-11.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNEmotionCacheManager.h"
#import "RCMainUser.h"
#import "RCDataPersistenceAssistant.h"


// 阿狸表情转义符内容及顺序
static NSString *aliEmotions = @"[al01],[al06],[al08],[al09],[al10],[al11],[al15],[al16],[al17],[al18],[al19],[al20],[al21],[al22],[al24],[al28],[al29],[al31],[al33],[al34],[al35],[al36],[al38],[al39],[al40],[al41],[al42],[al43],[al44],[al45],[al46],[al47],[al48],[al49],[al50],[al51]";
// 囧囧熊表情转义符内容及顺序
static NSString *jjEmotions = @"[jj01],[jj02],[jj03],[jj04],[jj05],[jj06],[jj07],[jj08],[jj09],[jj10],[jj11],[jj12],[jj13],[jj14],[jj15],[jj16],[jj17],[jj18],[jj19]";

static RNEmotionCacheManager *_instance = nil;
@implementation RNEmotionCacheManager
@synthesize delegate=_delegate;
@synthesize emotionMap = _emotionMap;

- (void)dealloc{
    TT_RELEASE_SAFELY(_emotionMap);
    TT_RELEASE_SAFELY(_emojiRequest);
    TT_RELEASE_SAFELY(_emotionDownLoad);
    TT_RELEASE_SAFELY(_downLoadList);
    [super dealloc];
}
+ (RNEmotionCacheManager *)getInstance{
    @synchronized(self){
        if (_instance == nil) {
            _instance = [[RNEmotionCacheManager alloc] init];
        }
    }        
    return _instance;
}
-(void)startRequest{
    _emojiRequest = [[RCBaseRequest alloc] init];
    _emojiRequest.onCompletion = ^(NSDictionary* result){     
        [self initNetEmotionsData:result];     
        if (self.delegate) {
            [self.delegate emotionListManagerDidUpdateSuccess:self];
        }
    };
    _emojiRequest.onError = ^(RCError* error) {
        if (self.delegate) {
            [self.delegate emotionListManager:self didUpdateError:error];
        }
    };
    RCMainUser *mainuserinfo = [RCMainUser getInstance];
    NSMutableDictionary* dics = [NSMutableDictionary dictionary];
    [dics setObject:mainuserinfo.sessionKey forKey:@"session_key"];
    [dics setObject:@"all" forKey:@"type"];
    [_emojiRequest sendQuery:dics withMethod:@"status/getEmoticons"];
}

- (id)init{
    self = [super init];
    if (self) {
        _emotionMap = [RNEmotionMap getInstance];
        _emotionDownLoad = [[RNEmojeDownLoad alloc] init];
        _emotionDownLoad.delegate = self;
        _downLoadList = [[NSMutableArray alloc] init];
        [self initLocalEmotionsData];
    }
    return self;
}
-(void)initCacheDefaultEmotion{
 
    NSDictionary *defaultemotion = [RCDataPersistenceAssistant getDefauleEmotionList];
    if (defaultemotion == nil || [defaultemotion count]<=0) {
        return;
    }
    NSString *commpath = [RCMainUser  commonPath];
    NSMutableArray *defaultEmotionsTmpArray = [[NSMutableArray alloc] initWithCapacity:[defaultemotion count]];
    for (NSDictionary *emotiondic in defaultemotion) {
        RNEmotion *emotion = [[RNEmotion alloc] init];
        emotion.emotionType = Default_Emotions;
        emotion.emotionPosition = OnTheInternet;
        NSString *code = [emotiondic objectForKey:@"emotion"];
        NSString *path = [NSString stringWithFormat:@"%@/%@",commpath,[code md5]];
        emotion.emotionPath = path;
        emotion.escapeCode = code;
        [defaultEmotionsTmpArray addObject:emotion];
        [emotion release];
    }
    self.emotionMap.defaultEmotionsArray = defaultEmotionsTmpArray;
    [defaultEmotionsTmpArray release];
  //  [self startNetEmotionDownLoad:self.emotionMap.defaultEmotionsArray];
}
-(void)startupemotion{
    [self startRequest];
    [self initCacheDefaultEmotion];
    [self initLocalEmotionsData];
}
-(void) upEmotionList{
    
    [NSThread detachNewThreadSelector:@selector(startupemotion) toTarget:self withObject:self];
}
-(void)startNetEmotionDownLoad:(NSMutableArray*)downList{
 //   [_emotionDownLoad cancel];
    [_downLoadList removeAllObjects];
    [_downLoadList setArray:downList];
    if ([_downLoadList count] <= 0) {
        return;
    }
    RNEmotion *currentemo = [_downLoadList objectAtIndex:0];
    _emotionDownLoad.url = [NSURL URLWithString: currentemo.netUrl];
    _emotionDownLoad.filePath = [RCMainUser commonPath];
    _emotionDownLoad.fileName = [currentemo.escapeCode md5];
    [_emotionDownLoad start];
    
}
- (void)initNetEmotionsData:(NSDictionary*)dicdata{
    
    NSString *baseurl = [dicdata objectForKey:@"base_url"];
    NSDictionary *emotionlist = [dicdata objectForKey:@"emoticon_list"];
    NSString *commpath = [RCMainUser  commonPath];
    NSMutableArray *defaultEmotionsTmpArray = [[NSMutableArray alloc] initWithCapacity:[emotionlist count]];
    if (emotionlist == nil || [emotionlist count]<=0) {
        return;
    }
    //保存表情数据
    [RCDataPersistenceAssistant saveDefauleEmotion:emotionlist];
    
    for (NSDictionary *emotiondic in emotionlist) {
        RNEmotion *emotion = [[RNEmotion alloc] init];
        emotion.emotionType = Default_Emotions;
        emotion.emotionPosition = OnTheInternet;
    
        
        NSString *code = [emotiondic objectForKey:@"emotion"];
        NSString *path = [NSString stringWithFormat:@"%@/%@",commpath,[code md5]];
        NSString *emotionUrl = [NSString stringWithFormat:@"%@%@",baseurl,[emotiondic objectForKey:@"icon"]];
        emotion.emotionPath = path;
        emotion.escapeCode = code;
        emotion.netUrl = emotionUrl;
        [defaultEmotionsTmpArray addObject:emotion];
        [emotion release];
    }
    self.emotionMap.defaultEmotionsArray = defaultEmotionsTmpArray;
    [defaultEmotionsTmpArray release];
    
    [self startNetEmotionDownLoad:self.emotionMap.defaultEmotionsArray];
}
- (void)initLocalEmotionsData{
    // 将阿里表情文件与转移字符串关系写入数组
    NSArray *aliEmotionsArray = [aliEmotions componentsSeparatedByString:@","];
    NSMutableArray *aliEmotionsTmpArray = [[NSMutableArray alloc] initWithCapacity:[aliEmotionsArray count]];
    for (NSString *escapeCode in aliEmotionsArray) {
        RNEmotion *emotion = [[RNEmotion alloc] init];
        emotion.emotionType = Ali_Emotions;
        emotion.emotionPosition = InProjectResource;
        emotion.emotionPath = [NSString stringWithFormat:@"%@.gif",[escapeCode md5]];
        emotion.escapeCode = escapeCode;
        //[emotion save];
        [aliEmotionsTmpArray addObject:emotion];
        [emotion release];
    }
    self.emotionMap.aliEmotionsArray = aliEmotionsTmpArray;
    [aliEmotionsTmpArray release];
    
    // 将囧囧熊表情文件与转移字符串关系写入数组
    NSArray *jjEmotionsArray = [jjEmotions componentsSeparatedByString:@","];
    NSMutableArray *jjEmotionsTmpArray = [[NSMutableArray alloc] initWithCapacity:[jjEmotionsArray count]];
    for (NSString *escapeCode in jjEmotionsArray) {
        RNEmotion *emotion = [[RNEmotion alloc] init];
        emotion.emotionType = JJ_Emotions;
        emotion.emotionPosition = InProjectResource;
        emotion.emotionPath = [NSString stringWithFormat:@"%@.gif",[escapeCode md5]];
        emotion.escapeCode = escapeCode;
        //[emotion save];
        [jjEmotionsTmpArray addObject:emotion];
        [emotion release];
    }
    self.emotionMap.jjEmotionsArray = jjEmotionsTmpArray;
    [jjEmotionsTmpArray release];
    
    
}
//下载失败
- (void)downloadFaild:(RNEmojeDownLoad *)aDownload didFailWithError:(NSError *)error{
    NSLog(@"emotion下载失败=%@",error);
}
//下载结束
- (void)downloadFinished:(RNEmojeDownLoad *)aDownload{
  [_downLoadList removeObjectAtIndex:0];
    if ([_downLoadList count]>0) {
        RNEmotion *currentemo = [_downLoadList objectAtIndex:0];
        _emotionDownLoad.url = [NSURL URLWithString: currentemo.netUrl];
        _emotionDownLoad.filePath = [RCMainUser commonPath];
        _emotionDownLoad.fileName = [currentemo.escapeCode md5];
        [_emotionDownLoad start];
    }
}

@end
