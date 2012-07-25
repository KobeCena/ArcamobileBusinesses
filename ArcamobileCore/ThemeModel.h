//
//  ThemeModel.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 8/8/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreUtility.h"


@interface ThemeModel : NSObject{
    
    NSDictionary * defaults;
    NSDictionary * navigationBar;
    NSDictionary * tabBar;
    NSDictionary * tabBarSelected;
    NSDictionary * labelLevel1;   
    NSDictionary * labelLevel2;    
    NSDictionary * labelLevel3;
    NSDictionary * labelLevel4;
    NSDictionary * labelLevel5;
    NSDictionary * labelLevel6;
    
@private NSDictionary * themeDict;
}



@property (nonatomic, retain) NSDictionary * defaults;
@property (nonatomic, retain) NSDictionary * navigationBar;
@property (nonatomic, retain) NSDictionary * tabBar;
@property (nonatomic, retain) NSDictionary * tabBarSelected;
@property (nonatomic, retain) NSDictionary * labelLevel1;   
@property (nonatomic, retain) NSDictionary * labelLevel2;   
@property (nonatomic, retain) NSDictionary * labelLevel3;
@property (nonatomic, retain) NSDictionary * labelLevel4;
@property (nonatomic, retain) NSDictionary * labelLevel5;
@property (nonatomic, retain) NSDictionary * labelLevel6;

@property (nonatomic, retain) NSDictionary * themeDict;

-(void)configureLabel:(UILabel *)label  withTextColor:(UIColor *) textColor andFontSize:(CGFloat) fontSize;
-(void)configureLabel:(UILabel *)label  withTheme:(NSString *) labelThemeIdentification;

-(void)configureNavigationBar:(UINavigationBar *)curNavigationBar;
-(void)configureTabBar:(UITabBar *)curTabBar;

-(UIColor *) RGB2HSV: (float)r green: (float)g  blue:(float)b withAlpha: (float) alpha;


- (UIColor *)createColorForTheme:(NSString *) themeName;
- (UIColor *)createColorForTheme:(NSString *) themeName isItHSV: (BOOL) hsv;

- (UIFont *)createFontForTheme:(NSString *) themeName;
- (UIFont *)createFontForTheme:(NSString *) themeName withSize:(float) fontSize;

- (UIColor *)createDefaultColor:(NSString *)attributeName theme:(NSString *)themeName isItHSV:(BOOL)hsv;


@end
