//
//  RCError.m
//  xiaonei
//
//  Created by wenhuaqiang on 10-4-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RCError.h"
#import "RRLogger.h"


@implementation RCError

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (RCError*)errorWithRestInfo:(NSDictionary*)restInfo {
	
	NSNumber* errorCode = [restInfo objectForKey:@"error_code"];
	RRLOG_debug(@"%d=%@", [errorCode intValue], [restInfo objectForKey:@"error_msg"]);
	RCError* error = [RCError errorWithDomain:@"Renren" code:[errorCode intValue] userInfo:restInfo];
	return error;
}	

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (RCError*)errorWithNSError:(NSError*)error {
    
	RCError* myError = [RCError errorWithDomain:error.domain code:error.code userInfo:error.userInfo];
	RRLOG_debug(@"code=%d", myError.code);
	return myError;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (RCError*)errorWithCode:(NSInteger)code errorMessage:(NSString*)errorMessage {
	NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
	[userInfo setObject:[NSString stringWithFormat:@"%d", code] forKey:@"error_code"];
    if (errorMessage) {
        [userInfo setObject:errorMessage forKey:@"error_msg"];
    }
	
	RCError* error = [RCError errorWithDomain:@"Renren" code:code userInfo:userInfo];
	[userInfo release];
	return error;
	
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
	RRLOG_debug(@"domain=%@,code=%d,userInfo=%@", domain, code, dict);
	if (self = [super initWithDomain:domain code:code userInfo:dict]) {
//		NSString* method = [self methodForRestApi];
		
		// 以下几个method也有框架统一处理
/*		if (method && (NSOrderedSame == [method compare:@"photos.getComments"])) {
			//self.processMode = RRErrorProcessModel;
		} else if (method && (NSOrderedSame == [method compare:@"gossip.postGossip"])) {
			//self.processMode = RRErrorProcessModel;
		} else if (self.code == RRErrorCodePrivacyLimit) { // 以下几种情况交给模型层自行处理.
			self.processMode = RRErrorProcessModel;
		} else if(self.code == RRErrorCodeEcPasswordError){
			self.processMode = RRErrorProcessModel;
		} else if(self.code == RRErrorCodeLackOfSig){
			self.processMode = RRErrorProcessModel;
		}*/
	}
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)methodForRestApi {
	NSDictionary* userInfo = self.userInfo;
	if (!userInfo) {
		return nil;
	}
	
	NSArray* requestArgs = [userInfo objectForKey:@"request_args"];
	if (!requestArgs) {
		return nil;
	}
	
	for (NSDictionary* pair in requestArgs) {
		if (NSOrderedSame == [@"method" compare:[pair objectForKey:@"key"]]) {
			return [pair objectForKey:@"value"];
		}
	}
	
	return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForError {
	if (NSOrderedSame == [self.domain compare:@"NSURLErrorDomain"]) {
		switch (self.code) {
			case NSURLErrorNotConnectedToInternet:
                return @"网络无法连接，请您稍后再试";
			default:
				break;
		}
	} else if (NSOrderedSame == [self.domain compare:@"NSPOSIXErrorDomain"]) {
		return TTLocalizedString(@"No Internet Connection", @"网络无法连接，请您稍后再试"/*@"网络无法连接，请检查网络设置后再试"*/);
	} else {
		switch (self.code) {
			case RRErrorCodeBlogNonExist:// 10300
				return @"日志不存在";
			case RRErrorCodeIllegalContent: // 20000
				return @"可能有违禁信息, 或者内容过长";
			case RRErrorCodeUnknowError: // 1
                return @"系统服务出错（1）";
			case RRErrorCodeServiceUnavailable: // 2
                return @"系统服务出错（2）";
			case RRErrorCodeUnknowMethodError: // 3
                return @"系统服务出错（3）";
			case RRErrorCodeRequestTooFast: // 4
                return @"您的操作过于频繁，请歇一会儿再试（4）";
			case RRErrorCodeRequestICEError: // 5
                return @"系统服务出错，请稍候重试（5）";
			case RRErrorCodeRequestXOAError: // 6
                return @"系统服务出错，请稍候重试（6）";
/*
            case RRErrorCodeAntispam://10
                return @"发布内容不合法";
*/
			case RRErrorCodeParameterError: // 100
                return @"系统服务出错，请重新登录（100）";
			case RRErrorCodeApiKeyError: // 101
                return @"系统服务出错，请重新登录（101）";
			case RRErrorCodeSessionKeyError: // 102
                return @"登录失效，请重新登录（102）";
			case RRErrorCodeJsonParamError: // 103
                return @"系统服务出错，请重新登录（103）";
			case RRErrorCodeInvalidSIError: // 104
                return @"登录失效，请重新登录（104）";
			case RRErrorCodeInvalidRequiredParam: // 105
				return @"系统服务出错，请稍候重试（105）";
			case RRErrorCodePrivacyLimit: // 200
				return @"对方设置了权限，您暂时无法进行操作";
			case RRErrorCodeSessionFormatError: // 452
				return @"搜索失败，请重试";
			case RRErrorCodeUsernameOrPasswordError: // 10000
				return @"登录失败，请重试";
			case RRErrorCodeUserNotExist: // 10001
				return @"帐号或密码输入有误，请重新输入";
			case RRErrorCodePasswordError: // 10002
				return @"帐号或密码输入错误，请检查后再试";
			case RRErrorCodeUserAudit: // 10003
                 return @"您的帐号由于存在安全问题，已被暂时冻结。如需恢复，建议在电脑登录处理，或联系管理员(027-82660276)咨询恢复使用！";
			case RRErrorCodeUserBand: // 10004
                return @"您的帐号因使用不当已停止使用。如需解封，建议在电脑登录处理，或联系管理员(027-82660276)咨询恢复使用！";
			case RRErrorCodeUserSuicide: // 10005
				return @"您的帐号已注销或停止使用。如需恢复，建议在电脑登录处理，或联系管理员(027-82660276)即可原地复活继续使用！";
			case RRErrorCodeDataError: // 10200
                return @"系统服务出错（10200）";
			case RRErrorCodeLackOfApiKey: // 10201
                return @"系统服务出错（10201）";
			case RRErrorCodeLackOfSessionKey: // 10202
                return @"系统服务出错（10202）";
			case RRErrorCodeLackOfVersion: // 10204
                return @"系统服务出错（10204）";
			case RRErrorCodeLackOfSig: // 10205
                return @"系统服务出错（10205）";
			case RRErrorCodeLackOfMethod: // 10206
                return @"系统服务出错（10206）";
			case RRErrorCodeLackOfRequiredParam: // 10207
				return @"系统服务出错（10207）";
			case RRErrorCodeSourceNotExist: // 20001
				return @"您查看的内容不存在或已被作者删除";
			case RRErrorCodeTextTooLong: // 20002
				return @"您发送的字数超过限制，请重试";
			case RRErrorCodeEcPasswordError: // 20003
				return @"您输入的密码错误，请重试";
			case RRErrorCodeSystemBusy: // 20004
				return @"系统服务出错，请稍后再试（20004）";
			case RRErrorCodeBlackListForbidde: // 20006
				return @"对方设置了权限，您暂时无法操作";
			case RRErrorCodeEcParamTextError: // 20007
				return @"您所输入的内容含有非法字符，请检查";
			case RRErrorCodePhotoAlbumNotExist: // 20100
				return @"您所选择的相册已删除，请重新选择相册";
			case RRErrorCodePhotoAlbumFail: // 20101
				return @"上传照片失败，请稍后重试";
            case RRErrorCodeAlbumFull: // 20106
                return @"相册中的照片已满，请重新选择";
			case RRErrorCodePhotoWrongType: // 20102
                return @"暂不支持此格式照片，请重新选择（20102）";
			case RRErrorCodePhotoUnknown: // 20103
				return @"暂不支持此格式照片，请重新选择（20103）";
            case RRErrorCodePhotoNeedPassword: // 20105
				return @"请输入相册密码";
            case RRErrorCodeHeadAlbumNotSupport: // 20108
                return @"暂不支持上传照片至头像相册，请重新选择相册后上传";
			case RRErrorCodeEcVedioSourceNotSupport: // 20200
                return @"暂时无法查看此内容，请稍后重试（20200）";
			case RRErrorCodeEcVedioPlatformNotSupport: // 20201
                return @"暂时无法查看此内容，请稍后重试（20201）";
			case RRErrorCodeEcVedioServiceIceError: // 20202
                return @"暂时无法查看此内容，请稍后重试（20202）";
			case RRErrorCodeEcVedioInterfaceError: // 20203
				return @"暂时无法查看此内容，请稍后重试（20203）";
			case RRErrorCodeEcShareSourceForbidden: // 20300
				return @"对方设置了权限，您暂时无法操作";
			case RRErrorCodeEcShareSourceType: // 20301
				return @"暂不支持分享此类型（20301）";
			case RRErrorCodeEcFriendRequestSelfError: // 20500
				return @"您无法加自己为好友（20501）";
            case RRErrorCodeApplicantFriendListFull: // 20501
                return @"您的好友数已达上限，无法添加好友";
            case RRErrorCodeRecipientFriendListFull: // 20502
                return @"对方好友数已达上限，无法添加好友";
            case RRErrorCodeFriendRequestDescError: // 20503
                return @"客户端无法收到此请求";
            case RRErrorCodeFriendRequestPrivacyLimit: // 20504
                return @"由于对方隐私设置，暂时不能加为好友";
			case RRErrorCodePageIsClosed: // 20601
				return @"您所查看公共主页已关闭";
            case RRErrorCodePlaceCheckInFail: // 20400
                return @"报到失败，请稍后重试";
            case RRErrorCodePlaceLatLonError: // 20401
                return @"无法获取您的位置";
			case RRErrorCodeMusicRadioNotExist: // 21001
				return @"电台不存在";
			case RRErrorCodeMusicSongNotExist: // 21002
				return @"歌不存在";
            case RRErrorCodeUserBlackListed: // 20801
				return @"对方设置了权限，您暂时无法转发此内容";
			case RRErrorCodeBlogNeedPassword: // 20701
				return @"请输入日志密码";
			
            case RRErrorCodePersonCardSyncDecodeError: // 21101
                return @"通讯录服务错误（21101）";
            case RRErrorCodePersonCardSyncFormatError: // 21102
				return @"通讯录服务错误（21102）";
				
		}
	}

	
	NSString* title = [self.userInfo objectForKey:@"error_msg"];
	title = title ? title : @"系统服务繁忙，请稍后再试";
	return title;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError {
	return nil;
}

@end
