//
//  DFTransparentNavibarConfigure.h

//
//  Created by wanghaojiao on 2017/6/23.
//

@import Foundation;
@import UIKit;

// Set either defaultNaviBgImage or defaultNaviBgColor in AppDelegate's
// - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
// to correctly initialize configurations.
//
// It automatically takes effect on all your navigation controllers.
// See UIViewController+TransparentNavibar when you want to customize specific VCs
@interface DFTransparentNavibarConfigure : NSObject

+ (instancetype)config;

@property (nonatomic, strong) UIImage* defaultNaviBgImage;
@property (nonatomic, strong) UIColor* defaultNaviBgColor;
@property (nonatomic, strong) UIColor* normalNaviTintColor; //tbc...

@end
