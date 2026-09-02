//
//  NovaCoreKitDevice.h
//  NovaCoreKit
//  设备信息：IDFV、型号、系统版本、屏幕、内存、磁盘等（纯本地，无网络）
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(DeviceInfo)
@interface NovaCoreKitDevice : NSObject

/// 单例
@property (class, nonatomic, readonly, strong) NovaCoreKitDevice *shared;

/// 设备 IDFV（Keychain 持久化，卸载重装后仍稳定）
@property (nonatomic, readonly, copy) NSString *idfv;

/// 系统版本，如 "16.0"
@property (nonatomic, readonly, copy) NSString *systemVersion;

/// 设备型号标识，如 "iPhone15,2"
@property (nonatomic, readonly, copy) NSString *deviceModel;

/// 设备型号名称，如 "iPhone 15 Pro"
@property (nonatomic, readonly, copy) NSString *deviceModelName;

/// 设备名称（用户设置的名称）
@property (nonatomic, readonly, copy) NSString *deviceName;

/// 系统名称，如 "iOS"
@property (nonatomic, readonly, copy) NSString *systemName;

/// 应用版本号
@property (nonatomic, readonly, copy) NSString *appVersion;

/// 应用构建号
@property (nonatomic, readonly, copy) NSString *appBuild;

/// Bundle ID
@property (nonatomic, readonly, copy) NSString *bundleIdentifier;

/// 屏幕尺寸（点）
@property (nonatomic, readonly) CGSize screenSize;

/// 屏幕缩放因子
@property (nonatomic, readonly) CGFloat screenScale;

/// 是否全面屏（有安全区域）
@property (nonatomic, readonly) BOOL isFullScreen;

/// 总内存（字节）
@property (nonatomic, readonly) unsigned long long totalMemory;

/// 已用内存（字节）
@property (nonatomic, readonly) unsigned long long usedMemory;

/// 总磁盘空间（字节）
@property (nonatomic, readonly) unsigned long long totalDiskSpace;

/// 可用磁盘空间（字节）
@property (nonatomic, readonly) unsigned long long freeDiskSpace;

/// 是否越狱
@property (nonatomic, readonly) BOOL isJailbroken;

/// 设备语言，如 "zh-Hans"
@property (nonatomic, readonly, copy) NSString *language;

/// 设备地区，如 "CN"
@property (nonatomic, readonly, copy) NSString *country;

/// 时区名称，如 "Asia/Shanghai"
@property (nonatomic, readonly, copy) NSString *timezone;

/// 设备唯一标识（基于 IDFV 的 MD5，32位）
@property (nonatomic, readonly, copy) NSString *deviceUUID;

@end

NS_ASSUME_NONNULL_END
