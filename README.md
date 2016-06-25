# QiNiuUploadToken
生成七牛的token, 方便小伙伴们使用

大体步骤参考[七牛上传凭证在线生成](http://jsfiddle.net/gh/get/extjs/4.2/icattlecoder/jsfiddle/tree/master/uptoken)
1. 确定上传策略
2. 将上传策略序列化成为json格式:
3. 对json序列化后的上传策略进行URL安全的Base64编码,得到如下encoded:
4. 用SecretKey对编码后的上传策略进行HMAC-SHA1加密，并且做URL安全的Base64编码,得到如下的encoded_signed:
5. 将 AccessKey、encode_signed 和 encoded 用 “:” 连接起来,得到如下的UploadToken:

>坑: 在线凭证生成会抽风, 有时候给出的结果是用AccessKey作为Key来HMAC-SHA1加密的结果, 所以如果你在与在线生成的步骤对照的时候发现错误不要方, 先运行看看会不会bad token`Error Domain=qiniu.com Code=401 "(null)" UserInfo={error=bad token}>`

# 功能代码
---
```objc
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
```
# 编码及加密代码
---
## URL安全的Base64编码
```objc
#import "QN_GTM_Base64.h" // 需先导入该文件, 七牛SDK已包含

+ (NSString *)URLSafeBase64Encode:(NSData *)text {
    
    NSString *base64 = [[NSString alloc] initWithData:[QN_GTM_Base64 encodeData:text] encoding:NSUTF8StringEncoding];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return base64;
}
```

## HMAC-SHA1加密，并且做URL安全的Base64编码

```objc
#import <CommonCrypto/CommonHMAC.h> // 需先导入该文件

+  (NSString *)HMACSHA1:(NSString *)key text:(NSString *)text {
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [self URLSafeBase64Encode:HMAC];
    return hash;
}
```