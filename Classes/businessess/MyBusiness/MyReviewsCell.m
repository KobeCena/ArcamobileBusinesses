//
//  MyReviewsCell.m
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/15/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "MyReviewsCell.h"
#import "EdirectoryAppDelegate.h"

#define EDITING_HORIZONTAL_OFFSET 80.0f

@implementation MyReviewsCell
@synthesize bgView;
@synthesize businessTitle;
@synthesize reviewRate;
@synthesize reviewDate;

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

-(void)applyTheme {
    
    
    //gets a reference to application delegate
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.themeSettings configureLabel:self.businessTitle withTextColor:[UIColor whiteColor] andFontSize:20];
    
    self.reviewDate.font = [UIFont fontWithName:@"Helvetica" size:12];
    self.reviewDate.textColor = [UIColor whiteColor];    
}

//#pragma mark - editing stuff
//- (void)setEditing:(BOOL)editing animated:(BOOL)animated
//{
//    [self setNeedsLayout];
//}
//
//- (void)layoutSubviews
//{
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    
//    [super layoutSubviews];
//    
//    if (((UITableView *)self.superview).isEditing)
//    {
//        CGRect contentFrame = self.contentView.frame;
//        contentFrame.origin.x = EDITING_HORIZONTAL_OFFSET;
//        self.contentView.frame = contentFrame;
//    }
//    else
//    {
//        CGRect contentFrame = self.contentView.frame;
//        contentFrame.origin.x = 0;
//        self.contentView.frame = contentFrame;
//    }
//    
//    [UIView commitAnimations];
//}

- (void)dealloc {
    [bgView release];
    [businessTitle release];
    [reviewRate release];
    [reviewDate release];
    [super dealloc];
}
@end
