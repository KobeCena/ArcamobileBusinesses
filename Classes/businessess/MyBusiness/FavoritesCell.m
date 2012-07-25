//
//  FavoritesCell.m
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/15/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "FavoritesCell.h"
#import "EdirectoryAppDelegate.h"

@implementation FavoritesCell
@synthesize businessTitle;
@synthesize favoriteDate;
@synthesize bgView;


-(void)applyTheme {
    
    //gets a reference to application delegate
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.themeSettings configureLabel:self.businessTitle withTextColor:[UIColor whiteColor] andFontSize:20];
    
    self.favoriteDate.font = [UIFont fontWithName:@"Helvetica" size:12];
    self.favoriteDate.textColor = [UIColor whiteColor];
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

- (void)dealloc {
    [businessTitle release];
    [favoriteDate release];
    [bgView release];
    [super dealloc];
}
@end
