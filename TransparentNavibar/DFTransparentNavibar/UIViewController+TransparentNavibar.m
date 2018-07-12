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
        
        original = class_getInstanceMethod([self class], @selector(viewWillAppear:));
        replaced = class_getInstanceMethod([self class], @selector(__tnw_viewWillAppear:));
        method_exchangeImplementations(original, replaced);
        
        original = class_getInstanceMethod([self class], @selector(viewDidAppear:));
        replaced = class_getInstanceMethod([self class], @selector(__tnw_viewDidAppear:));
        method_exchangeImplementations(original, replaced);
        
        original = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
        replaced = class_getInstanceMethod([self class], @selector(__tnw_dealloc));
        method_exchangeImplementations(original, replaced);
    }
}

- (void)__tnw_setTitle:(NSString *)title {
    [self __tnw_setTitle:title];
    [self tnw_setNavigationBarTitle:title];
}

- (void)__tnw_viewDidLoad {
    [self __tnw_viewDidLoad];
    
    [self addObserver:self forKeyPath:@"navigationItem.title" options:NSKeyValueObservingOptionNew context:nil];
    objc_setAssociatedObject(self, "navigationItem.title_observed", @"1", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  
    if ([self isKindOfClass:[UINavigationController class]]) {
        if (!objc_getAssociatedObject(self, "TWN_INIT_FINISHED")) {
            objc_setAssociatedObject(self, "TWN_INIT_FINISHED", @"1", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            if ([DFTransparentNavibarConfigure config].defaultNaviBgImage||[DFTransparentNavibarConfigure config].defaultNaviBgColor) {
                
                [((UINavigationController*)self).navigationBar setShadowImage:[UIImage new]];
                if ([DFTransparentNavibarConfigure config].defaultNaviBgImage) {
                    [((UINavigationController*)self).navigationBar setBackgroundImage:[DFTransparentNavibarConfigure config].defaultNaviBgImage forBarMetrics:UIBarMetricsDefault];
                } else {
                    CGRect rect = CGRectMake(0.0f, 0.0f, 64, 64);
                    UIGraphicsBeginImageContext(rect.size);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetFillColorWithColor(context, [[DFTransparentNavibarConfigure config].defaultNaviBgColor CGColor]);
                    CGContextFillRect(context, rect);
                    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    [((UINavigationController*)self).navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
                }
            }
            
            if (![DFTransparentNavibarConfigure config].defaultNaviTintColor) {
                [DFTransparentNavibarConfigure config].defaultNaviTintColor = ((UINavigationController*)self).navigationBar.tintColor;
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

- (void)__tnw_viewWillAppear:(BOOL)animated {
    [self __tnw_viewWillAppear:animated];
    UIColor* color = [self tnw_customizeNavibarTintColor];
    if (!color) {
        color = [DFTransparentNavibarConfigure config].defaultNaviTintColor;
    }
    [self.navigationController.navigationBar setTintColor:color];
}

- (void)__tnw_viewDidAppear:(BOOL)animated {
    [self __tnw_viewDidAppear:animated];
    
    [self.navigationController setNavigationBarAlpha:self.twn_preferredNaviAlpha];
    [self.fakeNavigationBar removeFromSuperview];
}

#pragma mark - navi bar & title alpha
- (void)setTwn_preferredNaviAlpha:(CGFloat)twn_preferredNaviAlpha {
    
    CGFloat alpha = twn_preferredNaviAlpha;
    if (alpha < 0) {
        alpha = 0;
    }
    
    if (alpha > 1) {
        alpha = 1;
    }
    
    objc_setAssociatedObject(self, "tnw_navibarAlpha", [NSString stringWithFormat:@"%f",alpha], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (alpha<1&&self.fakeNavigationBar) {
        [self.fakeNavigationBar removeFromSuperview];
    }
    
    [self.navigationController setNavigationBarAlpha:alpha];
}

- (CGFloat)twn_preferredNaviAlpha {
    NSString* alpha = objc_getAssociatedObject(self, "tnw_navibarAlpha");
    
    if (!alpha) {
        return [self twn_defaultPreferredNaviAlpha];
    }
    
    CGFloat value = alpha.doubleValue;
    
    if (value < 0) {
        return 0;
    }
    
    if (value > 1) {
        return 1;
    }
    
    return value;
}

- (void)setTwn_preferredNaviTitleAlpha:(CGFloat)twn_preferredNaviTitleAlpha {
    
    CGFloat alpha = twn_preferredNaviTitleAlpha;
    if (alpha < 0) {
        alpha = 0;
    }
    
    if (alpha > 1) {
        alpha = 1;
    }
    
    objc_setAssociatedObject(self, "tnw_navibarTitleAlpha", [NSString stringWithFormat:@"%f",alpha], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (self.navigationItem.titleView.tag == -182732) {
        [self.navigationItem.titleView.subviews lastObject].alpha = alpha;
    }
}

- (CGFloat)twn_preferredNaviTitleAlpha {
    NSString* alpha = objc_getAssociatedObject(self, "tnw_navibarTitleAlpha");
    
    if (!alpha) {
        return [self twn_defaultPreferredNaviTitleAlpha];
    }
    
    CGFloat value = alpha.doubleValue;
    
    if (value < 0) {
        return 0;
    }
    
    if (value > 1) {
        return 1;
    }
    
    return value;
}

- (CGFloat)twn_defaultPreferredNaviAlpha {
    return 1;
}

- (CGFloat)twn_defaultPreferredNaviTitleAlpha {
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
    return objc_getAssociatedObject(self, "tnw_fakeNavigationBar");
}

- (void)createFakeNaviBar {
    UIImageView* imageView = self.fakeNavigationBar;
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithImage:[DFTransparentNavibarConfigure config].defaultNaviBgImage];
        imageView.backgroundColor = [DFTransparentNavibarConfigure config].defaultNaviBgColor;
    }
    
    if ([self tnw_customizeNavibarBGColor]) {
        imageView.backgroundColor = [self tnw_customizeNavibarBGColor];
        imageView.image = nil;
    }
    
    if ([self tnw_customizeNavibarBGImage]) {
        imageView.image = [self tnw_customizeNavibarBGImage];
    }
    
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        imageView.frame = CGRectMake(0, -((UIScrollView*)self.view).contentInset.top, [UIApplication sharedApplication].keyWindow.frame.size.width, DF_TWN_NAVI_HEIGHT);
    } else {
        CGRect rect = [self.view convertRect:self.view.bounds toView:[UIApplication sharedApplication].keyWindow];
        
        if (rect.origin.y > 0) {
            imageView.frame = CGRectMake(0, -DF_TWN_NAVI_HEIGHT, [UIApplication sharedApplication].keyWindow.frame.size.width, DF_TWN_NAVI_HEIGHT);
        } else {
            imageView.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, DF_TWN_NAVI_HEIGHT);
        }
    }

    [self.view addSubview:imageView];
    
    self.view.clipsToBounds = NO;
    
    objc_setAssociatedObject(self, "tnw_fakeNavigationBar", imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - navigationItem.title
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"navigationItem.title"] && object == self) {
        [self tnw_setNavigationBarTitle:[change objectForKey:NSKeyValueChangeNewKey]];
    }
}

- (void)tnw_setNavigationBarTitle:(NSString*)title {
    
    UIView* titleView = self.navigationItem.titleView;
    UILabel* titleLabel = [titleView.subviews lastObject];
    
    if (!titleView || !titleLabel) {
        
        titleView = [[UIView alloc] initWithFrame:CGRectZero];
        titleView.tag = -182732;
        self.navigationItem.titleView = titleView;
    
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.alpha = self.twn_preferredNaviTitleAlpha;
        [titleView addSubview:titleLabel];
        
    } else if (titleView.tag != -182732) {
        return;
    }
    
    UIFont* font = [self tnw_customizeNavibarTitleFont];
    UIColor* color = [self tnw_customizeNavibarTintColor];
    
    titleLabel.textColor = color?color:[DFTransparentNavibarConfigure config].defaultNaviTintColor;
    titleLabel.font = font?font:[UIFont boldSystemFontOfSize:17];
    
    titleLabel.text = title;
    [titleLabel sizeToFit];
    
    titleView.frame = titleLabel.frame;
    titleLabel.frame = titleView.bounds;
}

- (void)__tnw_dealloc {
    if (objc_getAssociatedObject(self, "navigationItem.title_observed")) {
        [self removeObserver:self forKeyPath:@"navigationItem.title"];
    }
    [self __tnw_dealloc];
}

@end
