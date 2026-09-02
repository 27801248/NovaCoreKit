//
//  NovaCoreKitDevice.m
//  NovaCoreKit
//  设备信息实现：纯本地读取，无网络请求
//
#import "NovaCoreKitDevice.h"
#import "NovaCoreKitKeychain.h"
#import "NovaCoreKitCrypto.h"
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <UIKit/UIKit.h>

static NSString * const kNovaCoreKitIDFVKeychainKey = @"com.novacorekit.device.idfv";

@implementation NovaCoreKitDevice

+ (instancetype)shared {
    static NovaCoreKitDevice *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    return _shared;
}

- (NSString *)idfv {
    NSString *persisted = [[NovaCoreKitKeychain shared] stringForKey:kNovaCoreKitIDFVKeychainKey];
    if (persisted.length > 0) return persisted;

    NSString *systemIDFV = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (systemIDFV.length > 0) {
        [[NovaCoreKitKeychain shared] setString:systemIDFV forKey:kNovaCoreKitIDFVKeychainKey];
        return systemIDFV;
    }
    NSString *fallback = [[NSUUID UUID] UUIDString];
    [[NovaCoreKitKeychain shared] setString:fallback forKey:kNovaCoreKitIDFVKeychainKey];
    return fallback;
}

- (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString *)deviceModelName {
    NSString *model = [self deviceModel];
    // 常见型号映射表
    NSDictionary *map = @{
        @"iPhone1,1": @"iPhone",
        @"iPhone1,2": @"iPhone 3G",
        @"iPhone2,1": @"iPhone 3GS",
        @"iPhone3,1": @"iPhone 4",
        @"iPhone4,1": @"iPhone 4S",
        @"iPhone5,1": @"iPhone 5",
        @"iPhone5,2": @"iPhone 5",
        @"iPhone5,3": @"iPhone 5c",
        @"iPhone5,4": @"iPhone 5c",
        @"iPhone6,1": @"iPhone 5s",
        @"iPhone6,2": @"iPhone 5s",
        @"iPhone7,1": @"iPhone 6 Plus",
        @"iPhone7,2": @"iPhone 6",
        @"iPhone8,1": @"iPhone 6s",
        @"iPhone8,2": @"iPhone 6s Plus",
        @"iPhone8,4": @"iPhone SE",
        @"iPhone9,1": @"iPhone 7",
        @"iPhone9,2": @"iPhone 7 Plus",
        @"iPhone9,3": @"iPhone 7",
        @"iPhone9,4": @"iPhone 7 Plus",
        @"iPhone10,1": @"iPhone 8",
        @"iPhone10,2": @"iPhone 8 Plus",
        @"iPhone10,3": @"iPhone X",
        @"iPhone10,4": @"iPhone 8",
        @"iPhone10,5": @"iPhone 8 Plus",
        @"iPhone10,6": @"iPhone X",
        @"iPhone11,2": @"iPhone XS",
        @"iPhone11,4": @"iPhone XS Max",
        @"iPhone11,6": @"iPhone XS Max",
        @"iPhone11,8": @"iPhone XR",
        @"iPhone12,1": @"iPhone 11",
        @"iPhone12,3": @"iPhone 11 Pro",
        @"iPhone12,5": @"iPhone 11 Pro Max",
        @"iPhone12,8": @"iPhone SE (2nd)",
        @"iPhone13,1": @"iPhone 12 mini",
        @"iPhone13,2": @"iPhone 12",
        @"iPhone13,3": @"iPhone 12 Pro",
        @"iPhone13,4": @"iPhone 12 Pro Max",
        @"iPhone14,2": @"iPhone 13 Pro",
        @"iPhone14,3": @"iPhone 13 Pro Max",
        @"iPhone14,4": @"iPhone 13 mini",
        @"iPhone14,5": @"iPhone 13",
        @"iPhone14,6": @"iPhone SE (3rd)",
        @"iPhone14,7": @"iPhone 14",
        @"iPhone14,8": @"iPhone 14 Plus",
        @"iPhone15,2": @"iPhone 14 Pro",
        @"iPhone15,3": @"iPhone 14 Pro Max",
        @"iPhone15,4": @"iPhone 15",
        @"iPhone15,5": @"iPhone 15 Plus",
        @"iPhone16,1": @"iPhone 15 Pro",
        @"iPhone16,2": @"iPhone 15 Pro Max",
        @"iPad1,1": @"iPad",
        @"iPad2,1": @"iPad 2",
        @"iPad3,1": @"iPad (3rd)",
        @"iPad3,4": @"iPad (4th)",
        @"iPad4,1": @"iPad Air",
        @"iPad4,2": @"iPad Air",
        @"iPad5,3": @"iPad Air 2",
        @"iPad6,3": @"iPad Pro (9.7)",
        @"iPad6,7": @"iPad Pro (12.9)",
        @"iPad7,1": @"iPad Pro (12.9, 2nd)",
        @"iPad7,3": @"iPad Pro (10.5)",
        @"iPad7,5": @"iPad (6th)",
        @"iPad7,11": @"iPad (7th)",
        @"iPad8,1": @"iPad Pro (11)",
        @"iPad8,5": @"iPad Pro (12.9, 3rd)",
        @"iPad11,1": @"iPad mini (5th)",
        @"iPad11,3": @"iPad Air (3rd)",
        @"iPad11,6": @"iPad (8th)",
        @"iPad12,1": @"iPad (9th)",
        @"iPad13,1": @"iPad Air (4th)",
        @"iPad13,4": @"iPad Pro (11, 3rd)",
        @"iPad13,8": @"iPad Pro (12.9, 5th)",
        @"iPad14,1": @"iPad mini (6th)",
        @"iPad14,3": @"iPad Air (5th)",
    };
    NSString *name = map[model];
    return name ?: model;
}

- (NSString *)deviceName {
    return [[UIDevice currentDevice] name];
}

- (NSString *)systemName {
    return [[UIDevice currentDevice] systemName];
}

- (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
}

- (NSString *)appBuild {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @"";
}

- (NSString *)bundleIdentifier {
    return [[NSBundle mainBundle] bundleIdentifier] ?: @"";
}

- (CGSize)screenSize {
    return [UIScreen mainScreen].bounds.size;
}

- (CGFloat)screenScale {
    return [UIScreen mainScreen].scale;
}

- (BOOL)isFullScreen {
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        return window.safeAreaInsets.bottom > 0;
    }
    return NO;
}

- (unsigned long long)totalMemory {
    return [[NSProcessInfo processInfo] physicalMemory];
}

- (unsigned long long)usedMemory {
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kr == KERN_SUCCESS) {
        return info.resident_size;
    }
    return 0;
}

- (unsigned long long)totalDiskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (!error) {
        return [attrs[NSFileSystemSize] unsignedLongLongValue];
    }
    return 0;
}

- (unsigned long long)freeDiskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (!error) {
        return [attrs[NSFileSystemFreeSize] unsignedLongLongValue];
    }
    return 0;
}

- (BOOL)isJailbroken {
    NSArray *jailbreakFiles = @[
        @"/Applications/Cydia.app",
        @"/Applications/Sileo.app",
        @"/Applications/Zebra.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/bin/bash",
        @"/usr/sbin/sshd",
        @"/etc/apt",
        @"/private/var/lib/apt",
    ];
    for (NSString *path in jailbreakFiles) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return YES;
        }
    }
    // 尝试写入系统目录
    @try {
        NSError *error = nil;
        [@"test" writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
            [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
            return YES;
        }
    } @catch (NSException *exception) {}
    return NO;
}

- (NSString *)language {
    return [[NSLocale preferredLanguages] firstObject] ?: @"";
}

- (NSString *)country {
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] ?: @"";
}

- (NSString *)timezone {
    return [[NSTimeZone localTimeZone] name];
}

- (NSString *)deviceUUID {
    return [NovaCoreKitCrypto MD5:[self idfv]];
}

@end
