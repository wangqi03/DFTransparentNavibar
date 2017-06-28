//
//  ThirdViewController.m
//  TransparentNavibar
//
//  Created by wanghaojiao on 2017/6/28.
//  Copyright © 2017年 wangqi03. All rights reserved.
//

#import "ThirdViewController.h"
#import "UIViewController+TransparentNavibar.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    self.navibarAlpha = 1;
    [super viewDidLoad];
    self.title = @"oops";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor*)tnw_customizeNavibarBGColor {
    return [UIColor redColor];
}

- (UIColor*)tnw_customizeNavibarTintColor {
    return [UIColor whiteColor];
}

@end
