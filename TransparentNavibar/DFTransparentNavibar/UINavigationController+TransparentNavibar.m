//
//  UINavigationController+TransparentNavibar.m

//
//  Created by wanghaojiao on 2017/6/23.
//

#import "UINavigationController+TransparentNavibar.h"
#import "UIViewController+TransparentNavibar.h"
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
    ((UIView*)self.navigationBar.subviews.firstObject).alpha = alpha;
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
        
        //exchange update interactive
        original = class_getInstanceMethod([self class], @selector(_updateInteractiveTransition:));
        exchanged = class_getInstanceMethod([self class], @selector(__tnw_updateInteractiveTransition:));
        method_exchangeImplementations(original, exchanged);
        
        //set delegate
        original = class_getInstanceMethod([self class], @selector(setDelegate:));
        exchanged = class_getInstanceMethod([self class], @selector(__tnw_setRealDelegate:));
        method_exchangeImplementations(original, exchanged);
    }
}

#pragma mark -
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
            CGFloat nowAlpha = [context viewControllerForKey:UITransitionContextFromViewControllerKey].navibarAlpha;
            
            [self setNavigationBarAlpha:nowAlpha];
            UIViewController* fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
            BOOL hasCustomizedNavi = ([fromVC tnw_customizeNavibarBGColor]||[fromVC tnw_customizeNavibarBGImage]);
            self.customizedFakeNaviBar.alpha = hasCustomizedNavi?1:0;
        }];
    } else {
        NSTimeInterval finishDuration = [context transitionDuration] * (double)(1 - [context percentComplete]);
        [UIView animateWithDuration:finishDuration animations:^{
            CGFloat nowAlpha = [context viewControllerForKey:
                                 UITransitionContextToViewControllerKey].navibarAlpha;
            
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
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [viewController loadViewIfNeeded];
    } else {
//        [viewController loadView];
        [viewController viewDidLoad];
    }
    
    if (lastVC.navibarAlpha == viewController.navibarAlpha) {
        [self setNavigationBarAlpha:lastVC.navibarAlpha];
    } else {
        if (viewController.navibarAlpha == 1) {
            [viewController setNeedsFakeNavibar:YES];
        } else {
            [lastVC createFakeNaviBarOnTop:YES];
        }
    }
}

static NSTimer* __dummyTimer = nil;
- (UIViewController*)__tnw_popViewControllerAnimated:(BOOL)animated {
    UIViewController* viewController = [self __tnw_popViewControllerAnimated:animated];
    UIViewController* lastVC = [self.viewControllers lastObject];
    
    if (lastVC.navibarAlpha == viewController.navibarAlpha) {
        [self setNavigationBarAlpha:lastVC.navibarAlpha];
    } else {
        if (viewController.navibarAlpha == 1) {
            [self setNavigationBarAlpha:0];
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
                        if (!lastHasCustomizeNavi) {
                            self.customizedFakeNaviBar = nil;
                        }
        }];
    }
}

- (void)__tnw_updateInteractiveTransition:(CGFloat)percentComplete {
    [self __tnw_updateInteractiveTransition:percentComplete];
    [__dummyTimer invalidate];
    __dummyTimer = nil;
    UIViewController *topVC = self.topViewController;
    
    if (topVC != nil) {
        id<UIViewControllerTransitionCoordinator> coor = topVC.transitionCoordinator;
        if (coor != nil) {

            CGFloat fromAlpha = [coor viewControllerForKey:UITransitionContextFromViewControllerKey].navibarAlpha;
            CGFloat toAlpha = [coor viewControllerForKey:UITransitionContextToViewControllerKey].navibarAlpha;
            
            if (fromAlpha == toAlpha) {
                [self setNavigationBarAlpha:fromAlpha];
            } else {
                [self setNavigationBarAlpha:0];
            }
            
            BOOL fromHasCustomizeNavi = ([[coor viewControllerForKey:UITransitionContextFromViewControllerKey] tnw_customizeNavibarBGColor]||[[coor viewControllerForKey:UITransitionContextFromViewControllerKey] tnw_customizeNavibarBGImage]);
            BOOL toHasCustomizeNavi = ([[coor viewControllerForKey:UITransitionContextToViewControllerKey] tnw_customizeNavibarBGColor]||[[coor viewControllerForKey:UITransitionContextToViewControllerKey] tnw_customizeNavibarBGImage]);
            if (fromHasCustomizeNavi != toHasCustomizeNavi) {
                if (!self.customizedFakeNaviBar.superview&&toHasCustomizeNavi) {
                    UIImageView* image = [[UIImageView alloc] init];
                    image.image = [[coor viewControllerForKey:UITransitionContextToViewControllerKey] tnw_customizeNavibarBGImage];
                    image.backgroundColor = [[coor viewControllerForKey:UITransitionContextToViewControllerKey] tnw_customizeNavibarBGColor];
                    image.alpha = 0;
                    self.customizedFakeNaviBar = image;
                }
                self.customizedFakeNaviBar.alpha = fromHasCustomizeNavi?(1-percentComplete):percentComplete;
            }
        }
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
    
    customizedFakeNaviBar.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, 64);
    
    UIView* navibg = self.navigationBar.subviews.firstObject;
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
    UIView* view = objc_getAssociatedObject(self, "tnw_customizedFakeNaviBar");
    
//    if (!view) {
//        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
//        view.backgroundColor = WHITE_NAVI_BG;
//        view.alpha = 0;
//        UIView* navibg = self.navigationBar.subviews.firstObject;
//        for (UIImageView* image in navibg.subviews) {
//            if (image.frame.origin.y == 0) {
//                [image addSubview:view];
//                break;
//            }
//        }
//        [self setCustomizedFakeNaviBar:view];
//    }
    
    return view;
}

@end

@implementation TNWDummyObject
@end
