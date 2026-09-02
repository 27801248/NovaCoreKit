//
//  NovaCoreKitCrypto.h
//  NovaCoreKit
//
//  加解密工具：AES-256、RSA、HMAC、MD5/SHA 哈希、Base64
//  纯本地实现，基于 Security / CommonCrypto 框架
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Crypto)
@interface NovaCoreKitCrypto : NSObject

#pragma mark - AES-256 加解密

/// AES-256 CBC 加密
/// @param data 明文数据
/// @param key 密钥（16/24/32 字节，对应 AES-128/192/256）
/// @param iv 初始化向量（16 字节，传 nil 则用全零 IV）
+ (nullable NSData *)AES256EncryptData:(NSData *)data key:(NSData *)key iv:(nullable NSData *)iv;

/// AES-256 CBC 解密
+ (nullable NSData *)AES256DecryptData:(NSData *)data key:(NSData *)key iv:(nullable NSData *)iv;

/// 字符串快捷加密（UTF-8 编码，返回 Base64 字符串）
+ (nullable NSString *)AES256EncryptString:(NSString *)string key:(NSString *)key;

/// 字符串快捷解密（输入 Base64，返回 UTF-8 字符串）
+ (nullable NSString *)AES256DecryptString:(NSString *)base64String key:(NSString *)key;

#pragma mark - RSA 加解密 / 签名

/// 从 PEM 字符串解析公钥（返回 DER 数据）
+ (nullable NSData *)publicKeyDataFromString:(NSString *)pemString;

/// RSA 加密（公钥，PKCS1）
+ (nullable NSData *)encryptData:(NSData *)data withPublicKeyData:(NSData *)publicKeyData;

/// RSA 解密（私钥，PKCS1）
+ (nullable NSData *)decryptData:(NSData *)data withPrivateKeyData:(NSData *)privateKeyData;

/// RSA 签名（私钥，SHA256+PKCS1v15）
+ (nullable NSData *)signData:(NSData *)data withPrivateKeyData:(NSData *)privateKeyData;

/// RSA 验签（公钥，SHA256+PKCS1v15）
+ (BOOL)verifySignature:(NSData *)signature forData:(NSData *)data withPublicKeyData:(NSData *)publicKeyData;

#pragma mark - HMAC 签名

/// HMAC-MD5
+ (NSString *)HMAC_MD5:(NSString *)string key:(NSString *)key;

/// HMAC-SHA1
+ (NSString *)HMAC_SHA1:(NSString *)string key:(NSString *)key;

/// HMAC-SHA256
+ (NSString *)HMAC_SHA256:(NSString *)string key:(NSString *)key;

/// HMAC-SHA512
+ (NSString *)HMAC_SHA512:(NSString *)string key:(NSString *)key;

#pragma mark - 哈希

/// MD5（32位小写）
+ (NSString *)MD5:(NSString *)string;

/// MD5（NSData 输入）
+ (NSData *)MD5Data:(NSData *)data;

/// SHA1（40位小写）
+ (NSString *)SHA1:(NSString *)string;

/// SHA256（64位小写）
+ (NSString *)SHA256:(NSString *)string;

/// SHA512（128位小写）
+ (NSString *)SHA512:(NSString *)string;

#pragma mark - Base64

/// Base64 编码
+ (NSString *)base64Encode:(NSData *)data;

/// Base64 解码
+ (nullable NSData *)base64Decode:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
