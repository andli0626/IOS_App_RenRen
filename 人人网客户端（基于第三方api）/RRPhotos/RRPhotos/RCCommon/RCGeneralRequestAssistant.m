//
//  RCGeneralRequestAssistant.m
//  RRSpring
//
//  Created by jiachengwen on 12-2-16.
//  Copyright (c) 2012年 Renn. All rights reserved.
//

#import "RCGeneralRequestAssistant.h"
#import "RCMainUser.h"

@implementation RCGeneralRequestAssistant

@synthesize fields = _fields;
@synthesize onCompletion = _onCompletion;
@synthesize onError = _onError;

-(void)dealloc
{
    RL_RELEASE_SAFELY(_fields);
    RL_RELEASE_SAFELY(_onCompletion);
    RL_RELEASE_SAFELY(_onError);
    [super dealloc];
}

-(id)init
{
    if(self = [super init])
    {
        operation = nil;
    }
    
    return self;
}

+(RCGeneralRequestAssistant*)requestAssistant
{
    RCGeneralRequestAssistant* assisant = [[[RCGeneralRequestAssistant alloc] init] autorelease];
    return assisant;
}

-(void)sendQuery:(NSDictionary *)query withMethod:(NSString*)method
{
    NSString *loginUrl = nil;
    NSString *secretKey = nil;
    
    RCMainUser* mainUser = [RCMainUser getInstance];
    
    NSString *key = [query objectForKey:@"key"];
    //网络请求key不一样，故此判断传入参数query中是否有key，有则用query中加密；否则用默认　2012-04-06 modify by lyfing
    if ( !key ) {
        if(mainUser.userSecretKey)
            secretKey = mainUser.userSecretKey;
        else
            secretKey = [RCConfig globalConfig].appSecretKey;
    }
    else {
        secretKey = key;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:query];
        [dic removeObjectForKey:@"key"];
        query = [NSDictionary dictionaryWithDictionary:dic];
    }
    self.fields = [NSMutableDictionary dictionaryWithDictionary:query];
    
    RCConfig *config = [RCConfig globalConfig];
    
    loginUrl = config.apiUrl;
   //app/getInfo方法不需下面部分参数，故作此判断　　　　2012-04-06 modify by lyfing
   if (![method isEqualToString:@"app/getInfo"]) {
    
    if(![self.fields objectForKey:@"api_key"])
        [self.fields setObject:config.apiKey forKey:@"api_key"];
    
    if(![self.fields objectForKey:@"uniq_id"])
        [self.fields setObject:[config udid] forKey:@"uniq_id"];
    
    if(![self.fields objectForKey:@"format"])
        [self.fields setObject:@"json" forKey:@"format"];
      
    if(![self.fields objectForKey:@"client_info"])
        [self.fields setObject:config.clientInfo forKey:@"client_info"];
    
    if(![self.fields objectForKey:@"call_id"])
        [self.fields setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"call_id"];
    }
    
    if(![self.fields objectForKey:@"v"])
        [self.fields setObject:@"1.0" forKey:@"v"];
    
    if(![self.fields objectForKey:@"gz"])
        [self.fields setObject:@"compression" forKey:@"gz"];

    NSString* hostname = [NSString stringWithFormat:@"%@/%@", loginUrl, method];
    MKNetworkOperation* op = [[MKNetworkOperation alloc] initWithURLString:hostname
                                                                           params:self.fields 
                                                                       httpMethod:@"POST"];
    operation = op;
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSString *queryStr = nil;
        queryStr = [NSString queryStringWithSignature:postDataDict 
                                          opSecretKey:secretKey
                                        valueLenLimit:50];
        NSLog(@"MK queryStr = %@",queryStr);
        
        return queryStr;
        
    } forType:@"application/x-www-form-urlencoded"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
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
        
        // 首先判断是否接口返回错误代码.
        if ([content hasPrefix:@"{\"error_code\""] 
            || [content rangeOfString:@"request_args"].length > 0) {
            
            NSData *jsonData = [content dataUsingEncoding:NSUTF32BigEndianStringEncoding];
            NSDictionary* ret = nil;
            if([content hasPrefix:@"["]){
                jsonType = 0;
                NSArray* tempArray = [[CJSONDeserializer deserializer] deserializeAsArray:jsonData error:nil];	
                if (tempArray && [tempArray count] > 0) {
                    ret = [tempArray objectAtIndex:0];
                }
            } else {
                jsonType = 1;
                ret = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];		
            }
            
        } else if (!content) {
            
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
        
        
    } onError:^(NSError *error) {
        if(self.onError)
            self.onError([RCError errorWithNSError:error]);
    }];
    
    
    [self enqueueOperation:op];
    [operation release];
    
}

-(void)cancelRequest
{
    if(!operation)
        return;
    
    [operation cancel];
}

@end
