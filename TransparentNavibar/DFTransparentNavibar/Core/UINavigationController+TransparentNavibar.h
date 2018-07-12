//
//  UINavigationController+TransparentNavibar.h

//
//  Created by wanghaojiao on 2017/6/23.
//

@import UIKit;

#define DF_TWN_NAVI_HEIGHT (self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height)

@interface UINavigationController (TransparentNavibar)<UINavigationControllerDelegate>

- (void)setNavigationBarAlpha:(CGFloat)alpha;
@property (strong, nonatomic) UIView* customizedFakeNaviBar;

@end
