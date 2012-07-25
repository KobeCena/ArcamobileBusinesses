//
//  BusinessCell.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/2/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "BusinessCell.h"
#import "EdirectoryAppDelegate.h"
#import "CoreUtility.h"

#define VERTICAL_STAR_SPACE 13.0
#define TOP_PADDING_ADJUST 2.0
#define BOTTOM_PADDING_ADJUST 1.0


@implementation BusinessCell


@synthesize rating;
@synthesize businessTitle;
@synthesize businessSummaryText;
@synthesize businessDistance;
@synthesize businessAddress;
@synthesize businessImage;
@synthesize bgView;



-(void)applyTheme {

    //gets a reference to application delegate
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.themeSettings configureLabel:self.businessTitle withTextColor:nil andFontSize:17];
    [appDelegate.themeSettings configureLabel:self.businessDistance withTheme:THEME_LABEL_LEVEL4];
    //[appDelegate.themeSettings configureLabel:self.businessAddress withTheme:THEME_LABEL_LEVEL6];
    self.businessSummaryText.font = [UIFont fontWithName:@"Helvetica" size:11];
    self.businessSummaryText.textColor = [UIColor whiteColor];
 
}


- (void)drawRect:(CGRect)rect{

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    
    CGRect rectangle = CGRectMake(9,12,101,69);
    
    CGContextAddRect(context, rectangle);
    
    CGContextStrokePath(context);
    
    [self.businessImage drawInRect:CGRectMake(10, 13, 98, 68)];

     
    if (self.businessImage != nil) {
        CGPoint ratingImageOrigin = CGPointMake(95.0, 13.0);
        UIImage *ratingBackgroundImage = [UIImage imageNamed:@"rate_bar_background.png"];
        [ratingBackgroundImage drawAtPoint:ratingImageOrigin];
        UIImage *ratingForegroundImage = [UIImage imageNamed:@"rate_bar_foreground.png"];
        
        UIRectClip( CGRectMake(ratingImageOrigin.x, 
                    ( ratingBackgroundImage.size.height - ((rating*VERTICAL_STAR_SPACE) + BOTTOM_PADDING_ADJUST) ) +VERTICAL_STAR_SPACE ,
                    ratingForegroundImage.size.width,  (rating*VERTICAL_STAR_SPACE) + TOP_PADDING_ADJUST) );
        
        NSLog(@" rating: [%0.2f] :: %0.2f, %0.2f, %0.2f, %0.2f ", rating, 
              ratingImageOrigin.x, 
              ( ratingBackgroundImage.size.height - ((rating*VERTICAL_STAR_SPACE) + BOTTOM_PADDING_ADJUST) ) + VERTICAL_STAR_SPACE, 
              ratingForegroundImage.size.width, (rating*VERTICAL_STAR_SPACE) + TOP_PADDING_ADJUST);
        
        [ratingForegroundImage drawAtPoint:ratingImageOrigin];
    }

    
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [businessTitle              release];
    [businessSummaryText        release];
    [businessDistance           release];
    [businessAddress            release];
    [businessImage              release];
    [bgView                     release];

    [super                      dealloc];
}

@end
