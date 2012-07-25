//
//  FavoritesCell.h
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/15/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesCell : UITableViewCell {
    UILabel *businessTitle;
    UILabel *favoriteDate;
    UIView *bgView;
}

@property (nonatomic, retain) IBOutlet UILabel *businessTitle;
@property (nonatomic, retain) IBOutlet UILabel *favoriteDate;
@property (nonatomic, retain) IBOutlet UIView *bgView;

-(void)applyTheme;
@end
