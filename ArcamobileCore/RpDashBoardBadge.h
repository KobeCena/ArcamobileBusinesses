//
//  RpDashBoardBadge.h
//  ArcaMobileCore
//
//  Created by Ricardo Silva on 2/3/12.
//  Copyright (c) 2012 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RpDashBoardBadge : UIView{
        NSNumber *badgeIndex;
}

@property(nonatomic,retain) NSNumber *badgeIndex;

- (id)initWithFrame:(CGRect)frame andNumber:(int)badgeNumber;
@end
