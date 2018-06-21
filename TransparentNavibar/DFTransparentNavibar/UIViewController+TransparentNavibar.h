//
//  UIViewController+TransparentNavibar.h

//
//  Created by wanghaojiao on 2017/6/23.
//

@import UIKit;

@interface UIViewController (TransparentNavibar)

//navibar alpha
//by setting this value. you can change transparency of the navigation bar.
//by default it's 1
@property (nonatomic) CGFloat twn_preferredNaviAlpha;
@property (nonatomic) CGFloat twn_preferredNaviTitleAlpha;

//you can override this to specify a default value of twn_preferredNaviAlpha when a view controller is initialized
- (CGFloat)twn_defaultPreferredNaviAlpha;
- (CGFloat)twn_defaultPreferredNaviTitleAlpha;

//you can override these method to customize navigation bar appearance for each specific view controller
- (UIImage*)tnw_customizeNavibarBGImage;
- (UIColor*)tnw_customizeNavibarBGColor;
- (UIColor*)tnw_customizeNavibarTintColor;
- (UIFont*)tnw_customizeNavibarTitleFont;

//fake navi bar
//you dont need to care about these 2.   :)
@property (nonatomic,strong,readonly) UIImageView* fakeNavigationBar;
- (void)createFakeNaviBar;

@end
