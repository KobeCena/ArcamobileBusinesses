//
//  ProductsAllReviewsViewController.h
//  ArcaMobileBusinesses
//
//  Created by GiJoe on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReviewCell.h"
#import "IconDownloader.h"
#import "EdirectoryParserToWSSoapAdapter.h"

@interface BusinessAllReviewsViewController : UIViewController <UIScrollViewDelegate, IconDownloaderDelegate, EdirectoryXMLParserDelegate> {
    
    UITableView *tableReviews;
    NSMutableArray *arrReviews;
    ReviewCell *tmpCell;
    
    NSString *itemType;
    NSNumber *itemID;
    
    NSString *foursquare_id;
    
    unsigned actualPageNumber;
    unsigned totalNumberOfPageResults;
    
    NSMutableDictionary *imageDownloadsInProgress;
    
    EdirectoryParserToWSSoapAdapter *_adapter;
    
    
	//For pagination pourposes
	UITableViewCell *moreDataCell;
	UITableViewCell *paggingCell;
    
    //refers to the xib-based UiTableCellView
    UINib *cellNib;
}

@property (nonatomic,retain) EdirectoryParserToWSSoapAdapter *adapter;

@property (nonatomic, retain) IBOutlet UITableView *tableReviews;
@property (nonatomic, retain) NSMutableArray *arrReviews;
@property (nonatomic, retain) ReviewCell *tmpCell;


@property (nonatomic, retain) NSString *itemType;
@property (nonatomic, retain) NSNumber *itemID;
@property (nonatomic, retain) NSString *foursquare_id;

@property (nonatomic) unsigned actualPageNumber;
@property (nonatomic) unsigned totalNumberOfPageResults;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (retain, nonatomic) IBOutlet UIView *searching;
@property (retain, nonatomic) IBOutlet UILabel *alertLabel;

@property (nonatomic, retain) IBOutlet UITableViewCell *moreDataCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *paggingCell;

@property (nonatomic, retain) UINib *cellNib;
@property (retain, nonatomic) IBOutlet UILabel *lblLoadMore;

- (void) refreshTableData;

@end
