//
//  ThirdViewController.m
//  TransparentNavibar
//
//  Created by wanghaojiao on 2017/6/28.
//  Copyright © 2017年 wangqi03. All rights reserved.
//

#import "ThirdViewController.h"
#import "UIViewController+TransparentNavibar.h"

@interface ThirdViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    self.navibarAlpha = 1;
    [super viewDidLoad];
    self.title = @"oops";
    
    self.scrollview.contentSize = CGSizeMake(self.scrollview.frame.size.width, self.scrollview.frame.size.height+100);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.navibarAlpha = (100-scrollView.contentOffset.y)/100;
}

- (UIColor*)tnw_customizeNavibarBGColor {
    return [UIColor redColor];
}

- (UIColor*)tnw_customizeNavibarTintColor {
    return [UIColor whiteColor];
}

@end
