//
//  XYQNToken.m
//  community
//
//  Created by 韩啸宇 on 16/6/25.
//  Copyright © 2016年 Backy. All rights reserved.
//

#import "XYQNToken.h"
#import "QN_GTM_Base64.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation XYQNToken
#pragma mark - 生成token
/** 生成七牛UploadToken, 需要自己设置token有效时间 */
+ (NSString *)createTokenWithScope:(NSString *)scope accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey liveTime:(NSInteger)deadline {
    // 1.确定上传策略
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    jsonDict[@"scope"] = scope;
    jsonDict[@"deadline"] = @(deadline);
    
    // 2.将上传策略序列化成为json格式:
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                       options:0
                                                         error:nil];
    
    // 3.对json序列化后的上传策略进行URL安全的Base64编码,得到如下encoded:
    NSString* encoded = [self URLSafeBase64Encode:jsonData];
    
    // 4.用SecretKey对编码后的上传策略进行HMAC-SHA1加密，并且做URL安全的Base64编码,得到如下的encoded_signed:
    NSString *encoded_signed = [self HMACSHA1:secretKey text:encoded];
    
    // 5.将 AccessKey、encode_signed 和 encoded 用 “:” 连接起来,得到如下的UploadToken:
    NSString *uploadToken=[NSString stringWithFormat:@"%@:%@:%@",accessKey,encoded_signed,encoded];
    
    return uploadToken;
}

/** 生成七牛UploadToken, token有效时间默认1小时 */
+ (NSString *)createTokenWithScope:(NSString *)scope accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey {
    NSInteger deadline = [[NSDate date] timeIntervalSince1970] + 3600;
    return [self createTokenWithScope:scope accessKey:accessKey secretKey:secretKey liveTime:deadline];
}

#pragma mark - 编码及加密
// URL安全的Base64编码
+ (NSString *)URLSafeBase64Encode:(NSData *)text {
    
    NSString *base64 = [[NSString alloc] initWithData:[QN_GTM_Base64 encodeData:text] encoding:NSUTF8StringEncoding];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return base64;
}

// HMAC-SHA1加密，并且做URL安全的Base64编码
+  (NSString *)HMACSHA1:(NSString *)key text:(NSString *)text {
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [self URLSafeBase64Encode:HMAC];
    return hash;
}


@end
