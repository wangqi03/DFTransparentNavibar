//
//  UIViewController+TransparentNavibar.h

//
//  Created by wanghaojiao on 2017/6/23.
//

#import <UIKit/UIKit.h>

@interface UIViewController (TransparentNavibar)

//navibar alpha
//by setting this value. you can change transparency of the navigation bar.
//by default it's 1
@property (nonatomic) CGFloat twn_preferredNaviAlpha;

//you can override this to specify a default value of twn_preferredNaviAlpha when a view controller is initialized
- (CGFloat)twn_defaultPreferredNaviAlpha;

//you can override these method to customize navigation bar appearance for each specific view controller
- (UIImage*)tnw_customizeNavibarBGImage;
- (UIColor*)tnw_customizeNavibarBGColor;
- (UIColor*)tnw_customizeNavibarTintColor;
- (UIFont*)tnw_customizeNavibarTitleFont;

//fake navi bar
//normally you dont need to care about these 3.   :)
@property (nonatomic,strong,readonly) UIImageView* fakeNavigationBar;
//@property (nonatomic) BOOL needsFakeNavibar;
- (void)createFakeNaviBar;//OnTop:(BOOL)onTop;

@end
