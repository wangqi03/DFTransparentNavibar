//
//  DFNavigationTitleView.m
//  TransparentNavibar
//
//  Created by wanghaojiao on 2018/7/24.
//  Copyright © 2018年 wangqi03. All rights reserved.
//

#import "DFNavigationTitleView.h"
#import "UIViewController+TransparentNavibar.h"
#import "DFTransparentNavibarConfigure.h"

@interface DFNavigationTitleView()
@property (nonatomic,weak) UILabel* titleLabel;
@end

@implementation DFNavigationTitleView

#pragma mark - setter
- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText;
    
    self.titleLabel.text = titleText;
    if (titleText.length) {
        UIFont* font = nil;//[self.vc tnw_customizeNavibarTitleFont];
        UIColor* color = nil;//[self.vc tnw_customizeNavibarTintColor];
        
        self.titleLabel.textColor = color?color:[DFTransparentNavibarConfigure config].defaultNaviTintColor;
        self.titleLabel.font = font?font:[UIFont boldSystemFontOfSize:17];
        
        [self.titleLabel sizeToFit];
        CGRect rect = self.frame;
        rect.size = self.titleLabel.frame.size;
        self.frame = rect;
        self.titleLabel.frame = self.bounds;
    }
}

- (void)setInnerAlpha:(CGFloat)innerAlpha {
    _innerAlpha = innerAlpha;
    self.titleLabel.alpha = _innerAlpha;
}

- (void)setVc:(UIViewController *)vc {
    _vc = vc;
    if (_vc) {
        self.innerAlpha = 1;//[vc twn_preferredNaviTitleAlpha];
    }
}

#pragma mark - setup
- (void)prepare {
    _innerAlpha = 1;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

#pragma mark - init
- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

@end
