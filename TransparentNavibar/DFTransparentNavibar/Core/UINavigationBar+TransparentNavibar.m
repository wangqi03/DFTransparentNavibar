//
//  UINavigationBar+TransparentNavibar.m
//  DFTransparentNavibar
//
//  Created by wanghaojiao on 2017/9/22.
//

#import "UINavigationBar+TransparentNavibar.h"
#import <objc/runtime.h>

@implementation UINavigationBar (TransparentNavibar)

#pragma mark - exchange
+ (void)load {
    if (self == [UINavigationBar class]) {
        //exchange push
        Method original = class_getInstanceMethod([self class], @selector(setBackgroundImage:forBarMetrics:));
        Method exchanged = class_getInstanceMethod([self class], @selector(__tnw_setBackgroundImage:forBarMetrics:));
        method_exchangeImplementations(original, exchanged);
        
        /*/exchange pop
        original = class_getInstanceMethod([self class], @selector(setBackgroundImage:forBarPosition:barMetrics:));
        exchanged = class_getInstanceMethod([self class], @selector(__tnw_setBackgroundImage:forBarPosition:barMetrics:));
        method_exchangeImplementations(original, exchanged);//*/
    }
}

- (void)__tnw_setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    [self __tnw_setBackgroundImage:[UIImage imageNamed:@"tnw_alpha_bg"] forBarPosition:barPosition barMetrics:barMetrics];
    self.tnw_backgroundImage = backgroundImage;
}

- (void)__tnw_setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    
    //*
    [self __tnw_setBackgroundImage:[UIImage new] forBarMetrics:barMetrics];
    self.translucent = YES;
    /*/
    [self __tnw_setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
    //*/
    
    self.tnw_backgroundImage = backgroundImage;
}

#pragma mark - getter & setter
- (UIImage*)tnw_backgroundImage {
    return objc_getAssociatedObject(self, "tnw_backgroundImage");
}

- (void)setTnw_backgroundImage:(UIImage *)tnw_backgroundImage {
    objc_setAssociatedObject(self, "tnw_backgroundImage", tnw_backgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.tnw_fakeNaviBgView.image = tnw_backgroundImage;
}

- (UIImageView*)tnw_fakeNaviBgView {
    UIImageView* image = objc_getAssociatedObject(self, "tnw_fakeNaviBgView");
    
    if (!image) {
        image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.tnw_fakeNaviBgView = image;
        image.contentMode = UIViewContentModeScaleToFill;
    }
    
    return image;
}

- (void)setTnw_fakeNaviBgView:(UIImageView *)tnw_fakeNaviBgView {
    
    UIImageView* old = objc_getAssociatedObject(self, "tnw_fakeNaviBgView");
    if (old) {
        [old removeFromSuperview];
    }
    
    objc_setAssociatedObject(self, "tnw_fakeNaviBgView", tnw_fakeNaviBgView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //*
    if (self.subviews.count) {
        [self tnw_addFakeNaviBgViewToFirstSubview];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tnw_addFakeNaviBgViewToFirstSubview];
        });
    }//*/
}

- (void)tnw_addFakeNaviBgViewToFirstSubview {
    
    UIView* subView = [self.subviews firstObject];
    if (subView != nil) {
        [subView insertSubview:self.tnw_fakeNaviBgView atIndex:0];
        
        self.tnw_fakeNaviBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        if (subView.frame.origin.y < 0) {
            self.tnw_fakeNaviBgView.frame = subView.bounds;
        } else {
            self.tnw_fakeNaviBgView.frame = CGRectMake(0, -statusBarHeight, [UIApplication sharedApplication].statusBarFrame.size.width, self.bounds.size.height+statusBarHeight);
        }
        
    }
    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (!self.tnw_fakeNaviBgView.superview) {
        if (frame.size.width > 10 && frame.size.height > 1) {
            [self tnw_addFakeNaviBgViewToFirstSubview];
        }
    }
}

@end
