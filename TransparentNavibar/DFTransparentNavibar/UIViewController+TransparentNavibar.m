//
//  UIViewController+TransparentNavibar.m

//
//  Created by wanghaojiao on 2017/6/23.
//

#import "UIViewController+TransparentNavibar.h"
#import "UINavigationController+TransparentNavibar.h"
#import "DFTransparentNavibarConfigure.h"
#import <objc/runtime.h>

@implementation UIViewController (TransparentNavibar)

#pragma mark - fake viewDidLoad
+ (void)load {
    [super load];
    
    if ([self class] == [UIViewController class]) {
        Method original = class_getInstanceMethod([self class], @selector(viewDidLoad));
        Method replaced = class_getInstanceMethod([self class], @selector(__tnw_viewDidLoad));
        method_exchangeImplementations(original, replaced);
        
        original = class_getInstanceMethod([self class], @selector(setTitle:));
        replaced = class_getInstanceMethod([self class], @selector(__tnw_setTitle:));
        method_exchangeImplementations(original, replaced);
        
        original = class_getInstanceMethod([self class], @selector(viewDidAppear:));
        replaced = class_getInstanceMethod([self class], @selector(__tnw_viewDidAppear:));
        method_exchangeImplementations(original, replaced);
        
        /*
        original = class_getInstanceMethod([self class], @selector(viewWillAppear:));
        replaced = class_getInstanceMethod([self class], @selector(__tnw_viewWillAppear:));
        method_exchangeImplementations(original, replaced);//*/
    }
}

- (void)__tnw_setTitle:(NSString *)title {
    [self __tnw_setTitle:title];
    
    if ([self tnw_customizeNavibarTitleFont]||[self tnw_customizeNavibarTintColor]) {
        UILabel* titleView = (UILabel*)self.navigationItem.titleView;
        if (!titleView) {
            titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            self.navigationItem.titleView = titleView;
            titleView.textAlignment = NSTextAlignmentCenter;
        } else if (![titleView isKindOfClass:[UILabel class]]) {
            return;
        }
        
        UIFont* font = [self tnw_customizeNavibarTitleFont];
        UIColor* color = [self tnw_customizeNavibarTintColor];
        
        titleView.textColor = color?color:self.navigationController.navigationBar.tintColor;
        titleView.font = font?font:[UIFont boldSystemFontOfSize:17];
        
        titleView.text = title;
        [titleView sizeToFit];
    }
}

- (void)__tnw_viewDidLoad {
    [self __tnw_viewDidLoad];
  
    if ([self isKindOfClass:[UINavigationController class]]) {
        if (!objc_getAssociatedObject(self, "TWN_INIT_FINISHED")) {
            objc_setAssociatedObject(self, "TWN_INIT_FINISHED", @"1", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            if ([DFTransparentNavibarConfigure config].normalNaviBgImage||[DFTransparentNavibarConfigure config].normalNaviBgColor) {
                
//                ((UINavigationController*)self).navigationBar.translucent = NO;
                
                [((UINavigationController*)self).navigationBar setShadowImage:[UIImage new]];
                if ([DFTransparentNavibarConfigure config].normalNaviBgImage) {
                    [((UINavigationController*)self).navigationBar setBackgroundImage:[DFTransparentNavibarConfigure config].normalNaviBgImage forBarMetrics:UIBarMetricsDefault];
                } else {
                    CGRect rect = CGRectMake(0.0f, 0.0f, 64, 64);
                    UIGraphicsBeginImageContext(rect.size);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetFillColorWithColor(context, [[DFTransparentNavibarConfigure config].normalNaviBgColor CGColor]);
                    CGContextFillRect(context, rect);
                    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    [((UINavigationController*)self).navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
                }
            }
        }
        
    }
    
    BOOL hasCustomize = ([self tnw_customizeNavibarBGColor]||[self tnw_customizeNavibarBGImage]);
    if (hasCustomize) {
        UIImageView* view = [[UIImageView alloc] init];
        view.image = [self tnw_customizeNavibarBGImage];
        view.backgroundColor = [self tnw_customizeNavibarBGColor];
        view.alpha = 0;
        self.navigationController.customizedFakeNaviBar = view;
    }
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.navigationController.customizedFakeNaviBar.alpha = hasCustomize?1:0;
    } completion:^(BOOL finished) {
        if (!hasCustomize) {
            [self.navigationController.customizedFakeNaviBar removeFromSuperview];
            self.navigationController.customizedFakeNaviBar = nil;
        }
    }];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

//- (void)__tnw_viewWillAppear:(BOOL)animated {
//    [self __tnw_viewWillAppear:animated];
//
//     if (self.needsFakeNavibar&&!self.fakeNavigationBar) {
////         dispatch_async(dispatch_get_main_queue(), ^{
////             [self createFakeNaviBar];
////         });
//    }
//}

- (void)__tnw_viewDidAppear:(BOOL)animated {
    [self __tnw_viewDidAppear:animated];
    
    [self.navigationController setNavigationBarAlpha:self.twn_preferredNaviAlpha];
    [self.fakeNavigationBar removeFromSuperview];
}

#pragma mark - navi bar alpha
- (void)setTwn_preferredNaviAlpha:(CGFloat)twn_preferredNaviAlpha {
    objc_setAssociatedObject(self, "tnw_navibarAlpha", [NSString stringWithFormat:@"%f",twn_preferredNaviAlpha], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (twn_preferredNaviAlpha<1&&self.fakeNavigationBar) {
        [self.fakeNavigationBar removeFromSuperview];
    }
    
    [self.navigationController setNavigationBarAlpha:twn_preferredNaviAlpha];
}

- (CGFloat)twn_preferredNaviAlpha {
    NSString* alpha = objc_getAssociatedObject(self, "tnw_navibarAlpha");
    
    if (!alpha) {
        return [self twn_defaultPreferredNaviAlpha];
    }
    
    return alpha.doubleValue;
}

- (CGFloat)twn_defaultPreferredNaviAlpha {
    return 1;
}

#pragma mark - customize
- (UIImage*)tnw_customizeNavibarBGImage {
    return nil;
}

- (UIColor*)tnw_customizeNavibarBGColor {
    return nil;
}

- (UIColor*)tnw_customizeNavibarTintColor {
    return nil;
}

- (UIFont*)tnw_customizeNavibarTitleFont {
    return nil;
}

#pragma mark - fake navi bar
- (UIImageView*)fakeNavigationBar {
    UIImageView* imageView = objc_getAssociatedObject(self, "tnw_fakeNavigationBar");
//    if (!imageView) {
//        
//    }
    
    return imageView;
}

- (void)createFakeNaviBar {//OnTop:(BOOL)onTop {
    UIImageView* imageView = self.fakeNavigationBar;
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithImage:[DFTransparentNavibarConfigure config].normalNaviBgImage];
        imageView.backgroundColor = [DFTransparentNavibarConfigure config].normalNaviBgColor;
    }
    
    if ([self tnw_customizeNavibarBGColor]) {
        imageView.backgroundColor = [self tnw_customizeNavibarBGColor];
        imageView.image = nil;
    }
    
    if ([self tnw_customizeNavibarBGImage]) {
        imageView.image = [self tnw_customizeNavibarBGImage];
    }
    
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        imageView.frame = CGRectMake(0, -((UIScrollView*)self.view).contentInset.top, [UIApplication sharedApplication].keyWindow.frame.size.width, NAVI_HEIGHT);
    } else {
        imageView.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, NAVI_HEIGHT);
    }

    [self.view addSubview:imageView];
    
    self.view.clipsToBounds = NO;
    
    objc_setAssociatedObject(self, "tnw_fakeNavigationBar", imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/*
- (void)setUseAlterNavigationBar:(BOOL)useAlterNavigationBar {
    objc_setAssociatedObject(self, "tnw_useLightColorNavigationBar", (useAlterNavigationBar?@"1":@"0"), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)useAlterNavigationBar {
    NSString* useLightColorNavigationBar = objc_getAssociatedObject(self, "tnw_useLightColorNavigationBar");
    return [useLightColorNavigationBar boolValue];
}

- (void)setNeedsFakeNavibar:(BOOL)needsFakeNavibar {
    objc_setAssociatedObject(self, "tnw_needsFakeNavibar", (needsFakeNavibar?@"1":@"0"), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)needsFakeNavibar {
    NSString* needsFakeNavibar = objc_getAssociatedObject(self, "tnw_needsFakeNavibar");
    return [needsFakeNavibar boolValue];
}*/

@end
