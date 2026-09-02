//
//  NovaCoreKit.h
//  NovaCoreKit
//
//  统一入口头文件：纯本地工具库，无网络、无登录授权
//  模块：加密 / 设备信息 / Keychain / UI
//
#import <Foundation/Foundation.h>

//! Project version number for NovaCoreKit.
FOUNDATION_EXPORT double NovaCoreKitVersionNumber;

//! Project version string for NovaCoreKit.
FOUNDATION_EXPORT const unsigned char NovaCoreKitVersionString[];

// 核心模块（纯本地，无网络）
#import <NovaCoreKit/NovaCoreKitCrypto.h>
#import <NovaCoreKit/NovaCoreKitDevice.h>
#import <NovaCoreKit/NovaCoreKitKeychain.h>
#import <NovaCoreKit/NovaCoreKitUI.h>
