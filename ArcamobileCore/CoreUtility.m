//
//  Utility.m
//  JuridGen
//
//  Created by Ricardo Silva on 12/13/10.
//  Copyright 2010 Arca Solutions Inc. All rights reserved.
//

#import "CoreUtility.h"
#import <CommonCrypto/CommonDigest.h>
#import <MessageUI/MFMailComposeViewController.h>

@implementation CoreUtility

//Constants defined about themes
NSString *const THEME_DEFAULTS = @"Defaults";
NSString *const THEME_COLOR = @"color";
NSString *const THEME_FONTCOLOR = @"fontColor";
NSString *const THEME_SIZE = @"fontSize";
NSString *const THEME_FONT = @"fontName";
NSString *const THEME_NAVIGATIONBAR = @"navigationBar";
NSString *const THEME_TABBAR = @"tabBar";
NSString *const THEME_TABBARSELECTED = @"tabBarSelected";
NSString *const THEME_LABEL_LEVEL1 = @"LabelLevel1";
NSString *const THEME_LABEL_LEVEL2 = @"LabelLevel2";
NSString *const THEME_LABEL_LEVEL3 = @"LabelLevel3";
NSString *const THEME_LABEL_LEVEL4 = @"LabelLevel4";
NSString *const THEME_LABEL_LEVEL5 = @"LabelLevel5";
NSString *const THEME_LABEL_LEVEL6 = @"LabelLevel6";
NSString *const THEME_RED = @"red";
NSString *const THEME_GREEN = @"green";
NSString *const THEME_BLUE = @"blue";


+ (void)writeMutableDictionaryToPlist:(NSMutableDictionary *)dict withName:(NSString *)newName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:newName];
    
    [dict writeToFile:filePath atomically: YES];

}

+ (NSMutableDictionary *)loadPlistToDictionaryWithName:(NSString *)newName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:newName];

    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];

    return plistDict;
}

+ (void)writeDictionaryToPlist:(NSDictionary *)dict
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"header.plist"];
    
    [dict writeToFile:filePath atomically: YES];
}


+ (NSString *) getMD5Hash:(NSString *)str{
	
	const char *cStr = [str UTF8String];
	
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5( cStr, strlen(cStr), result );
	
	return [NSString 
			
			stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			
			result[0], result[1],
			
			result[2], result[3],
			
			result[4], result[5],
			
			result[6], result[7],
			
			result[8], result[9],
			
			result[10], result[11],
			
			result[12], result[13],
			
			result[14], result[15]
			
			];
	
}



+(NSString *) getHexStringFromRed:(CGFloat)redValue fromGreen:(CGFloat)greenValue fromBlue:(CGFloat)blueValue {  
    
    CGFloat r, g, b;  
    r = (redValue / 255);  
    g = (greenValue / 255);  
    b = (blueValue / 255);  

    
    
    // Fix range if needed  
    if (r < 0.0f) r = 0.0f;  
    if (g < 0.0f) g = 0.0f;  
    if (b < 0.0f) b = 0.0f;  
    
    if (r > 1.0f) r = 1.0f;  
    if (g > 1.0f) g = 1.0f;  
    if (b > 1.0f) b = 1.0f;  
    
    // Convert to hex string between 0x00 and 0xFF  
    return [NSString stringWithFormat:@"%02X%02X%02X",  
            (int)(r * 255), (int)(g * 255), (int)(b * 255)];  
}  


+ (void)showAnAlertMessage:(NSString *)i18NMessageKey withTitle:(NSString *) i18NTitleKey{
	NSLog(@"%@", NSLocalizedString(@"i18NKeyString", @"Title for alert displayed when download or parse error occurs.") );
	
    UIAlertView *alertErrorView = [[UIAlertView alloc] 
								   initWithTitle:NSLocalizedString(i18NTitleKey, @"Title for alert displayed when download or parse error occurs.") 
								   message:NSLocalizedString(i18NMessageKey, @"Message body for this alert view") 
								   delegate:nil
								   cancelButtonTitle:NSLocalizedString(@"OK", @"")
								   otherButtonTitles:nil
								   ];
	
    [alertErrorView show];
    [alertErrorView release];
}

#pragma mark - Gets a Dictionary from a plist file
+ (NSDictionary *)getDictionaryFromPlistNamed:(NSString *)plistFileName{
	//Gets the URL string from a plist file
	return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistFileName ofType:@"plist"]];
	
}



	
@end
