//
//  BusinessListViewController.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/2/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessCell.h"
#import "EdirectoryXMLParser.h"
#import "EdirectoryUserLocation.h"
#import "ListTableView.h"
#import "IconDownloader.h"
#import "Setting.h"
#import "ARCAserver_businesses.h"

@interface BusinessListViewController : UIViewController <UIScrollViewDelegate, IconDownloaderDelegate, EdirectoryXMLParserDelegate, EdirectoryUserLocationDelegate> {
    
    BusinessCell *tmpCell;
    NSArray *BusinessArray;
	//This is the view that "locks" the mapView until the results aren't fully parsed.
	UIView *searching;    
    ListTableView *tableView;

	//For pagination pourposes
	UITableViewCell *moreDataCell;
	UITableViewCell *paggingCell;
	
	UIButton *previousButton;
	UIButton *nextButton;
	UILabel *actualPageLabel;
	
	int totalNumberOfPageResults;
	int actualPageNumber;
    
    //controls the deal category that was requested
    NSInteger categoryId;
    //controls the deal keyword that was requested
    NSString *keyword;
 
    //to access app settings
    Setting *setting;
    
    double pLatitude, pLongitude;
    EdirectoryUserLocation *edirectoryUserLocation;
    
    IBOutlet UILabel *loadingLabel;
    IBOutlet UILabel *loadMoreListings;
    
    NSMutableDictionary *imageDownloadsInProgress;
    
    //the tableview background image
    UIImageView * bgView;
    UIView *searchView;

    UILabel *alertLabel;
    
    UISegmentedControl *orderSegmentControl;
 
    //refers to the xib-based UiTableCellView
    UINib *cellNib;
    
    CLLocationCoordinate2D userLocation;
    
    BOOL searchWasDone;
    
    NSString *placeHolderCategName;
    
}

@property(nonatomic,retain) UINib *cellNib;


@property (nonatomic, retain) IBOutlet UISegmentedControl *orderSegmentControl;

@property(nonatomic, retain) NSArray *BusinessArray;

@property(nonatomic, retain) IBOutlet BusinessCell * tmpCell;
@property(nonatomic, retain) IBOutlet UIView *searching;
@property (nonatomic, retain) IBOutlet ListTableView *tableView;

@property (nonatomic, assign) 	int totalNumberOfPageResults;
@property (nonatomic, assign) 	int actualPageNumber;

@property (nonatomic, retain) IBOutlet UITableViewCell *moreDataCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *paggingCell;

@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UILabel *actualPageLabel;

@property (nonatomic, assign) NSInteger categoryId;
@property (nonatomic, retain) NSString *keyword;

@property (nonatomic, retain) Setting *setting;

@property (nonatomic, assign) double pLatitude;
@property (nonatomic, assign) double pLongitude;
@property (nonatomic, retain) EdirectoryUserLocation *edirectoryUserLocation;

@property (nonatomic, retain) IBOutlet UILabel *loadingLabel;
@property (nonatomic, retain) IBOutlet UILabel *loadMoreListings;

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@property (nonatomic, retain) IBOutlet UIImageView * bgView;

@property (nonatomic, retain) IBOutlet UIView *searchView;


@property (nonatomic, retain) IBOutlet UILabel *alertLabel;

@property (nonatomic) CLLocationCoordinate2D userLocation;
@property (retain, nonatomic) IBOutlet UITextField *searchTextField;
@property (retain, nonatomic) IBOutlet UILabel *lblKeywordObligation;

@property (retain, nonatomic)     NSString *placeHolderCategName;;

- (IBAction)handleOrderByMenuValueChanged:(id)sender;
- (IBAction)textSearchEditBegin:(id)sender;
- (IBAction)textfieldValueChanged:(id)sender;

@end
