//
//  RCBaseRequest.m
//  RRSpring
//
//  Created by jiachengwen on 12-2-21.
//  Copyright (c) 2012年 Renn. All rights reserved.
//

#import "RCBaseRequest.h"
#import "RCMainUser.h"

@implementation RCBaseRequest

@synthesize operation = _operation;
@synthesize fields = _fields;
@synthesize secretKey = _secretKey;
@synthesize onCompletion = _onCompletion;
@synthesize onError = _onError;

-(void)dealloc
{
    RL_RELEASE_SAFELY(_fields);
    RL_RELEASE_SAFELY(_secretKey);
    RL_RELEASE_SAFELY(_onCompletion);
    RL_RELEASE_SAFELY(_onError);
    [super dealloc];
}

-(id)init
{
    if(self = [super init])
    {
        _operation = nil;

        RCMainUser* mainUser = [RCMainUser getInstance];
        if(mainUser.userSecretKey)
            self.secretKey = mainUser.userSecretKey;
        else
            self.secretKey = [RCConfig globalConfig].appSecretKey;
    }
    
    return self;
}

-(void)cancelRequest
{
    if(!_operation)
        return;
    
    [_operation cancel];
}

-(void)sendQuery:(NSDictionary *)query withMethod:(NSString*)method
{
    self.fields = [NSMutableDictionary dictionaryWithDictionary:query];
    
    RCConfig *config = [RCConfig globalConfig];
    NSString *loginUrl = config.apiUrl;
    
    if(![self.fields objectForKey:@"api_key"])
        [self.fields setObject:config.apiKey forKey:@"api_key"];
    
    if(![self.fields objectForKey:@"v"])
        [self.fields setObject:@"1.0" forKey:@"v"];
    
    if(![self.fields objectForKey:@"uniq_id"])
        [self.fields setObject:[config udid] forKey:@"uniq_id"];
    
    if(![self.fields objectForKey:@"format"])
        [self.fields setObject:@"json" forKey:@"format"];
    
    if(![self.fields objectForKey:@"client_info"])
        [self.fields setObject:config.clientInfo forKey:@"client_info"];
    
    if(![self.fields objectForKey:@"call_id"])
        [self.fields setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"call_id"];
    
    if(![self.fields objectForKey:@"gz"])
        [self.fields setObject:@"compression" forKey:@"gz"];
    
    NSString* hostname = [NSString stringWithFormat:@"%@/%@", loginUrl, method];
    MKNetworkOperation* operation = [[MKNetworkOperation alloc] initWithURLString:hostname
                                                                           params:self.fields 
                                                                       httpMethod:@"POST"];
    
    NSLog(@"<fields>%@ </fields>",self.fields);
    
    NSString* contentType = @"application/x-www-form-urlencoded";
    [operation setCustomPostDataEncodingHandler:[self postDataEncodingHandler] forType:contentType];
    
    [operation onCompletion:[self completionHandler] onError:[self errorHandler]];
    
    [self enqueueOperation:operation];
    
    _operation = operation;
    [operation release];
    
}

-(MKNKEncodingBlock)postDataEncodingHandler
{
    MKNKEncodingBlock block = ^NSString *(NSDictionary *postDataDict) {
        NSString *queryStr = nil;
        queryStr = [NSString queryStringWithSignature:postDataDict 
                                          opSecretKey:self.secretKey 
                                        valueLenLimit:50];
        
        return queryStr;
        
    };
    
    return [[block copy] autorelease];
}

-(MKNKResponseBlock)completionHandler
{
    MKNKResponseBlock block = ^(MKNetworkOperation *completedOperation) {
        NSData* data = completedOperation.responseData;
        
        NSData *tempReceivedData = [data gzipInflate];
        NSString *content;
        if([tempReceivedData length] >0){
            content = [[[NSString alloc]
                        initWithData: tempReceivedData
                        encoding: NSUTF8StringEncoding] autorelease];
        } else {
            content = [[[NSString alloc]
                        initWithData: data
                        encoding: NSUTF8StringEncoding] autorelease];
        }
        
        if(content == nil)
            return;
        
        int jsonType = 0;
        if([content hasPrefix:@"["]){
            jsonType = 0;//RRJSONObjectTypeArray;
        } else {
            jsonType = 1;//RRJSONObjectTypeDictionary;
        }
        
        id rootObject = nil;
        switch (jsonType) {
            case 1: {
                NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
                if([content hasPrefix:@"["]) {
                    NSArray* tempArray = [[CJSONDeserializer deserializer] deserializeAsArray:jsonData error:nil];	
                    if (tempArray && [tempArray count] > 0) {
                        rootObject = [tempArray objectAtIndex:0];
                    }
                } else {
                    rootObject = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
                }
                
                //处理火星文
                if (!rootObject) {
                    content =[[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
                    
                    // 没有必要使用UTF32BigEndian来编码。
                    NSData *jsonDataHuo = [content dataUsingEncoding:NSUTF8StringEncoding]; 
                    if([content hasPrefix:@"["]){
                        NSArray* tempArray = [[CJSONDeserializer deserializer] deserializeAsArray:jsonDataHuo error:nil];	
                        if (tempArray && [tempArray count] > 0) {
                            rootObject = [tempArray objectAtIndex:0];
                        }
                    } else {
                        rootObject = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonDataHuo error:nil];		
                    }
                    rootObject = [RLUtility convertAsacIItoUTF8:rootObject];
                    
                    [content release];
                }
                
                break;
            }
            case 0: {
                // 没有必要使用UTF32BigEndian来编码。
                NSData *jsonDataArray = [content dataUsingEncoding:NSUTF8StringEncoding];
                rootObject = [[CJSONDeserializer deserializer] deserializeAsArray:jsonDataArray error:nil];
                
                //处理火星文
                if (!rootObject) {
                    content =[[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
                    
                    NSData *jsonDataArrayHuo = [content dataUsingEncoding:NSUTF8StringEncoding];
                    rootObject = [[CJSONDeserializer deserializer] deserializeAsArray:jsonDataArrayHuo error:nil]; // memory leaks?
                    
                    [content release];
                } else {
                }
                break;
            }
            default:
                break;
        }
        
        NSDictionary* dics = (NSDictionary*)rootObject;
        if([dics objectForKey:@"error_code"])
        {
            if(self.onError)
                self.onError([RCError errorWithRestInfo:rootObject]);
            return;
            
        }
        
        if(self.onCompletion)
            self.onCompletion(rootObject);
    };
    
    return [[block copy] autorelease];
}

-(MKNKErrorBlock)errorHandler
{
    MKNKErrorBlock block = ^(NSError *error) {
        if(self.onError)
            self.onError([RCError errorWithNSError:error]);
    };
    
    return [[block copy] autorelease];
}

@end
