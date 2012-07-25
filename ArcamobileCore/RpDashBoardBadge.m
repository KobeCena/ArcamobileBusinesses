//
//  RpDashBoardBadge.m
//  ArcaMobileCore
//
//  Created by Ricardo Silva on 2/3/12.
//  Copyright (c) 2012 Arca Solutions Inc. All rights reserved.
//

#import "RpDashBoardBadge.h"

@implementation RpDashBoardBadge
@synthesize badgeIndex;


- (void)dealloc {
    [badgeIndex release];
}

- (id)initWithFrame:(CGRect)frame andNumber:(int)badgeNumber
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILabel *numberLabel = [[[UILabel alloc] initWithFrame:self.frame] autorelease];
        
        CGPoint saveCenter = numberLabel.center;
        CGRect newFrame = CGRectMake(numberLabel.frame.origin.x, numberLabel.frame.origin.y, frame.size.width, frame.size.height);

        [self.layer setShouldRasterize:YES];
        [self.layer setRasterizationScale:2.0];
        numberLabel.frame = newFrame;
        numberLabel.layer.cornerRadius = frame.size.width / 2.0;
        numberLabel.center = saveCenter;      
        numberLabel.layer.borderWidth = 1.5;
        numberLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        numberLabel.text = [NSString stringWithFormat:@"%i", badgeNumber];
        numberLabel.font = [UIFont boldSystemFontOfSize:12];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.textAlignment = UITextAlignmentCenter;
        numberLabel.backgroundColor = [UIColor redColor];
        [self addSubview:numberLabel];        
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
    
}

@end
