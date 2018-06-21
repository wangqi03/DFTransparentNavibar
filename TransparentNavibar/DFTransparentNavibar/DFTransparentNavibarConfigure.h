//
//  DFTransparentNavibarConfigure.h

//
//  Created by wanghaojiao on 2017/6/23.
//

@import Foundation;
@import UIKit;

// Set normalNaviBgImage or normalNaviBgColor in AppDelegate's
// - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
// to correctly initialize configurations.
//
// It automatically takes effect on all your navigation controllers.
// See UIViewController+TransparentNavibar when you want to customize specific VCs
@interface DFTransparentNavibarConfigure : NSObject

+ (instancetype)config;

@property (nonatomic, strong) UIImage* normalNaviBgImage;
@property (nonatomic, strong) UIColor* normalNaviBgColor;
@property (nonatomic, strong) UIColor* normalNaviTintColor; //tbc...

@end
