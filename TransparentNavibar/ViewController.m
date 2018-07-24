//
//  ViewController.m
//  TransparentNavibar
//
//  Created by wanghaojiao on 2017/6/28.
//  Copyright © 2017年 wangqi03. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+TransparentNavibar.h"
#import "DFTransparentNavibarConfigure.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"hello";
}

- (CGFloat)twn_defaultPreferredNaviAlpha {
    return 0;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toNext"]) {
        ((ViewController*)segue.destinationViewController).twn_preferredNaviAlpha = 1;
        segue.destinationViewController.title = @"againagainagainagainagainagainagain";
    }
}


@end
