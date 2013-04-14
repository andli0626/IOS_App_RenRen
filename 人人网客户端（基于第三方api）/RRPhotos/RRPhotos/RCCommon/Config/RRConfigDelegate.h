//
//  RRConfigDelegate.h
//  RenrenCore
//
//  Created by Cloud Sun on 10-10-12.
//  Copyright 2010 www.renren.com. All rights reserved.
//

@protocol RRConfigDelegate <NSObject>

// Open Platform API Key
@property (nonatomic, copy) NSString *opApiKey;

// Open Platform API URL
@property (nonatomic, copy) NSString *opApiUrl;

// 3G API URL
@property (nonatomic, copy) NSString *mApiUrl;

// Open Platform Secret Key
@property (nonatomic, copy) NSString *opSecretKey;

// Open Platform 登录接口地址
@property (nonatomic, copy) NSString *opLoginUrl;

// Client name.
@property (nonatomic, copy) NSString *clientName;

// Client version.
@property (nonatomic, copy) NSString *version;

// Client fromType.
@property (nonatomic, copy) NSString *fromType;

// Client fromID.
@property (nonatomic, copy) NSString *fromID;

// Device model.
@property (nonatomic, copy) NSString *model;

// Client Info.
@property (nonatomic, readonly) NSString *clientInfoJSONString;
@property (nonatomic, copy) NSString *imageCachePath;
@property (nonatomic, copy) NSString *emotionsPath;
@property (nonatomic, copy) NSString *databasePath;
@property (nonatomic, copy) NSString *pubdate;
@property (nonatomic, copy) NSString *configFilePath;


@end
