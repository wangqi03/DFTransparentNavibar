//
//  DFTransparentNavibarConfigure.h

//
//  Created by wanghaojiao on 2017/6/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DFTransparentNavibarConfigure : NSObject

+ (instancetype)config;

@property (nonatomic, strong) UIImage* normalNaviBgImage;
@property (nonatomic, strong) UIColor* normalNaviBgColor;

@end
