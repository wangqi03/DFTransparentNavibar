//
//  UINavigationController+TransparentNavibar.m

//
//  Created by wanghaojiao on 2017/6/23.
//

#import "UINavigationController+TransparentNavibar.h"
#import "UIViewController+TransparentNavibar.h"
#import "DFTransparentNavibarConfigure.h"
#import "UINavigationBar+TransparentNavibar.h"
#import <objc/runtime.h>

//system version
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface TNWDummyObject : NSObject
@property (nonatomic) BOOL viewControllerHasCustomizeNavi;
@property (nonatomic) BOOL lastHasCustomizeNavi;

@property (nonatomic,strong) UIColor* lastColor;
@property (nonatomic,strong) UIImage* lastImage;

@end

@implementation UINavigationController (TransparentNavibar)

#pragma mark - change the alpha
- (void)setNavigationBarAlpha:(CGFloat)alpha {
    self.navigationBar.tnw_fakeNaviBgView.alpha = alpha;
}

- (void)setNavigationTitleAlpha:(CGFloat)alpha {
    
}

#pragma mark - method exchange
+ (void)load {
    if (self == [UINavigationController class]) {
        //exchange push
        Method original = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
        Method exchanged = class_getInstanceMethod([self class], @selector(__tnw_pushViewController:animated:));
        method_exchangeImplementations(original, exchanged);
        
        //exchange pop
        original = class_getInstanceMethod([self class], @selector(popViewControllerAnimated:));
        exchanged = class_getInstanceMethod([self class], @selector(__tnw_popViewControllerAnimated:));
        method_exchangeImplementations(original, exchanged);
        
        //exchange set
        original = class_getInstanceMethod([self class], @selector(setViewControllers:));
        exchanged = class_getInstanceMethod([self class], @selector(__tnw_setViewControllers:));
        method_exchangeImplementations(original, exchanged);
        
        //exchange update interactive
        /*original = class_getInstanceMethod([self class], @selector(viewDidLoad));
        exchanged = class_getInstanceMethod([self class], @selector(__tnw_viewDidLoad));
        method_exchangeImplementations(original, exchanged);//*/
        
        //set delegate
        original = class_getInstanceMethod([self class], @selector(setDelegate:));
        exchanged = class_getInstanceMethod([self class], @selector(__tnw_setRealDelegate:));
        method_exchangeImplementations(original, exchanged);
    }
}

#pragma mark - delegate
- (void)__tnw_setRealDelegate:(id<UINavigationControllerDelegate>)delegate {
    [self __tnw_setRealDelegate:self];
    objc_setAssociatedObject(self, "__tnw_delegate", delegate, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - UINavigationController Delegate
- (id<UINavigationControllerDelegate>)myDelegate {
    return objc_getAssociatedObject(self, "__tnw_delegate");
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return [self myDelegate];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL mySelf = [super respondsToSelector:aSelector];
    if (!mySelf) {
        mySelf = [[self myDelegate] respondsToSelector:aSelector];
    }
    return mySelf;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *topVC = self.topViewController;
    if (topVC != nil) {
        id<UIViewControllerTransitionCoordinator> coor = topVC.transitionCoordinator;
        if (coor != nil) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
                [coor notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context){
                    [self handleInteractionChanges:context];
                }];
            } else {
                [coor notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [self handleInteractionChanges:context];
                }];
            }
        }
    }
    
    id<UINavigationControllerDelegate> delegate = objc_getAssociatedObject(self, "__tnw_delegate");
    if ([delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [delegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)handleInteractionChanges:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if ([context isCancelled]) {
        NSTimeInterval cancelDuration = [context transitionDuration] * (double)[context percentComplete];
        [UIView animateWithDuration:cancelDuration animations:^{
            CGFloat nowAlpha = [context viewControllerForKey:UITransitionContextFromViewControllerKey].twn_preferredNaviAlpha;
            
            [self setNavigationBarAlpha:nowAlpha];
            UIViewController* fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
            BOOL hasCustomizedNavi = ([fromVC tnw_customizeNavibarBGColor]||[fromVC tnw_customizeNavibarBGImage]);
            self.customizedFakeNaviBar.alpha = hasCustomizedNavi?1:0;
        }];
    } else {
        NSTimeInterval finishDuration = [context transitionDuration] * (double)(1 - [context percentComplete]);
        [UIView animateWithDuration:finishDuration animations:^{
            CGFloat nowAlpha = [context viewControllerForKey:
                                 UITransitionContextToViewControllerKey].twn_preferredNaviAlpha;
            
            [self setNavigationBarAlpha:nowAlpha];
            UIViewController* toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
            BOOL hasCustomizedNavi = ([toVC tnw_customizeNavibarBGColor]||[toVC tnw_customizeNavibarBGImage]);
            self.customizedFakeNaviBar.alpha = hasCustomizedNavi?1:0;
        }];
    }
}

#pragma mark - push & pop
- (void)__tnw_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self __tnw_setRealDelegate:self];
    UIViewController* lastVC = [self.viewControllers lastObject];
    
    [self __tnw_pushViewController:viewController animated:animated];
    
    if (self.navigationBarHidden) {
        return;
    }
    
    if (lastVC&&viewController) {
        if (lastVC.twn_preferredNaviAlpha == viewController.twn_preferredNaviAlpha) {
            [self setNavigationBarAlpha:lastVC.twn_preferredNaviAlpha];
        } else {
            if (viewController.twn_preferredNaviAlpha == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [viewController createFakeNaviBar];
                });
                [self setNavigationBarAlpha:lastVC.twn_preferredNaviAlpha];
            } else if (lastVC.twn_preferredNaviAlpha == 1) {
                [lastVC createFakeNaviBar];
                [self setNavigationBarAlpha:viewController.twn_preferredNaviAlpha];
            }
        }
    } else if (!lastVC) {
        [self setNavigationBarAlpha:viewController.twn_preferredNaviAlpha];
    }
}

static NSTimer* __dummyTimer = nil;
- (UIViewController*)__tnw_popViewControllerAnimated:(BOOL)animated {
    UIViewController* viewController = [self __tnw_popViewControllerAnimated:animated];
    UIViewController* lastVC = [self.viewControllers lastObject];
    
    if (lastVC.twn_preferredNaviAlpha == viewController.twn_preferredNaviAlpha) {
        [self setNavigationBarAlpha:lastVC.twn_preferredNaviAlpha];
    } else {
        
        [self setNavigationBarAlpha:0];
        
        if (viewController.twn_preferredNaviAlpha == 1) {
            [viewController createFakeNaviBar];
        } else {
            [lastVC createFakeNaviBar];
        }
    }
    
    BOOL lastHasCustomizeNavi = ([lastVC tnw_customizeNavibarBGColor]||[lastVC tnw_customizeNavibarBGImage]);
    BOOL viewControllerHasCustomizeNavi = ([viewController tnw_customizeNavibarBGColor]||[viewController tnw_customizeNavibarBGImage]);
    
    TNWDummyObject* obj = [[TNWDummyObject alloc] init];
    obj.lastHasCustomizeNavi = lastHasCustomizeNavi;
    obj.viewControllerHasCustomizeNavi = viewControllerHasCustomizeNavi;
    obj.lastColor = [lastVC tnw_customizeNavibarBGColor];
    obj.lastImage = [lastVC tnw_customizeNavibarBGImage];
    
    __dummyTimer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(handleCustomizedNavibarWithDummy:) userInfo:obj repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:__dummyTimer forMode:NSDefaultRunLoopMode];
    
    return viewController;
}

- (void)__tnw_setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    [self __tnw_setViewControllers:viewControllers];
    [self setNavigationBarAlpha:viewControllers.lastObject.twn_preferredNaviAlpha];
}

- (void)handleCustomizedNavibarWithDummy:(NSTimer*)timer {
    TNWDummyObject* dummy = timer.userInfo;
    
    BOOL lastHasCustomizeNavi = dummy.lastHasCustomizeNavi;//([lastVC tnw_customizeNavibarBGColor]||[lastVC tnw_customizeNavibarBGImage]);
    BOOL viewControllerHasCustomizeNavi = dummy.viewControllerHasCustomizeNavi;//([viewController tnw_customizeNavibarBGColor]||[viewController tnw_customizeNavibarBGImage]);
    
    if (lastHasCustomizeNavi!=viewControllerHasCustomizeNavi) {
        
        if (lastHasCustomizeNavi) {
            UIImageView* image = [[UIImageView alloc] init];
            image.image = dummy.lastImage;//[lastVC tnw_customizeNavibarBGImage];
            image.backgroundColor = dummy.lastColor;//[lastVC tnw_customizeNavibarBGColor];
            image.alpha = 0;
            self.customizedFakeNaviBar = image;
        }
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.customizedFakeNaviBar.alpha = lastHasCustomizeNavi?1:0;
        } completion:^(BOOL finished) {
                        /*if (!lastHasCustomizeNavi) {
                            self.customizedFakeNaviBar = nil;
                        }*/
        }];
    }
}

#pragma mark - fake cover bar
- (void)setCustomizedFakeNaviBar:(UIView *)customizedFakeNaviBar {
    if (self.customizedFakeNaviBar) {
        [self.customizedFakeNaviBar removeFromSuperview];
    }
    
    if (!customizedFakeNaviBar) {
        return;
    }
    
    UIView* navibg = self.navigationBar.tnw_fakeNaviBgView;

    customizedFakeNaviBar.frame = navibg.bounds;
    customizedFakeNaviBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    if ([navibg isKindOfClass:[UIImageView class]]) {
        [navibg addSubview:customizedFakeNaviBar];
    } else {
        for (UIImageView* image in navibg.subviews) {
            if (image.frame.origin.y == 0) {
                [image addSubview:customizedFakeNaviBar];
                break;
            }
        }
    }

    
    objc_setAssociatedObject(self, "tnw_customizedFakeNaviBar", customizedFakeNaviBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)customizedFakeNaviBar {
    return objc_getAssociatedObject(self, "tnw_customizedFakeNaviBar");
}

@end

@implementation TNWDummyObject
@end
