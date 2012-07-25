//
//  ThemeModel.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 8/8/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "ThemeModel.h"
#import "CoreUtility.h"


//Enum for the labels 
//typedef enum { DEFAULTS=0,NAVIGATIONBAR=1, TABBAR=2, TABBARSELECTED=3, LEVEL1LABEL=4, LEVEL2LABEL=5, LEVEL3LABEL=6, LEVEL4LABEL=7, LEVEL5LABEL=8, LEVEL6LABEL=9 } LabelType;

typedef enum { DEFAULTS=0, LEVEL1LABEL=1, LEVEL2LABEL=2, LEVEL3LABEL=3, LEVEL4LABEL=4, LEVEL5LABEL=5, LEVEL6LABEL =6} LabelType;

//Dictionary used to store the possible label type received
static NSDictionary *labelTypeLookupTable;


#define RGB_CONSTANT	255
#define HSV_ALPHA_CONSTANT 0.6f

@interface ThemeModel()

- (void) loadAllDefaultsIntoMemory;
- (NSDictionary *) getLabelTheme:(NSString *) labelTheme;

- (UIFont *)createFontForTheme:(NSString *) themeName;
- (UIFont *)createFontForTheme:(NSString *) themeName withSize:(float) fontSize;

@end

@implementation ThemeModel


@synthesize defaults;
@synthesize navigationBar;
@synthesize tabBar;
@synthesize tabBarSelected;
@synthesize labelLevel1;    
@synthesize labelLevel2;    
@synthesize labelLevel3;
@synthesize labelLevel4;
@synthesize labelLevel5;
@synthesize labelLevel6;

@synthesize themeDict;



- (id)init
{
    self = [super init];
    if (self) {
        
        
		if (labelTypeLookupTable == nil)
		{
			labelTypeLookupTable = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:DEFAULTS], THEME_DEFAULTS,
                                    [NSNumber numberWithInteger:DEFAULTS], THEME_NAVIGATIONBAR,
                                    [NSNumber numberWithInteger:DEFAULTS], THEME_TABBAR,
                                    [NSNumber numberWithInteger:DEFAULTS], THEME_TABBARSELECTED, 
                                    [NSNumber numberWithInteger:LEVEL1LABEL], THEME_LABEL_LEVEL1, 
                                    [NSNumber numberWithInteger:LEVEL2LABEL], THEME_LABEL_LEVEL2, 
                                    [NSNumber numberWithInteger:LEVEL3LABEL], THEME_LABEL_LEVEL3, 
                                    [NSNumber numberWithInteger:LEVEL4LABEL], THEME_LABEL_LEVEL4, 
                                    [NSNumber numberWithInteger:LEVEL5LABEL], THEME_LABEL_LEVEL5, 
                                    [NSNumber numberWithInteger:LEVEL6LABEL], THEME_LABEL_LEVEL6,                                     
                                    nil]; 
		}
        
        //Load the theme file into memory
        NSDictionary * appTheme = [CoreUtility getDictionaryFromPlistNamed:@"ApplicationTheme"];
        themeDict = [appTheme objectForKey:@"THEME"];
        [self loadAllDefaultsIntoMemory];
    }
    
    return self;
}


-(void) loadAllDefaultsIntoMemory{
    
    defaults = [[NSDictionary alloc] initWithDictionary:[themeDict objectForKey:THEME_DEFAULTS]];
    
    
    navigationBar = [[NSDictionary alloc] initWithDictionary:[defaults objectForKey:THEME_NAVIGATIONBAR]];
    tabBar = [[NSDictionary alloc] initWithDictionary:[defaults objectForKey:THEME_TABBAR]];
    tabBarSelected = [[NSDictionary alloc] initWithDictionary:[defaults objectForKey:THEME_TABBARSELECTED]];
    
    labelLevel1 = [[NSDictionary alloc] initWithDictionary:[themeDict objectForKey:THEME_LABEL_LEVEL1]];
    labelLevel2 = [[NSDictionary alloc] initWithDictionary:[themeDict objectForKey:THEME_LABEL_LEVEL2]];
    labelLevel3 = [[NSDictionary alloc] initWithDictionary:[themeDict objectForKey:THEME_LABEL_LEVEL3]];
    labelLevel4 = [[NSDictionary alloc] initWithDictionary:[themeDict objectForKey:THEME_LABEL_LEVEL4]];
    labelLevel5 = [[NSDictionary alloc] initWithDictionary:[themeDict objectForKey:THEME_LABEL_LEVEL5]];
    labelLevel6 = [[NSDictionary alloc] initWithDictionary:[themeDict objectForKey:THEME_LABEL_LEVEL6]]; 
    
    //NSLog(@"LableLevel1 color: %@", [labelLevel1 objectForKey:THEME_COLOR] );
    //NSLog(@"Defaults font: %@", [defaults objectForKey:THEME_FONT] );
    //NSLog(@"NavigationBar red: %@", [[defaults objectForKey:THEME_NAVIGATIONBAR] objectForKey:THEME_RED] );
    
    
}

-(NSDictionary *) getLabelTheme:(NSString *) labelTheme{
    
    
    NSNumber * labelType = [labelTypeLookupTable objectForKey:labelTheme];
    
    switch ([labelType intValue]) {
        case DEFAULTS:
            if ([labelTheme isEqualToString:THEME_TABBAR]) {
                return tabBar;
            } else if([labelTheme isEqualToString:THEME_TABBARSELECTED]) {
                return tabBarSelected;
            } else {
                return defaults;
            }
            break;
        case LEVEL1LABEL:
            return labelLevel1 ;
            break;
            
        case LEVEL2LABEL:
            return labelLevel2 ;
            break;
            
        case LEVEL3LABEL:
            return labelLevel3 ;
            break;
            
        case LEVEL4LABEL:
            return labelLevel4 ;
            break;
            
        case LEVEL5LABEL:
            return labelLevel5 ;
            break;
            
        case LEVEL6LABEL:
            return labelLevel6 ;
            break;
            
        default:
            break;
    }
    
    return nil;
    
}

/*
 This methods creates a UIColoer based in a given pre-defined configuration name 
 */

-(UIColor *)createDefaultColor:(NSString *)attributeName theme:(NSString *)themeName isItHSV:(BOOL)hsv {
    
    NSDictionary * themeDictonary = [self getLabelTheme:themeName];    
    
    NSNumber * redColor = [[themeDictonary objectForKey:attributeName] objectForKey:THEME_RED];
    NSNumber * greenColor = [[themeDictonary objectForKey:attributeName] objectForKey:THEME_GREEN];
    NSNumber * blueColor = [[themeDictonary objectForKey:attributeName] objectForKey:THEME_BLUE];
    
    CGFloat red   = [redColor floatValue];
    CGFloat green = [greenColor floatValue];
    CGFloat blue  = [blueColor floatValue];
    
    if (hsv) {
        return [self RGB2HSV:red green:green blue:blue withAlpha: HSV_ALPHA_CONSTANT];
    } else {
        
        red   /= (RGB_CONSTANT);
        green /= (RGB_CONSTANT);
        blue  /= (RGB_CONSTANT);
        
        return [UIColor colorWithRed:red 
                               green:green
                                blue:blue
                               alpha:1.0f];
    }
    
}

-(UIColor *)createFontColorForTheme:(NSString *) themeName{
    return [self createFontColorForTheme:themeName isItHSV:NO];
}
-(UIColor *)createFontColorForTheme:(NSString *) themeName isItHSV: (BOOL) hsv{
    return [self createDefaultColor:THEME_FONTCOLOR theme:themeName isItHSV:hsv];
}


-(UIColor *)createColorForTheme:(NSString *) themeName{
    return [self createColorForTheme:themeName isItHSV:NO];
}

-(UIColor *)createColorForTheme:(NSString *) themeName isItHSV: (BOOL) hsv{
    return [self createDefaultColor:THEME_COLOR theme:themeName isItHSV:hsv];
}

/*
 This methods creates a UIFont based in a given pre-defined configuration name  
 */
-(UIFont *)createFontForTheme:(NSString *) themeName{
    NSDictionary * themeDictonary = [self getLabelTheme:themeName];
    
    NSNumber * fontSizeNumber = (NSNumber *)[themeDictonary objectForKey:THEME_SIZE];
    
    
    NSString * fontName = [themeDictonary objectForKey:THEME_FONT];
    
    return [UIFont fontWithName: fontName 
                           size: [fontSizeNumber floatValue] ];
    
}


/*
 This methods creates a UIFont based in a given pre-defined configuration name and a defined size 
 */
-(UIFont *)createFontForTheme:(NSString *) themeName withSize:(float) fontSize{
    NSDictionary * themeDictonary = [self getLabelTheme:themeName];
    
    NSString * fontName = [themeDictonary objectForKey:THEME_FONT];
    
    return [UIFont fontWithName: fontName 
                           size: fontSize ];
    
}


/*
 This methods configures a font for an UILabel with the defaults value for FontName and FontColor, but you can set the font Size.
 */
-(void)configureLabel:(UILabel *)label  withTextColor:(UIColor *) textColor andFontSize:(CGFloat) fontSize{
    
    UIFont * labelFont = [self createFontForTheme:THEME_DEFAULTS withSize:fontSize];
    
    [label setFont: labelFont];
    
    if (isEmpty(textColor)) {
        [label setTextColor: [self createColorForTheme:THEME_DEFAULTS] ];
    }else{
        [label setTextColor:textColor];
    }
    
    
}

-(void)configureLabel:(UILabel *)label  withTheme:(NSString *) labelThemeIdentification{
    
    /*
     for (NSString * str in [labelTheme allKeys]) {
     NSLog(@"Key:  %@  value: %@", str, [labelTheme objectForKey:str]);
     }
     
     for (NSString *family in [UIFont familyNames]) {
     NSLog(@"%@", [UIFont fontNamesForFamilyName:family]);
     }
     */
    
    
    [label setFont: [self createFontForTheme:labelThemeIdentification] ];

    [label setTextColor: [self createColorForTheme:labelThemeIdentification] ];
    
}

-(void)configureNavigationBar:(UINavigationBar *)curNavigationBar {
    [curNavigationBar setBackgroundColor:[UIColor blackColor]];
    [curNavigationBar setTintColor: [self createColorForTheme:THEME_TABBAR isItHSV:YES]];
}

-(void)configureTabBar:(UITabBar *)curTabBar {
    
    [curTabBar setBackgroundColor:[UIColor blackColor]];
    
    if ([curTabBar respondsToSelector:@selector(setTintColor:)]) {
        [curTabBar setTintColor: [self createColorForTheme:THEME_TABBAR isItHSV:YES]];
    }
    
    if ([curTabBar respondsToSelector:@selector(setSelectedImageTintColor:)]) {
        [curTabBar setSelectedImageTintColor: [self createColorForTheme:THEME_TABBARSELECTED]];
    }
    
    
    for (UITabBarItem *tabItem in curTabBar.items) {
        
        if ([tabItem respondsToSelector:@selector(setTitleTextAttributes:forState:)]) {
            [tabItem setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [self createFontColorForTheme:THEME_TABBAR],UITextAttributeTextColor,[NSValue valueWithUIOffset:UIOffsetMake(0,0)], UITextAttributeTextShadowOffset, 
              [UIFont fontWithName:@"Helvetica Bold" size:10.0], UITextAttributeFont, nil] 
                                   forState:UIControlStateNormal];
            
            [tabItem setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [self createFontColorForTheme:THEME_TABBARSELECTED],UITextAttributeTextColor,[NSValue valueWithUIOffset:UIOffsetMake(0,0)], UITextAttributeTextShadowOffset, 
              [UIFont fontWithName:@"Helvetica Bold" size:10.0], UITextAttributeFont, nil] 
                                   forState:UIControlStateSelected];
        }
    }
    
}

-(UIColor *) RGB2HSV: (float)r green: (float)g  blue:(float)b withAlpha: (float) alpha {
    
    float hue;
    float sat;
    float bri;
    
    RGB2HSL(r, g, b, &hue, &sat, &bri);
    return [UIColor colorWithHue:hue saturation:sat brightness:bri alpha:alpha];
}

@end
