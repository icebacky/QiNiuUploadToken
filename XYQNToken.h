//
//  XYQNToken.h
//  community
//
//  Created by 韩啸宇 on 16/6/25.
//  Copyright © 2016年 Backy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYQNToken : NSObject

/**
 *  生成七牛UploadToken, 需要自己设置token有效时间
 *
 *  @param scope     Scope
 *  @param accessKey AccessKey
 *  @param secretKey SecretKey
 *  @param deadline  token有效时间, UNIX时间戳
 *
 *  @return 生成的UploadToken
 */
+ (NSString *)createTokenWithScope:(NSString *)scope accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey liveTime:(NSInteger)deadline;

/**
 *  生成七牛UploadToken, token有效时间默认1小时
 *
 *  @param scope     Scope
 *  @param accessKey AccessKey
 *  @param secretKey SecretKey
 *
 *  @return 生成的UploadToken
 */
+ (NSString *)createTokenWithScope:(NSString *)scope accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey;
@end
