//
//  NovaCoreKitCrypto.m
//  NovaCoreKit
//  加解密实现：AES-256 / RSA / HMAC / MD5-SHA / Base64
//  基于 Security 框架 + CommonCrypto
//
#import "NovaCoreKitCrypto.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation NovaCoreKitCrypto

#pragma mark - AES-256 加解密

+ (NSData *)AES256EncryptData:(NSData *)data key:(NSData *)key iv:(NSData *)iv {
    if (!data || !key) return nil;
    // key 长度必须是 16/24/32 字节
    if (key.length != 16 && key.length != 24 && key.length != 32) return nil;

    NSUInteger dataLength = data.length;
    // PKCS7 填充，输出缓冲区 = 输入 + 一个块大小
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    if (!buffer) return nil;

    size_t numBytesEncrypted = 0;
    // iv 为 nil 时用全零 IV
    void *ivBytes = NULL;
    unsigned char zeroIV[kCCBlockSizeAES128] = {0};
    if (iv && iv.length == kCCBlockSizeAES128) {
        ivBytes = (void *)iv.bytes;
    } else {
        ivBytes = zeroIV;
    }

    CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding,
                                     key.bytes, key.length,
                                     ivBytes,
                                     data.bytes, dataLength,
                                     buffer, bufferSize,
                                     &numBytesEncrypted);
    if (status != kCCSuccess) {
        free(buffer);
        return nil;
    }
    return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted freeWhenDone:YES];
}

+ (NSData *)AES256DecryptData:(NSData *)data key:(NSData *)key iv:(NSData *)iv {
    if (!data || !key) return nil;
    if (key.length != 16 && key.length != 24 && key.length != 32) return nil;

    NSUInteger dataLength = data.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    if (!buffer) return nil;

    size_t numBytesDecrypted = 0;
    void *ivBytes = NULL;
    unsigned char zeroIV[kCCBlockSizeAES128] = {0};
    if (iv && iv.length == kCCBlockSizeAES128) {
        ivBytes = (void *)iv.bytes;
    } else {
        ivBytes = zeroIV;
    }

    CCCryptorStatus status = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding,
                                     key.bytes, key.length,
                                     ivBytes,
                                     data.bytes, dataLength,
                                     buffer, bufferSize,
                                     &numBytesDecrypted);
    if (status != kCCSuccess) {
        free(buffer);
        return nil;
    }
    return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted freeWhenDone:YES];
}

+ (NSString *)AES256EncryptString:(NSString *)string key:(NSString *)key {
    if (!string || !key) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    // 密钥不足 32 字节时用 SHA256 派生
    if (keyData.length < 32) {
        keyData = [self SHA256Data:keyData];
    } else if (keyData.length > 32) {
        keyData = [keyData subdataWithRange:NSMakeRange(0, 32)];
    }
    NSData *encrypted = [self AES256EncryptData:data key:keyData iv:nil];
    return [encrypted base64EncodedStringWithOptions:0];
}

+ (NSString *)AES256DecryptString:(NSString *)base64String key:(NSString *)key {
    if (!base64String || !key) return nil;
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    if (!data) return nil;
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    if (keyData.length < 32) {
        keyData = [self SHA256Data:keyData];
    } else if (keyData.length > 32) {
        keyData = [keyData subdataWithRange:NSMakeRange(0, 32)];
    }
    NSData *decrypted = [self AES256DecryptData:data key:keyData iv:nil];
    if (!decrypted) return nil;
    return [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
}

#pragma mark - RSA 加解密 / 签名

+ (NSData *)derDataFromPEM:(NSString *)pemString {
    NSString *clean = [pemString stringByReplacingOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----" withString:@""];
    clean = [clean stringByReplacingOccurrencesOfString:@"-----END PUBLIC KEY-----" withString:@""];
    clean = [clean stringByReplacingOccurrencesOfString:@"-----BEGIN RSA PUBLIC KEY-----" withString:@""];
    clean = [clean stringByReplacingOccurrencesOfString:@"-----END RSA PUBLIC KEY-----" withString:@""];
    clean = [clean stringByReplacingOccurrencesOfString:@"-----BEGIN PRIVATE KEY-----" withString:@""];
    clean = [clean stringByReplacingOccurrencesOfString:@"-----END PRIVATE KEY-----" withString:@""];
    clean = [clean stringByReplacingOccurrencesOfString:@"-----BEGIN RSA PRIVATE KEY-----" withString:@""];
    clean = [clean stringByReplacingOccurrencesOfString:@"-----END RSA PRIVATE KEY-----" withString:@""];
    clean = [clean stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    clean = [clean stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    clean = [clean stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [[NSData alloc] initWithBase64EncodedString:clean options:0];
}

+ (NSData *)publicKeyDataFromString:(NSString *)pemString {
    NSData *derData = [self derDataFromPEM:pemString];
    if (derData.length == 0) return nil;
    NSDictionary *options = @{
        (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
        (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPublic,
    };
    CFErrorRef error = NULL;
    SecKeyRef keyRef = SecKeyCreateWithData((__bridge CFDataRef)derData, (__bridge CFDictionaryRef)options, &error);
    if (keyRef) {
        CFDataRef exported = SecKeyCopyExternalRepresentation(keyRef, &error);
        CFRelease(keyRef);
        if (exported) {
            return (__bridge_transfer NSData *)exported;
        }
    }
    return derData;
}

+ (SecKeyRef)publicKeyRefFromData:(NSData *)keyData {
    NSDictionary *attributes = @{
        (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
        (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPublic,
    };
    CFErrorRef error = NULL;
    return SecKeyCreateWithData((__bridge CFDataRef)keyData, (__bridge CFDictionaryRef)attributes, &error);
}

+ (SecKeyRef)privateKeyRefFromData:(NSData *)keyData {
    NSDictionary *attributes = @{
        (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
        (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate,
    };
    CFErrorRef error = NULL;
    return SecKeyCreateWithData((__bridge CFDataRef)keyData, (__bridge CFDictionaryRef)attributes, &error);
}

+ (NSData *)encryptData:(NSData *)data withPublicKeyData:(NSData *)publicKeyData {
    if (!data || !publicKeyData) return nil;
    SecKeyRef keyRef = [self publicKeyRefFromData:publicKeyData];
    if (!keyRef) return nil;
    size_t blockSize = SecKeyGetBlockSize(keyRef) - 11;
    CFErrorRef error = NULL;
    NSMutableData *result = [NSMutableData data];
    NSUInteger offset = 0;
    while (offset < data.length) {
        size_t chunkLen = MIN(blockSize, data.length - offset);
        NSData *chunk = [data subdataWithRange:NSMakeRange(offset, chunkLen)];
        CFDataRef encrypted = SecKeyCreateEncryptedData(keyRef, kSecKeyAlgorithmRSAEncryptionPKCS1, (__bridge CFDataRef)chunk, &error);
        if (!encrypted) { CFRelease(keyRef); return nil; }
        [result appendData:(__bridge_transfer NSData *)encrypted];
        offset += chunkLen;
    }
    CFRelease(keyRef);
    return result;
}

+ (NSData *)decryptData:(NSData *)data withPrivateKeyData:(NSData *)privateKeyData {
    if (!data || !privateKeyData) return nil;
    SecKeyRef keyRef = [self privateKeyRefFromData:privateKeyData];
    if (!keyRef) return nil;
    size_t blockSize = SecKeyGetBlockSize(keyRef);
    CFErrorRef error = NULL;
    NSMutableData *result = [NSMutableData data];
    NSUInteger offset = 0;
    while (offset < data.length) {
        size_t chunkLen = MIN(blockSize, data.length - offset);
        NSData *chunk = [data subdataWithRange:NSMakeRange(offset, chunkLen)];
        CFDataRef decrypted = SecKeyCreateDecryptedData(keyRef, kSecKeyAlgorithmRSAEncryptionPKCS1, (__bridge CFDataRef)chunk, &error);
        if (!decrypted) { CFRelease(keyRef); return nil; }
        [result appendData:(__bridge_transfer NSData *)decrypted];
        offset += chunkLen;
    }
    CFRelease(keyRef);
    return result;
}

+ (NSData *)signData:(NSData *)data withPrivateKeyData:(NSData *)privateKeyData {
    if (!data || !privateKeyData) return nil;
    SecKeyRef keyRef = [self privateKeyRefFromData:privateKeyData];
    if (!keyRef) return nil;
    CFErrorRef error = NULL;
    CFDataRef signature = SecKeyCreateSignature(keyRef, kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256, (__bridge CFDataRef)data, &error);
    CFRelease(keyRef);
    if (!signature) return nil;
    return (__bridge_transfer NSData *)signature;
}

+ (BOOL)verifySignature:(NSData *)signature forData:(NSData *)data withPublicKeyData:(NSData *)publicKeyData {
    if (!signature || !data || !publicKeyData) return NO;
    SecKeyRef keyRef = [self publicKeyRefFromData:publicKeyData];
    if (!keyRef) return NO;
    CFErrorRef error = NULL;
    BOOL valid = SecKeyVerifySignature(keyRef, kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256, (__bridge CFDataRef)data, (__bridge CFDataRef)signature, &error);
    CFRelease(keyRef);
    return valid;
}

#pragma mark - HMAC

+ (NSString *)HMACWithAlgorithm:(CCHmacAlgorithm)algorithm data:(NSData *)data key:(NSData *)key digestLength:(int)digestLength {
    unsigned char cHMAC[CC_SHA512_DIGEST_LENGTH];
    CCHmac(algorithm, key.bytes, key.length, data.bytes, data.length, cHMAC);
    NSMutableString *result = [NSMutableString stringWithCapacity:digestLength * 2];
    for (int i = 0; i < digestLength; i++) {
        [result appendFormat:@"%02x", cHMAC[i]];
    }
    return result;
}

+ (NSString *)HMAC_MD5:(NSString *)string key:(NSString *)key {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    return [self HMACWithAlgorithm:kCCHmacAlgMD5 data:data key:keyData digestLength:CC_MD5_DIGEST_LENGTH];
}

+ (NSString *)HMAC_SHA1:(NSString *)string key:(NSString *)key {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    return [self HMACWithAlgorithm:kCCHmacAlgSHA1 data:data key:keyData digestLength:CC_SHA1_DIGEST_LENGTH];
}

+ (NSString *)HMAC_SHA256:(NSString *)string key:(NSString *)key {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    return [self HMACWithAlgorithm:kCCHmacAlgSHA256 data:data key:keyData digestLength:CC_SHA256_DIGEST_LENGTH];
}

+ (NSString *)HMAC_SHA512:(NSString *)string key:(NSString *)key {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    return [self HMACWithAlgorithm:kCCHmacAlgSHA512 data:data key:keyData digestLength:CC_SHA512_DIGEST_LENGTH];
}

#pragma mark - 哈希

+ (NSString *)hexStringFromData:(NSData *)data {
    NSMutableString *result = [NSMutableString stringWithCapacity:data.length * 2];
    const unsigned char *bytes = data.bytes;
    for (NSUInteger i = 0; i < data.length; i++) {
        [result appendFormat:@"%02x", bytes[i]];
    }
    return result;
}

+ (NSString *)MD5:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self hexStringFromData:[self MD5Data:data]];
}

+ (NSData *)MD5Data:(NSData *)data {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, digest);
    return [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

+ (NSString *)SHA1:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    return [self hexStringFromData:[NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH]];
}

+ (NSString *)SHA256:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self hexStringFromData:[self SHA256Data:data]];
}

+ (NSData *)SHA256Data:(NSData *)data {
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

+ (NSString *)SHA512:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    return [self hexStringFromData:[NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH]];
}

#pragma mark - Base64

+ (NSString *)base64Encode:(NSData *)data {
    return [data base64EncodedStringWithOptions:0];
}

+ (NSData *)base64Decode:(NSString *)string {
    return [[NSData alloc] initWithBase64EncodedString:string options:0];
}

@end
