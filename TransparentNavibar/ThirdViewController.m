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
    [super viewDidLoad];
    self.title = @"oops";
    
    self.scrollview.contentSize = CGSizeMake(self.scrollview.frame.size.width, self.scrollview.frame.size.height+100);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.twn_preferredNaviAlpha = (100-scrollView.contentOffset.y)/100;
    self.twn_preferredNaviTitleAlpha = self.twn_preferredNaviAlpha/2+0.5;
}

- (UIColor*)tnw_customizeNavibarBGColor {
    return [UIColor redColor];
}

- (UIColor*)tnw_customizeNavibarTintColor {
    return [UIColor blueColor];
}

@end
