//
//  NovaCoreKitKeychain.h
//  NovaCoreKit
//  Keychain 存取工具：安全存储字符串、数据、布尔值等
//  基于 Security 框架的 SecItem 封装
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(KeychainStore)
@interface NovaCoreKitKeychain : NSObject

/// 单例
@property (class, nonatomic, readonly, strong) NovaCoreKitKeychain *shared;

/// 自定义服务名（默认 com.novacorekit.sdk，设置后影响所有后续操作）
@property (nonatomic, copy) NSString *serviceName;

#pragma mark - 字符串存取

/// 写入字符串
- (BOOL)setString:(NSString *)value forKey:(NSString *)key;

/// 读取字符串
- (nullable NSString *)stringForKey:(NSString *)key;

#pragma mark - 数据存取

/// 写入 NSData
- (BOOL)setData:(NSData *)data forKey:(NSString *)key;

/// 读取 NSData
- (nullable NSData *)dataForKey:(NSString *)key;

#pragma mark - 布尔值

/// 写入 BOOL
- (BOOL)setBool:(BOOL)value forKey:(NSString *)key;

/// 读取 BOOL
- (BOOL)boolForKey:(NSString *)key;

#pragma mark - 通用对象（归档）

/// 写入归档对象（需遵守 NSCoding）
- (BOOL)setObject:(id<NSCoding>)object forKey:(NSString *)key;

/// 读取归档对象
- (nullable id)objectForKey:(NSString *)key;

#pragma mark - 删除 / 查询

/// 删除某个 key
- (BOOL)removeValueForKey:(NSString *)key;

/// 删除全部
- (BOOL)removeAll;

/// 是否存在某个 key
- (BOOL)hasValueForKey:(NSString *)key;

/// 获取所有 key
- (NSArray<NSString *> *)allKeys;

@end

NS_ASSUME_NONNULL_END
