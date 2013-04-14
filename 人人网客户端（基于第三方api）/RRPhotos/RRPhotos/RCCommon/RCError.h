//
//  RCError.h
//  xiaonei
//
//  Created by wenhuaqiang on 10-4-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 人人Rest接口错误返回代码定义.
 */
typedef enum {
	RRErrorCodeSuccess						= 99999999,// 自定义,表示成功.
	RRErrorCodeUnknowError					= 1, // 未知错误
	RRErrorCodeServiceUnavailable			= 2, // 服务临时不可用，请您稍候再试
	RRErrorCodeUnknowMethodError            = 3, // 未知方法错误
	RRErrorCodeRequestTooFast				= 4, // 操作过于频繁
	RRErrorCodeRequestXOAError				= 5, // XOA服务异常，请稍候重试（依赖接口问题）
	RRErrorCodeRequestICEError				= 6, // ICE服务异常，请稍候重试（平台自身问题）
    RRErrorCodeAntispam						= 10, // 发布内容不合法（antispam统一返回数据）
	RRErrorCodeParameterError				= 100, // 无效未知参数
	RRErrorCodeApiKeyError					= 101, // 无效的API_KEY
	RRErrorCodeSessionKeyError				= 102, // 无效的SESSION_KEY
	RRErrorCodeJsonParamError				= 103, // JSON参数格式有误
	RRErrorCodeInvalidSIError				= 104, // 无效的签名
	RRErrorCodeInvalidRequiredParam			= 105, // 输入参数不合法
	RRErrorCodePrivacyLimit					= 200, // 由于对方的隐私设置，您没有权限执行该操作
	RRErrorCodeSessionFormatError			= 452, // 搜索失败
    RRErrorCodeUsernameOrPasswordError		= 10000, // 登录失败
	RRErrorCodeUserNotExist					= 10001, // 用户不存在
	RRErrorCodePasswordError				= 10002, // 密码错误。
	RRErrorCodeUserAudit					= 10003, // 用户被冻结。
	RRErrorCodeUserBand						= 10004, // 用户被封禁。
	RRErrorCodeUserSuicide					= 10005, // 用户已经注销。
	RRErrorCodeDataError					= 10200, // 您提交的数据有误,请核对后重新发送
	RRErrorCodeLackOfApiKey					= 10201, // lack of api_key
	RRErrorCodeLackOfSessionKey				= 10202, // lack of session_key
	RRErrorCodeLackOfVersion				= 10204, // lack of version
	RRErrorCodeLackOfSig					= 10205, // lack of sig
	RRErrorCodeLackOfMethod					= 10206, // lack of method
	RRErrorCodeLackOfRequiredParam			= 10207, // lack of required parameter
	RRErrorCodeBlogNonExist					= 10300, // 日志不存在
	RRErrorCodeIllegalContent				= 20000, // 请不要发布政治敏感内容、色情内容、商业广告或其他不恰当内容 :D
	RRErrorCodeSourceNotExist				= 20001, // 访问资源不存在
	RRErrorCodeTextTooLong					= 20002, // 输入文本长度超限制
	RRErrorCodeEcPasswordError				= 20003, // 相册或日志密码错误
	RRErrorCodeSystemBusy					= 20004, // 底层依赖服务异常
	RRErrorCodeBlackListForbidde			= 20006, // 黑名单限制访问
	RRErrorCodeEcParamTextError				= 20007, // 文本格式非法
	RRErrorCodePhotoAlbumNotExist			= 20100, // 上传照片所选的相册不存在
	RRErrorCodePhotoAlbumFail				= 20101, // 上传照片失败
	RRErrorCodePhotoWrongType				= 20102, // 上传照片类型错误
	RRErrorCodePhotoUnknown					= 20103, // 上传照片类型未知
	RRErrorCodePhotoNeedPassword            = 20105, //　加密相册，访问需要密码　sunyu added
    RRErrorCodeAlbumFull                    = 20106, // 相册已满
    RRErrorCodeHeadAlbumNotSupport          = 20108, // 不支持上传至头像相册
	RRErrorCodeEcVedioSourceNotSupport		= 20200, // 来源不支持
	RRErrorCodeEcVedioPlatformNotSupport	= 20201, // 平台不支持
	RRErrorCodeEcVedioServiceIceError		= 20202, // ICE服务错误
	RRErrorCodeEcVedioInterfaceError		= 20203, // 合作方接口错误
	RRErrorCodeEcShareSourceForbidden		= 20300, // 用户权限禁止分享
	RRErrorCodeEcShareSourceType			= 20301, // 分享类型不支持
	RRErrorCodeEcFriendRequestSelfError		= 20500, // 禁止加自己为好友
    RRErrorCodeApplicantFriendListFull      = 20501, // 自己好友列表已满
    RRErrorCodeRecipientFriendListFull      = 20502, // 对方好友列表已满
    RRErrorCodeFriendRequestDescError       = 20503, // 好友申请描述中有外链
    RRErrorCodeFriendRequestPrivacyLimit    = 20504, // 由于对方隐私设置，不能加对方为好友
    RRErrorCodePlaceCheckInFail             = 20400, // 签到失败
    RRErrorCodePlaceLatLonError             = 20401, // 经纬度错误
	RRErrorCodePageIsClosed					= 20601, // 公共主页已经关闭
	RRErrorCodeBlogNeedPassword             = 20701, // 访问日志需要密码
    RRErrorCodeUserBlackListed              = 20801, // 被好友拉黑
	RRErrorCodeMusicRadioNotExist			= 21001, // 电台不存在
	RRErrorCodeMusicSongNotExist			= 21002, // 歌不存在
    RRErrorCodePersonCardSyncDecodeError    = 21101, // 解密错误
    RRErrorCodePersonCardSyncFormatError    = 21102 // json解析错误

} RRErrorCode;

@interface RCError : NSError {
	
}

/**
 * 返回用于展现给用户的错误提示标题
 */
- (NSString*)titleForError;

/**
 * 返回用于展现给用户的错误提示子标题
 */
- (NSString*)subtitleForError;

/**
 * 返回由Rest接口错误信息构建的错误对象.
 */
+ (RCError*)errorWithRestInfo:(NSDictionary*)restInfo;


/**
 * 返回由NSError构建的错误对象.
 */
+ (RCError*)errorWithNSError:(NSError*)error;

/**
 * 构造RRError错误。
 *
 * @param code 错误代码
 * @param errorMessage 错误信息
 *
 * 返回错误对象.
 */
+ (RCError*)errorWithCode:(NSInteger)code errorMessage:(NSString*)errorMessage;

/**
 * 返回调用Rest Api 的 method字段的值.
 */
- (NSString*)methodForRestApi;

@end
