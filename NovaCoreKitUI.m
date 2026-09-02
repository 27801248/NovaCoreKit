#import "NovaCoreKitUI.h"

#pragma mark - Toast

@implementation NovaCoreKitToast

+ (void)showToast:(NSString *)message {
    [self showToast:message onView:nil duration:2.0 position:NovaCoreKitToastPositionBottom];
}

+ (void)showToast:(NSString *)message onView:(UIView *)view duration:(NSTimeInterval)duration position:(NovaCoreKitToastPosition)position {
    if (!message || message.length == 0) return;
    
    UIView *targetView = view ?: [self keyWindow];
    if (!targetView) return;
    
    UILabel *toast = [[UILabel alloc] init];
    toast.text = message;
    toast.textColor = [UIColor whiteColor];
    toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    toast.font = [UIFont systemFontOfSize:14];
    toast.textAlignment = NSTextAlignmentCenter;
    toast.numberOfLines = 0;
    toast.layer.cornerRadius = 8;
    toast.clipsToBounds = YES;
    toast.alpha = 0;
    
    CGSize textSize = [message boundingRectWithSize:CGSizeMake(targetView.bounds.size.width - 80, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: toast.font}
                                            context:nil].size;
    
    CGFloat toastWidth = textSize.width + 32;
    CGFloat toastHeight = textSize.height + 16;
    CGFloat x = (targetView.bounds.size.width - toastWidth) / 2;
    CGFloat y;
    
    switch (position) {
        case NovaCoreKitToastPositionTop:
            y = 80;
            break;
        case NovaCoreKitToastPositionCenter:
            y = (targetView.bounds.size.height - toastHeight) / 2;
            break;
        case NovaCoreKitToastPositionBottom:
        default:
            y = targetView.bounds.size.height - toastHeight - 80;
            break;
    }
    
    toast.frame = CGRectMake(x, y, toastWidth, toastHeight);
    [targetView addSubview:toast];
    
    [UIView animateWithDuration:0.3 animations:^{
        toast.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:duration options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toast.alpha = 0;
        } completion:^(BOOL finished) {
            [toast removeFromSuperview];
        }];
    }];
}

+ (UIWindow *)keyWindow {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)]) {
        return app.delegate.window;
    }
    return app.keyWindow;
}

@end

#pragma mark - Activity

@implementation NovaCoreKitActivity

+ (void)showWithText:(NSString *)text {
    UIView *targetView = [NovaCoreKitToast keyWindow];
    if (!targetView) return;
    
    UIView *bg = [[UIView alloc] initWithFrame:targetView.bounds];
    bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    bg.tag = 99991;
    
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 100)];
    box.center = targetView.center;
    box.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    box.layer.cornerRadius = 10;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(60, 40);
    [indicator startAnimating];
    [box addSubview:indicator];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 120, 25)];
    label.text = text ?: @"加载中...";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    [box addSubview:label];
    
    [bg addSubview:box];
    [targetView addSubview:bg];
}

+ (void)hide {
    UIView *targetView = [NovaCoreKitToast keyWindow];
    UIView *bg = [targetView viewWithTag:99991];
    if (bg) {
        [UIView animateWithDuration:0.2 animations:^{
            bg.alpha = 0;
        } completion:^(BOOL finished) {
            [bg removeFromSuperview];
        }];
    }
}

@end

#pragma mark - Alert

@implementation NovaCoreKitAlert

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message okHandler:(void (^)(void))okHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (okHandler) okHandler();
    }]];
    
    UIViewController *rootVC = [NovaCoreKitToast keyWindow].rootViewController;
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    [rootVC presentViewController:alert animated:YES completion:nil];
}

+ (void)showConfirmWithTitle:(NSString *)title message:(NSString *)message okHandler:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelHandler) cancelHandler();
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (okHandler) okHandler();
    }]];
    
    UIViewController *rootVC = [NovaCoreKitToast keyWindow].rootViewController;
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    [rootVC presentViewController:alert animated:YES completion:nil];
}

@end
