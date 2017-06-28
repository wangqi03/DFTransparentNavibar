//
//  UINavigationController+TransparentNavibar.h

//
//  Created by wanghaojiao on 2017/6/23.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (TransparentNavibar)<UINavigationControllerDelegate>

- (void)setNavigationBarAlpha:(CGFloat)alpha;
@property (strong, nonatomic) UIView* customizedFakeNaviBar;

@end
