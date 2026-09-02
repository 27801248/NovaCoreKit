//
//  NovaCoreKitKeychain.m
//  NovaCoreKit
//  Keychain 存取实现：基于 Security 框架 SecItem 封装
//
#import "NovaCoreKitKeychain.h"
#import <Security/Security.h>

static NSString * const kNovaCoreKitDefaultService = @"com.novacorekit.sdk";

@interface NovaCoreKitKeychain ()
@end

@implementation NovaCoreKitKeychain

+ (instancetype)shared {
    static NovaCoreKitKeychain *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
        _shared.serviceName = kNovaCoreKitDefaultService;
    });
    return _shared;
}

- (NSMutableDictionary *)baseQueryForKey:(NSString *)key {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrService] = self.serviceName ?: kNovaCoreKitDefaultService;
    if (key) {
        query[(__bridge id)kSecAttrAccount] = key;
    }
    return query;
}

#pragma mark - 字符串

- (BOOL)setString:(NSString *)value forKey:(NSString *)key {
    if (!key || !value) return NO;
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [self setData:data forKey:key];
}

- (NSString *)stringForKey:(NSString *)key {
    NSData *data = [self dataForKey:key];
    if (!data) return nil;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - 数据

- (BOOL)setData:(NSData *)data forKey:(NSString *)key {
    if (!key || !data) return NO;
    NSMutableDictionary *query = [self baseQueryForKey:key];
    // 先删旧值
    SecItemDelete((__bridge CFDictionaryRef)query);
    // 写入新值
    NSMutableDictionary *attributes = [query mutableCopy];
    attributes[(__bridge id)kSecValueData] = data;
    attributes[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
    return status == errSecSuccess;
}

- (NSData *)dataForKey:(NSString *)key {
    if (!key) return nil;
    NSMutableDictionary *query = [self baseQueryForKey:key];
    query[(__bridge id)kSecReturnData] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess || result == NULL) return nil;
    return (__bridge_transfer NSData *)result;
}

#pragma mark - 布尔值

- (BOOL)setBool:(BOOL)value forKey:(NSString *)key {
    return [self setString:value ? @"1" : @"0" forKey:key];
}

- (BOOL)boolForKey:(NSString *)key {
    NSString *value = [self stringForKey:key];
    return [value isEqualToString:@"1"];
}

#pragma mark - 归档对象

- (BOOL)setObject:(id<NSCoding>)object forKey:(NSString *)key {
    if (!key || !object) return NO;
    @try {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:NO error:nil];
        return [self setData:data forKey:key];
    } @catch (NSException *e) {
        return NO;
    }
}

- (id)objectForKey:(NSString *)key {
    NSData *data = [self dataForKey:key];
    if (!data) return nil;
    @try {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *e) {
        return nil;
    }
}

#pragma mark - 删除 / 查询

- (BOOL)removeValueForKey:(NSString *)key {
    if (!key) return NO;
    NSMutableDictionary *query = [self baseQueryForKey:key];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    return status == errSecSuccess || status == errSecItemNotFound;
}

- (BOOL)removeAll {
    NSMutableDictionary *query = [self baseQueryForKey:nil];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    return status == errSecSuccess || status == errSecItemNotFound;
}

- (BOOL)hasValueForKey:(NSString *)key {
    if (!key) return NO;
    NSMutableDictionary *query = [self baseQueryForKey:key];
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    return status == errSecSuccess;
}

- (NSArray<NSString *> *)allKeys {
    NSMutableDictionary *query = [self baseQueryForKey:nil];
    query[(__bridge id)kSecReturnAttributes] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess || result == NULL) return @[];
    NSArray *items = (__bridge_transfer NSArray *)result;
    NSMutableArray *keys = [NSMutableArray array];
    for (NSDictionary *item in items) {
        NSString *key = item[(__bridge id)kSecAttrAccount];
        if (key) [keys addObject:key];
    }
    return keys;
}

@end
