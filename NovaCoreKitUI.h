//
//  NovaCoreKitUI.h
//  NovaCoreKit
//  轻量 UI 组件：Toast、加载指示器、Alert 弹窗、HUD
//  纯本地实现，基于 UIKit
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Toast 位置

typedef NS_ENUM(NSInteger, NovaCoreKitToastPosition) {
    NovaCoreKitToastPositionTop,
    NovaCoreKitToastPositionCenter,
    NovaCoreKitToastPositionBottom,
};

#pragma mark - Toast 管理器

NS_SWIFT_NAME(ToastManager)
@interface NovaCoreKitToast : NSObject

/// 展示一条 Toast（在 keyWindow 上）
+ (void)showToast:(NSString *)message;

/// 展示一条 Toast（指定视图、时长、位置）
+ (void)showToast:(NSString *)message
           onView:(UIView *)view
         duration:(NSTimeInterval)duration
         position:(NovaCoreKitToastPosition)position;

/// 隐藏当前 Toast
+ (void)hideToast:(UIView *)view;

@end

#pragma mark - 加载指示器

NS_SWIFT_NAME(ActivityIndicator)
@interface NovaCoreKitActivity : NSObject

/// 在 keyWindow 上展示加载指示器（带文字）
+ (void)showWithText:(nullable NSString *)text;

/// 在指定视图上展示加载指示器
+ (void)showOnView:(UIView *)view text:(nullable NSString *)text;

/// 隐藏加载指示器
+ (void)hide;

/// 隐藏指定视图上的加载指示器
+ (void)hideOnView:(UIView *)view;

@end

#pragma mark - Alert 弹窗

NS_SWIFT_NAME(AlertManager)
@interface NovaCoreKitAlert : NSObject

/// 简单提示弹窗（确定按钮）
+ (void)showAlertWithTitle:(nullable NSString *)title
                   message:(nullable NSString *)message
                 okHandler:(nullable void (^)(void))okHandler;

/// 确认弹窗（确定/取消）
+ (void)showConfirmWithTitle:(nullable NSString *)title
                     message:(nullable NSString *)message
                   okHandler:(nullable void (^)(void))okHandler
               cancelHandler:(nullable void (^)(void))cancelHandler;

/// 多按钮弹窗
+ (void)showAlertWithTitle:(nullable NSString *)title
                   message:(nullable NSString *)message
                 actions:(NSArray<UIAlertAction *> *)actions;

@end

NS_ASSUME_NONNULL_END
