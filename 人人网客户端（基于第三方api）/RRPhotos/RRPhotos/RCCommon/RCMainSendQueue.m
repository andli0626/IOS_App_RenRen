//
//  RCMainSendQueue.m
//  RRSpring
//
//  Created by jiachengwen on 12-2-28.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#define kMainSendQueueCacheDirectory @"MainSendQueue"
#define kSingleSendQueueExtension @"SingleSend"
#define kMultiSendQueueExtension @"MultiSend"
#define kTempSingleSendQueueExtension @"TempSingleSend"
#define kTempMultiSendQueueExtension @"TempMultiSend"
#define kErrorSendQueueExtension @"errorSend"

//#define kRenrenApiHostName @"api.m.renren.com"
#define kRenrenApiHostName @"mc1.test.renren.com"

#import "RCMainSendQueue.h"

static RCMainSendQueue* _sharedInstance = nil;

@implementation RCMainSendQueue

@synthesize currentSinglePost = _currentSinglePost;

+ (RCMainSendQueue *)sharedMainQueue
{
    @synchronized(self) {
        if(_sharedInstance == nil)
            [[RCMainSendQueue alloc] init];
    }
    
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if(_sharedInstance == nil) 
        {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;
        }
    }
    
    return nil;
}

- (id)init
{
    self = [super initWithHostName:kRenrenApiHostName customHeaderFields:nil];
    if(self)
    {
        _singleDispatch = [[NSMutableArray alloc] init];
        _multiDispatch = [[NSMutableArray alloc] init];
        _errorStateOfPost = [[NSMutableArray alloc] init];
        
        _currentSinglePost = nil;
        _currentMultiPost = [[NSMutableDictionary alloc] init];
        
        self.reachabilityChangedHandler = ^(NetworkStatus ns) {
            [self dealWithLinearQueue];
            [self dealWithConcurrentQueue];
        };
        
        // 保证退出时 请求可以被存储
        [self canFreezeQueue];
        
        [self restoreFrozenQueueIfNeed];

    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain 
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;
}

- (oneway void)release 
{  
    // 什么也不做
} 

- (id)autorelease 
{ 
    return self; 
}

- (void)dealloc
{
    RL_RELEASE_SAFELY(_singleDispatch);
    RL_RELEASE_SAFELY(_multiDispatch);
    RL_RELEASE_SAFELY(_errorStateOfPost);
    RL_RELEASE_SAFELY(_currentSinglePost);
    RL_RELEASE_SAFELY(_currentMultiPost);
    [super dealloc];
}

- (void)removeAllPostOperation
{
    [_singleDispatch removeAllObjects];
    [_multiDispatch removeAllObjects];
    
    [_currentMultiPost removeAllObjects];
    self.currentSinglePost = nil;
    
    // TODO: delete shared operation here
}

- (void)removePostByIdentifier:(NSString*)uniqueID
{
    // 这个地方暂时这么写 以后优化
    NSString* uid = nil;
    for(RCBasePost* post in _singleDispatch)
    {
        uid = post.postState.uniqueID;
        if([uid isEqualToString:uniqueID])
        {
            [_singleDispatch removeObject:post];
            [self postStatusChangeMessageToGlobal];
            return;
        }
    }
    
    for(RCBasePost* post in _multiDispatch)
    {
        uid = post.postState.uniqueID;
        if([uid isEqualToString:uniqueID])
        {
            [_multiDispatch removeObject:post];
            [self postStatusChangeMessageToGlobal];
            return;
        }
    }
    
    for(RCPostState* state in _errorStateOfPost)
    {
        uid = state.uniqueID;
        if([uid isEqualToString:uniqueID])
        {
            [_errorStateOfPost removeObject:state];
            [self postStatusChangeMessageToGlobal];
            return;
        }
    }
}

- (NSMutableDictionary*)listAllPostOperations
{
    NSMutableDictionary* dics = [NSMutableDictionary dictionary];
    
    NSMutableArray* section = [NSMutableArray array];
    NSMutableArray* send = [NSMutableArray array];
    @synchronized(_currentSinglePost) {
        
        if(_currentSinglePost)
        {
            RCPostState* state = _currentSinglePost.postState;
            state.canRemoveFromQueue = NO;
            
            [send addObject:state];
        }
    }
    
    @synchronized(_currentMultiPost) {
        if(_currentMultiPost)
        {
            NSArray* objs = [_currentMultiPost allValues];
            [objs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                RCBasePost* tmp = obj;
                tmp.postState.canRemoveFromQueue = NO;
                
                [send addObject:tmp.postState];
            }];
        }
    }
    if([send count] > 0)
    {
        [dics setObject:send forKey:NSLocalizedString(@"正在发送", @"正在发送") ];
        [section addObject:NSLocalizedString(@"正在发送", @"正在发送") ];
    }
    
    NSMutableArray* wait = [NSMutableArray array];
    @synchronized(_multiDispatch) {
        [_multiDispatch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            RCBasePost* tmp = obj;
            [wait addObject:tmp.postState];
        }];
    }
    
    @synchronized(_singleDispatch) {
        [_singleDispatch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            RCBasePost* tmp = obj;
            [wait addObject:tmp.postState];
        }];
    }
    if([wait count] > 0)
    {
        [dics setObject:wait forKey:NSLocalizedString(@"等待发送", @"等待发送")];
        [section addObject:NSLocalizedString(@"等待发送", @"等待发送")];
    }
    
    NSMutableArray* error = [NSMutableArray array];
    @synchronized(_errorStateOfPost) {
        [_errorStateOfPost enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            RCPostState* state = obj;
            [error addObject:state];
            
        }];
    }
    if([error count] > 0)
    {
        [dics setObject:wait forKey:NSLocalizedString(@"发送失败", @"发送失败")];
        [section addObject:NSLocalizedString(@"发送失败", @"发送失败")];
    }
    
    if([section count] > 0)
        [dics setObject:section forKey:@"sections"];
    
    return dics;
}

/**
 * 添加到线性发送队列
 */
- (void)addToErrorStateQueue:(RCPostState *) state
{
    @synchronized(_errorStateOfPost) {
        [_errorStateOfPost addObject:state];
    }
}

- (void)addToConcurrentQueue:(RCBasePost *) postOperation
{

    postOperation.postStateChanged = ^(RCBasePost* basePost) {
        // 从后台恢复回来的临时队列 存储到本地
        if(basePost.postState.ePostState == EPostStateFinished)
        {
            [_currentMultiPost removeObjectForKey:[basePost uniqueIdentifier]];
                
            [self dealWithConcurrentQueue];
            
            [self postStatusToStatusBar:NO];
            [self postStatusChangeMessageToGlobal];
        }
        else if(basePost.postState.ePostState == EPostStateError)
        {
            RCBasePost* temp = [_currentMultiPost objectForKey:[basePost uniqueIdentifier]];
            temp.postState.ePostState = EPostStateError;
            [_multiDispatch addObject:temp];
            
            [_currentMultiPost removeObjectForKey:[basePost uniqueIdentifier]];
            
            [self dealWithConcurrentQueue];
            
            [self postStatusToStatusBar:NO];
            [self postStatusChangeMessageToGlobal];
        }
        else if(basePost.postState.ePostState == EPostStateExecuting)
        {
            RCBasePost* temp = [_currentMultiPost objectForKey:[basePost uniqueIdentifier]];
            temp.postState.ePostState = EPostStateExecuting;
            
            [self postStatusToStatusBar:NO];
            [self postStatusChangeMessageToGlobal];
        }
    };
    
    [_multiDispatch addObject:postOperation];
    
    [self dealWithConcurrentQueue];
    
    [self postStatusToStatusBar:YES];
    [self postStatusChangeMessageToGlobal];
}

- (void)addToLinearQueue:(RCBasePost *) postOperation
{
    postOperation.postStateChanged = ^(RCBasePost* basePost) {
        if(basePost.postState.ePostState == EPostStateFinished)
        {
            self.currentSinglePost = nil;
            
            [self dealWithLinearQueue];
            
            [self postStatusToStatusBar:NO];
            [self postStatusChangeMessageToGlobal];
        }
        else if(basePost.postState.ePostState == EPostStateError)
        {
            self.currentSinglePost.postState.ePostState = EPostStateError;
            [_singleDispatch addObject:self.currentSinglePost];
            self.currentSinglePost = nil;

            [self dealWithLinearQueue];
            
            [self postStatusToStatusBar:NO];
            [self postStatusChangeMessageToGlobal];
        }
        else if(basePost.postState.ePostState == EPostStateExecuting)
        {
            self.currentSinglePost.postState.ePostState = EPostStateExecuting;
            
            [self postStatusToStatusBar:NO];
            [self postStatusChangeMessageToGlobal];
        }
        
    };
    
    [_singleDispatch addObject:postOperation];
    
    [self dealWithLinearQueue];
    
    [self postStatusToStatusBar:YES];
    [self postStatusChangeMessageToGlobal];
}

- (void)dealWithConcurrentQueue
{
    if([super reachabilityStatus] == NotReachable)
        return;
    
    if([_multiDispatch count] > 0)
    {
        NSUInteger count = [super operationsCount];
        
        // 预留一个并发给图片队列.
        switch ([super reachabilityStatus]) {
            case ReachableViaWiFi:
                // wifi情况下最多6个并发，包含一个图片队列的预留。
                if(count <= 4 ) 
                {
                    RCBasePost* ops = [_multiDispatch objectAtIndex:0];
                    NSString* struid = [ops uniqueIdentifier];
                    
                    [_currentMultiPost setObject:ops forKey:struid];
                    [_multiDispatch removeObjectAtIndex:0];
                    
                    RCBasePost* temp = [ops copy];
                    [super enqueueOperation:temp];
                    RL_RELEASE_SAFELY(temp);
                }
                break;
            case ReachableViaWWAN:
                // 除wifi情况下最多2个并发（mk功能)。
                if(count < 1 )
                {
                    RCBasePost* ops = [_multiDispatch objectAtIndex:0];
                    NSString* struid = [ops uniqueIdentifier];
                    
                    [_currentMultiPost setObject:ops forKey:struid];
                    [_multiDispatch removeObjectAtIndex:0];
                    
                    RCBasePost* temp = [ops copy];
                    [super enqueueOperation:temp];
                    RL_RELEASE_SAFELY(temp);
                }
                break;
                
            default:
                break;
        }
    }
}

- (void)dealWithLinearQueue
{
    if([super reachabilityStatus] == NotReachable)
        return;
        
    if([_singleDispatch count] > 0 && _currentSinglePost == nil)
    {
        self.currentSinglePost = [_singleDispatch objectAtIndex:0];
        [_singleDispatch removeObjectAtIndex:0];
        
        RCBasePost* temp = [self.currentSinglePost copy];
        [super enqueueOperation:temp];
        RL_RELEASE_SAFELY(temp);
    }
}

- (void)postStatusChangeMessageToGlobal
{
    int count = 0;
    count += [_singleDispatch count];
    count += [_multiDispatch count];
    
    if(self.currentSinglePost)
        count += 1;
    
    count += [[_currentMultiPost allKeys] count];
    
    NSNumber* num = [NSNumber numberWithInt:count];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMainSendQueueStatusChanged object:num];
}

- (void)postStatusToStatusBar:(BOOL)isAddnew
{
    if(_isInLunching)
        return;
    
    NSMutableDictionary* dics = [NSMutableDictionary dictionaryWithCapacity:3];
    if(isAddnew)
    {
        // insert 作为statusbar的状态判断条件
        [dics setObject:@"insert" forKey:@"insert"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMainSendQueueStatusBarMessage object:dics];
    }
    else
    {
        // 当前正在执行的放到第一个
        if(self.currentSinglePost || [_currentMultiPost count] > 0)
        {
            [dics setObject:@"excute" forKey:@"excute"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMainSendQueueStatusBarMessage object:dics];
            return;
        }
        
        if([_errorStateOfPost count] > 0)
        {
            [dics setObject:@"error" forKey:@"error"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMainSendQueueStatusBarMessage object:dics];
            return;
        }
        
        int count = 0;
        count += [_singleDispatch count];
        count += [_multiDispatch count];
        count += [_errorStateOfPost count];
        
        if(count == 0)
        {
            [dics setObject:@"success" forKey:@"success"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMainSendQueueStatusBarMessage object:dics];
            return;
        }
    }
}

- (NSString*)cacheSendQueueDirectoryName 
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:kMainSendQueueCacheDirectory];
    return cacheDirectoryName;
}

- (void)canFreezeQueue 
{
    
    NSString *cacheDirectory = [self cacheSendQueueDirectoryName];
    BOOL isDirectory = YES;
    BOOL folderExists = [[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDirectory] && isDirectory;
    
    if (!folderExists)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSendQueue)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSendQueue)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

-(void) saveSendQueue 
{
    // TODO: save temp operations
    NSString* uid = nil;
    if(_currentSinglePost)
    {
        uid = _currentSinglePost.postState.uniqueID;
        NSString *archivePath = [[[self cacheSendQueueDirectoryName] stringByAppendingPathComponent:uid] stringByAppendingPathExtension:kTempSingleSendQueueExtension];
        [NSKeyedArchiver archiveRootObject:_currentSinglePost toFile:archivePath];
    }
    
    for(RCBasePost *operation in [_currentMultiPost allValues]) 
    {
        uid = operation.postState.uniqueID;
        NSString *archivePath = [[[self cacheSendQueueDirectoryName] stringByAppendingPathComponent:uid] stringByAppendingPathExtension:kTempMultiSendQueueExtension];
        [NSKeyedArchiver archiveRootObject:operation toFile:archivePath];
    }
    
    for(RCBasePost *operation in _singleDispatch) 
    {
        uid = operation.postState.uniqueID;
        NSString *archivePath = [[[self cacheSendQueueDirectoryName] stringByAppendingPathComponent:uid] stringByAppendingPathExtension:kSingleSendQueueExtension];
        [NSKeyedArchiver archiveRootObject:operation toFile:archivePath];
    }
    
    for(RCBasePost *operation in _multiDispatch) 
    {
        uid = operation.postState.uniqueID;
        NSString *archivePath = [[[self cacheSendQueueDirectoryName] stringByAppendingPathComponent:uid] stringByAppendingPathExtension:kMultiSendQueueExtension];
        [NSKeyedArchiver archiveRootObject:operation toFile:archivePath];
    }
    
    for(RCPostState *state in _errorStateOfPost) 
    {
        NSString *archivePath = [[[self cacheSendQueueDirectoryName] stringByAppendingPathComponent:state.uniqueID] stringByAppendingPathExtension:kErrorSendQueueExtension];
        [NSKeyedArchiver archiveRootObject:state toFile:archivePath];
    }
    
    [_singleDispatch removeAllObjects];
    [_multiDispatch removeAllObjects];
    [_errorStateOfPost removeAllObjects];
}

- (void)restoreFrozenQueueIfNeed {
    
    _isInLunching = YES;
    
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cacheSendQueueDirectoryName] error:&error];
    
    // TODO: restore temp operations.
    NSString *pendingOperationFile = nil;
    NSArray *pendingOperations = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *thisFile = (NSString*) evaluatedObject;
        return ([thisFile rangeOfString:kTempSingleSendQueueExtension].location != NSNotFound);             
    }]];
    
    // 1.临时串行队列
    for(pendingOperationFile in pendingOperations)
    {
        // 应该只有一个
        NSString *archivePath = [[self cacheSendQueueDirectoryName] stringByAppendingPathComponent:pendingOperationFile];
        RCBasePost* temp = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
        
        [self addToLinearQueue:temp];
        
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:archivePath error:&error];
    }
    
    pendingOperations = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *thisFile = (NSString*) evaluatedObject;
        return ([thisFile rangeOfString:kTempMultiSendQueueExtension].location != NSNotFound);             
    }]];
    
    // 临时并行队列
    for(pendingOperationFile in pendingOperations)
    {
        // 可有多个
        NSString *archivePath = [[self cacheSendQueueDirectoryName] stringByAppendingPathComponent:pendingOperationFile];
        RCBasePost *pendingOperation = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
        
        [self addToConcurrentQueue:pendingOperation];

        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:archivePath error:&error];
    }

    // 3. 单并发队列
    pendingOperations = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *thisFile = (NSString*) evaluatedObject;
        return ([thisFile rangeOfString:kSingleSendQueueExtension].location != NSNotFound);             
    }]];
    
    for(pendingOperationFile in pendingOperations) {
        
        NSString *archivePath = [[self cacheSendQueueDirectoryName] stringByAppendingPathComponent:pendingOperationFile];
        RCBasePost *pendingOperation = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
//        [_singleDispatch addObject:pendingOperation];
        [self addToLinearQueue:pendingOperation];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:archivePath error:&error];
    }
    
    // 4.多并发队列
    pendingOperations = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *thisFile = (NSString*) evaluatedObject;
        return ([thisFile rangeOfString:kMultiSendQueueExtension].location != NSNotFound);             
    }]];
    
    for(pendingOperationFile in pendingOperations) {
        
        NSString *archivePath = [[self cacheSendQueueDirectoryName] stringByAppendingPathComponent:pendingOperationFile];
        RCBasePost *pendingOperation = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
//        [_multiDispatch addObject:pendingOperation];
        [self addToConcurrentQueue:pendingOperation];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:archivePath error:&error];
    }
    
    // 5.发送成功但返回错误数据的
    pendingOperations = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *thisFile = (NSString*) evaluatedObject;
        return ([thisFile rangeOfString:kErrorSendQueueExtension].location != NSNotFound);             
    }]];
    
    for(pendingOperationFile in pendingOperations) {
        
        NSString *archivePath = [[self cacheSendQueueDirectoryName] stringByAppendingPathComponent:pendingOperationFile];
        RCPostState *state = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];

        [_errorStateOfPost addObject:state];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:archivePath error:&error];
    }
    
    _isInLunching = NO;
}

@end
