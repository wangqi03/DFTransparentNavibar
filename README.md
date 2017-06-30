# DFTransparentNavibar

# what does it do
Gives you a simple way to control the transparency of your navigation bar. 
And provides transition animations when your view controllers navigate.
It ONLY supports navigation bars with translucent set to NO. i.e. no blur effects

# how to integrate
pod 'DFTransparentNavibar'

# how to use it:

1. Set a default navi bar background image/color in [DFTransparentNavibarConfigure config] before any of your view controller initialized.

2. Control navigation bar's alpha by setting navibarAlpha of each view controller. Or override - (CGFloat)defaultNavibarAlpha to provide a default value for each of them.

3. If you need a navigation bar to be other than the default background. Override the following methods in the each view controllers:
- (UIImage*)tnw_customizeNavibarBGImage;
- (UIColor*)tnw_customizeNavibarBGColor;
- (UIColor*)tnw_customizeNavibarTintColor;
- (UIFont*)tnw_customizeNavibarTitleFont;

4. The - (UIColor*)tnw_customizeNavibarTintColor only change title text color of the bar. 
You should manage the colors if you have other navigation items or navigation title view.

See demo for detail.
Feel free to email me. wangqi03@outlook.com
:)
