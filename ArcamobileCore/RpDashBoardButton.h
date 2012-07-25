//
//  RpDashBoardButton.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/1/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RpDashBoardButton : UIButton {
    
    NSNumber *buttonIndex;
    NSURL *buttonImageURL;
    NSNumber * _badgeNumber;
}

@property(nonatomic,retain) NSNumber *badgeNumber;
@property(nonatomic,retain) NSNumber *buttonIndex;
@property(nonatomic,retain) NSURL *buttonImageURL;

@end
