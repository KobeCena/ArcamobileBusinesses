//
//  ArcaMobileDealsViewController.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 5/12/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EdirectoryXMLParser.h"
#import "EdirectoryUserLocation.h"
#import "MapViewController.h"
#import "Utility.h"
#import "iCarousel.h"
#import "RpCacheController.h"

@interface BusinessNearbyViewController : UIViewController <EdirectoryXMLParserDelegate, EdirectoryUserLocationDelegate, iCarouselDataSource, iCarouselDelegate, RpCacheControllerDelegate> {
    
    EdirectoryXMLParser *edirectoryXMLParser;
    MapViewController *mapViewController;
    
    BOOL isCancelled;
    
    UILabel * resultsLabel;
    UIButton * resultsButton;
    
    NSArray *objectsDatasource;
    
    //for location pourposes
	EdirectoryUserLocation *edirectoryUserLocation;
    
    CLLocationCoordinate2D userLocation;
    
	Setting *setting;    
    UILabel *topMessageLabel;
    UILabel *businessNameLabel;
    UILabel *businessDistanceLabel;
    UILabel *businessAddressLabel;

    UILabel *dealMapMesageLabel;
    UIView *alertView;
    UILabel *alertLabel;
    UILabel *businessDescriptionTextView;
    
    //for controlling the refresh operation
    NSString *operation;
    
    //for access the cache
    RpCacheController * cacheController;
    NSMutableDictionary* carousselDatasourceItems;
}

@property (nonatomic, retain) IBOutlet iCarousel *carousel;
@property (nonatomic, retain) NSMutableDictionary* carousselDatasourceItems;
@property (nonatomic, retain) EdirectoryXMLParser *edirectoryXMLParser;
@property (nonatomic, retain) IBOutlet MapViewController *mapViewController;
@property (nonatomic, retain) IBOutlet UILabel * resultsLabel;
@property (nonatomic, retain) IBOutlet UIButton * resultsButton;
@property (nonatomic, retain) NSArray *objectsDatasource;
@property (nonatomic, retain) EdirectoryUserLocation *edirectoryUserLocation;
@property (nonatomic, readonly) CLLocationCoordinate2D userLocation;
@property (nonatomic, retain) Setting *setting;
@property (nonatomic, retain) NSString *operation;

@property (nonatomic, retain) IBOutlet UILabel *topMessageLabel;
@property (nonatomic, retain) IBOutlet UILabel *businessNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *businessDistanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *businessAddressLabel;
@property (nonatomic, retain) IBOutlet UILabel *dealMapMesageLabel;
@property (nonatomic, retain) IBOutlet UIView *alertView;
@property (nonatomic, retain) IBOutlet UILabel *alertLabel;
@property (nonatomic, retain) IBOutlet UILabel *businessDescriptionTextView;

@property (retain, nonatomic) IBOutlet UILabel *lblNoNearbyTip;

@property (nonatomic, retain) RpCacheController * cacheController;



#pragma mark - Button Methods
-(IBAction) handleButtonClick:(id)sender;
-(IBAction) handleBodyButton:(id)sender;
-(void)cancelNearbyDeals;
#pragma mark - "Refresh" Navigation Button method
-(IBAction)reloadNearbyDealsFromServer;

@end
