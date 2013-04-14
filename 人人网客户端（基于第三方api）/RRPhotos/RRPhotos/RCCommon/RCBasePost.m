//
//  RCBasePost.m
//  RRSpring
//
//  Created by jiachengwen on 12-2-28.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCBasePost.h"

@implementation RCPostState

@synthesize ePostState = _ePostState;
@synthesize error = _error;
@synthesize title = _title;
@synthesize sendTime = _sendTime;
@synthesize thumbnails = _thumbnails;
@synthesize itemType = _itemType;
@synthesize canRemoveFromQueue = _canRemoveFromQueue;
@synthesize uniqueID;


-(id)init
{
    self = [super init];
    if(self)
    {
        _ePostState = EPostStateReady;
        _itemType = EPostTypeNone;
        _canRemoveFromQueue = YES;
    }
    return self;
}

-(void)dealloc
{
    RL_RELEASE_SAFELY(_error);
    RL_RELEASE_SAFELY(_title);
    RL_RELEASE_SAFELY(_sendTime)
    RL_RELEASE_SAFELY(_thumbnails);
    
    [super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeInteger:self.ePostState forKey:@"ePostState"];
    [encoder encodeObject:self.error forKey:@"error"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.sendTime forKey:@"sendTime"];
    [encoder encodeObject:self.thumbnails forKey:@"thumbnails"];
    [encoder encodeInteger:self.itemType forKey:@"itemType"];
    [encoder encodeBool:self.canRemoveFromQueue forKey:@"canRemoveFromQueue"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.ePostState = EPostStateReady;
        self.error = [decoder decodeObjectForKey:@"error"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.sendTime = [decoder decodeObjectForKey:@"sendTime"];
        self.thumbnails = [decoder decodeObjectForKey:@"thumbnails"];
        self.itemType = [decoder decodeIntegerForKey:@"itemType"];
        self.canRemoveFromQueue = [decoder decodeBoolForKey:@"canRemoveFromQueue"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    RCPostState *theCopy = [[[self class] allocWithZone:zone] init];  // use designated initializer
    
    [theCopy setEPostState:self.ePostState];
    [theCopy setError:[self.error copy]];
    [theCopy setTitle:[self.title copy]];
    [theCopy setSendTime:[self.sendTime copy]];
    [theCopy setThumbnails:[self.thumbnails copy]];
    [theCopy setItemType:self.itemType];
    [theCopy setCanRemoveFromQueue:self.canRemoveFromQueue];
    
    return theCopy;
}

- (NSString*)uniqueID
{
    NSString* str = [_title stringByAppendingString:_sendTime];
    return [str md5];
}

- (NSString*)description
{
    NSString* descrip = [NSString stringWithFormat:@"%@,%@,%@.", _title, _sendTime, _error];
    return descrip;
}

@end

@interface RCBasePost ()

-(void)postResponseMessage:(NSString*)response;

@end


@implementation RCBasePost

@synthesize postStateChanged = _postStateChanged;
@synthesize postState = _postState;

-(id)init
{
    if(self = [super init])
    {
        _postState = [[RCPostState alloc] init];
        // 
        self.operationStateChangedHandler = ^(MKNetworkOperationState newState) {
            switch (newState) {
                case MKNetworkOperationStateReady:
                {
                    self.postState.ePostState = EPostStateReady;
                    if(self.postStateChanged)
                        self.postStateChanged(self);

                    break;
                }
                    
                case MKNetworkOperationStateExecuting:
                {
                    self.postState.ePostState = EPostStateExecuting;
                    if(self.postStateChanged)
                        self.postStateChanged(self);
                    break;
                }
                 
                // 由operationSucceeded和operationFailedWithError处理这个状态
          //      case MKNetworkOperationStateFinished:
          //          self.postState.ePostState = EPostStateFinished;
          //          break;
                    
                default:
                    break;
            }
            
        };
    }
    
    return self;
}

- (id)initWithURLString:(NSString *)aURLString
                 params:(NSMutableDictionary *)params
             httpMethod:(NSString *)method
{
    self = [super initWithURLString:aURLString params:params httpMethod:method];
    if(self)
    {
        if(!_postState)
            _postState = [[RCPostState alloc] init];
        self.operationStateChangedHandler = ^(MKNetworkOperationState newState) {
            switch (newState) {
                case MKNetworkOperationStateReady:
                {
                    self.postState.ePostState = EPostStateReady;
                    if(self.postStateChanged)
                        self.postStateChanged(self);
                    
                    break;
                }
                    
                case MKNetworkOperationStateExecuting:
                {
                    self.postState.ePostState = EPostStateExecuting;
                    if(self.postStateChanged)
                        self.postStateChanged(self);
                    break;
                }
                    
                default:
                    break;
            }
        };
    }
    return self;
}

-(void)dealloc
{
    RL_RELEASE_SAFELY(_postState);
    RL_RELEASE_SAFELY(_postStateChanged);
    [super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.postState forKey:@"postState"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super initWithCoder:decoder];
    if (self) {
        self.postState = [decoder decodeObjectForKey:@"postState"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
//    RCBasePost *theCopy = [[[self class] allocWithZone:zone] init];  // use designated initializer
    RCBasePost *theCopy = [super copyWithZone:zone];
    
    [theCopy setPostState:[self.postState copy]];
    [theCopy setPostStateChanged:[self.postStateChanged copy]];
    
    return theCopy;
}


-(NSString*)curlCommandLineString
{
    // 通过sig值保证此函数返回值的唯一性。
    NSMutableURLRequest* rqst = [super operationRequest];
    __block NSMutableString *displayString = [NSMutableString stringWithFormat:@"curl -X %@", rqst.HTTPMethod];
    
    [displayString appendFormat:@" \"%@\"",  self.url];
    
    NSMutableDictionary* query = [super operationQueries];
    NSString *option = [query count] == 0 ? @"-d" : @"-F";
    [query enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        [displayString appendFormat:@" %@ \"%@=%@\"", option, key, obj];    
    }];
    
    
    return displayString;
}

-(void)operationSucceeded
{
    if(self.postStateChanged)
    {
        self.postState.ePostState = EPostStateFinished;
        self.postStateChanged(self);
    }
    
    [self postResponseMessage:self.responseString];

    [super operationSucceeded];
}

-(void)operationFailedWithError:(NSError *)error
{
    if(self.postStateChanged)
    {
        self.postState.ePostState = EPostStateError;
        self.postStateChanged(self);
    }
    
    NSString* result = @"network_error";
    [self postResponseMessage:result];
    
    [super operationFailedWithError:error];
}

-(void)postResponseMessage:(NSString*)response
{
//    NSString* name = nil;
//    switch (self.postState.itemType) {
//        case EPostTypePhoto:
//            name = kPostTypePhoto;
//            break;
//        default:
//            break;
//    }
    if(self.postState.sendTime != nil && response != nil)
    {
        NSMutableDictionary* dics = [NSMutableDictionary dictionaryWithCapacity:2];
        [dics setObject:response forKey:@"result"];
        [dics setObject:self.postState.sendTime forKey:@"call_id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPostTypeWebView object:dics];
    }
}

@end
