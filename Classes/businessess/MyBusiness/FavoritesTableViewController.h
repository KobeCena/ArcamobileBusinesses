//
//  FavoritesTableViewController.h
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/15/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesCell.h"

@interface FavoritesTableViewController : UITableViewController {
    FavoritesCell *tmpCell;
    NSMutableArray * datasourceArray;    

    //refers to the xib-based UiTableCellView
    UINib *cellNib;    
    
    //refers to ViewController that call this MyReviewsTableViewController
    UIViewController * reviewParentViewController;
    
}

@property (nonatomic, retain) IBOutlet FavoritesCell *tmpCell;
@property (nonatomic, retain) NSMutableArray * datasourceArray;
@property (nonatomic, retain) UINib *cellNib;
@property (nonatomic, assign) UIViewController * reviewParentViewController;

@end
