//
//  DFNavigationTitleView.h
//  TransparentNavibar
//
//  Created by wanghaojiao on 2018/7/24.
//  Copyright © 2018年 wangqi03. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFNavigationTitleView : UIView

@property (nonatomic,weak) UIViewController* vc;
@property (nonatomic,strong) NSString* titleText;
@property (nonatomic) CGFloat innerAlpha;

@end
