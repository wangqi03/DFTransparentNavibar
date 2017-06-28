//
//  UIViewController+TransparentNavibar.h

//
//  Created by wanghaojiao on 2017/6/23.
//

#import <UIKit/UIKit.h>

@interface UIViewController (TransparentNavibar)

//navibar alpha
@property (nonatomic) CGFloat navibarAlpha;

//fake navi bar
@property (nonatomic,strong,readonly) UIImageView* fakeNavigationBar;
@property (nonatomic) BOOL needsFakeNavibar;
- (void)createFakeNaviBarOnTop:(BOOL)onTop;

//you should override these method to customize navigation bar appearance for each specific view controller
- (UIImage*)tnw_customizeNavibarBGImage;
- (UIColor*)tnw_customizeNavibarBGColor;
- (UIColor*)tnw_customizeNavibarTintColor;
- (UIFont*)tnw_customizeNavibarTitleFont;

@end
