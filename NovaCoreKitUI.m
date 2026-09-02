//
//  NovaCoreKitUI.m
//  NovaCoreKit
//  UI 组件实现：Toast、加载指示器、Alert 弹窗
//
#import "NovaCoreKitUI.h"

static const NSTimeInterval kToastDefaultDuration = 2.0;
static const CGFloat kToastCornerRadius = 10.0;
static const CGFloat kToastVerticalMargin = 80.0;
static const NSInteger kToastTag = 20260901;
static const NSInteger kActivityTag = 20260902;

#pragma mark - Toast

@implementation NovaCoreKitToast

+ (void)showToast:(NSString *)message {
    UIWindow *window = [self keyWindow];
    if (!window) return;
    [self showToast:message onView:window duration:kToastDefaultDuration position:NovaCoreKitToastPositionBottom];
}

+ (void)showToast:(NSString *)message
           onView:(UIView *)view
         duration:(NSTimeInterval)duration
         position:(NovaCoreKitToastPosition)position {
    if (!view || message.length == 0) return;

    // 移除旧 Toast
    [self hideToast:view];

    UILabel *label = [[UILabel alloc] init];
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    label.layer.cornerRadius = kToastCornerRadius;
    label.layer.masksToBounds = YES;
    label.tag = kToastTag;

    CGSize maxSize = CGSizeMake(view.bounds.size.width - 80, CGFLOAT_MAX);
    CGSize textSize = [message boundingRectWithSize:maxSize
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: label.font}
                                            context:nil].size;
    label.frame = CGRectMake(0, 0, textSize.width + 32, textSize.height + 16);

    CGFloat centerX = view.bounds.size.width / 2.0;
    CGFloat centerY;
    switch (position) {
        case NovaCoreKitToastPositionTop:
            centerY = kToastVerticalMargin + label.bounds.size.height / 2.0;
            break;
        case NovaCoreKitToastPositionBottom:
            centerY = view.bounds.size.height - kToastVerticalMargin - label.bounds.size.height / 2.0;
            break;
        case NovaCoreKitToastPositionCenter:
        default:
            centerY = view.bounds.size.height / 2.0;
            break;
    }
    label.center = CGPointMake(centerX, centerY);
    label.alpha = 0;
    [view addSubview:label];

    [UIView animateWithDuration:0.25 animations:^{
        label.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25
                              delay:duration
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
}

+ (void)hideToast:(UIView *)view {
    if (!view) return;
    for (UIView *subview in view.subviews) {
        if (subview.tag == kToastTag) {
            [subview removeFromSuperview];
        }
    }
}

+ (UIWindow *)keyWindow {
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) return window;
                }
            }
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}

@end

#pragma mark - 加载指示器

@implementation NovaCoreKitActivity

+ (void)showWithText:(NSString *)text {
    UIWindow *window = [self keyWindow];
    if (!window) return;
    [self showOnView:window text:text];
}

+ (void)showOnView:(UIView *)view text:(NSString *)text {
    if (!view) return;
    [self hideOnView:view];

    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    container.layer.cornerRadius = 12.0;
    container.tag = kActivityTag;
    container.translatesAutoresizingMaskIntoConstraints = NO;

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:indicator];
    [indicator startAnimating];

    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:label];

    [view addSubview:container];

    // 约束
    [NSLayoutConstraint activateConstraints:@[
        [container.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [container.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
        [container.widthAnchor constraintGreaterThanOrEqualToConstant:120],
        [container.heightAnchor constraintGreaterThanOrEqualToConstant:100],
        [indicator.topAnchor constraintEqualToAnchor:container.topAnchor constant:20],
        [indicator.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [label.topAnchor constraintEqualToAnchor:indicator.bottomAnchor constant:12],
        [label.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:16],
        [label.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-16],
        [label.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-16],
    ]];
}

+ (void)hide {
    UIWindow *window = [self keyWindow];
    if (window) [self hideOnView:window];
}

+ (void)hideOnView:(UIView *)view {
    if (!view) return;
    for (UIView *subview in view.subviews) {
        if (subview.tag == kActivityTag) {
            [UIView animateWithDuration:0.2 animations:^{
                subview.alpha = 0;
            } completion:^(BOOL finished) {
                [subview removeFromSuperview];
            }];
        }
    }
}

+ (UIWindow *)keyWindow {
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) return window;
                }
            }
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}

@end

#pragma mark - Alert

@implementation NovaCoreKitAlert

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                 okHandler:(void (^)(void))okHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        if (okHandler) okHandler();
    }];
    [alert addAction:ok];
    [self presentAlert:alert];
}

+ (void)showConfirmWithTitle:(NSString *)title
                     message:(NSString *)message
                   okHandler:(void (^)(void))okHandler
               cancelHandler:(void (^)(void))cancelHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
        if (cancelHandler) cancelHandler();
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        if (okHandler) okHandler();
    }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentAlert:alert];
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                   actions:(NSArray<UIAlertAction *> *)actions {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction *action in actions) {
        [alert addAction:action];
    }
    [self presentAlert:alert];
}

+ (void)presentAlert:(UIAlertController *)alert {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *root = [self topViewController];
        if (root) {
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}

+ (UIViewController *)topViewController {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in scene.windows) {
                    if (w.isKeyWindow) { window = w; break; }
                }
            }
        }
    }
    if (!window) window = [UIApplication sharedApplication].keyWindow;

    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

@end
