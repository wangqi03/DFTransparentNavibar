//
//  DFTransparentNavibarConfigure.m

//
//  Created by wanghaojiao on 2017/6/23.
//

#import "DFTransparentNavibarConfigure.h"

@implementation DFTransparentNavibarConfigure

+ (instancetype)config {
    static DFTransparentNavibarConfigure *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setDefaultNaviTintColor:(UIColor *)defaultNaviTintColor {
    _defaultNaviTintColor = defaultNaviTintColor;
    [[UINavigationBar appearance] setTintColor:defaultNaviTintColor];
}

@end
