//
//  ReviewCell.m
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/12/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "ReviewCell.h"
#define VERTICAL_STAR_SPACE 13.0
#define TOP_PADDING_ADJUST 2.0
#define BOTTOM_PADDING_ADJUST 1.0


@implementation ReviewCell

@synthesize rating;
@synthesize bgView;
@synthesize reviewerName;
@synthesize reviewDate;
@synthesize reviewText;
@synthesize reviewerImage;
@synthesize reviewerImageView;
@synthesize cacheControl;
@synthesize reviewImageURL;

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

- (RpCacheController *) cacheControl {
    
    if (cacheControl != nil) {
        return cacheControl;
    }
    
    //init the cacheController
    RpCacheController * tempCache = [[RpCacheController alloc] initWhithLastUpdateFromServer: [NSDate date] ];
    [self setCacheControl:tempCache];
    [tempCache release];
    //sets the delegate
    [self.cacheControl setDelegate: self];
    
    return self.cacheControl;
}


- (void)drawRect:(CGRect)rect{
    NSLog(@"drawRect");
    
    if (self.reviewerImage != nil) {
        
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
    
    [[self cacheControl] prepareCachedImage: [NSURL URLWithString: self.reviewImageURL] forThisIndex:0];
    
    
}

- (void)appImageDidLoad:(NSData *)imageData forIndex:(int)index {
    [self setReviewerImage: [UIImage imageWithData:imageData]];
    if(self.reviewerImage != nil) {
        [reviewerImageView setImage: self.reviewerImage];
        [reviewerImageView setContentMode:UIViewContentModeScaleAspectFit];
    }
}

- (void)dealloc {
    [bgView release];
    [reviewerName release];
    [reviewDate release];
    [reviewText release];
    [reviewerImage release];
    [reviewerImageView release];
    
    [cacheControl setDelegate:nil];
    [cacheControl release];
    
    [reviewImageURL release];
    
    [super dealloc];
}

@end
