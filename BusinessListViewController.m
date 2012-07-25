//
//  BusinessListViewController.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/2/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "BusinessListViewController.h"
#import "Deal.h"
#import "Utility.h"
#import "CoreUtility.h"
#import "BusinessCell.h"
#import "EdirectoryAppDelegate.h"
#import "BusinessDetailsViewController.h"
#import "SettingsManager.h"
#import "EdirectoryParserToWSSoapAdapter.h"
#import "ARCABusinesses.h"


#define kOddAlpha 0.0
#define kNormalAlpha 0.2
#define kShowCaseRowHeight	80.0
#define kNormalRowHeight	60.0
#define kCustomRowCount		4


@interface BusinessListViewController()

-(void)handleBackButton;
-(void)addWaitingAlertOverCurrentView;
- (void)updateText:(NSString *)newText;
- (void)removeAlert;
- (void) removeAllInvisibleButtons;

@property(nonatomic,retain) SettingsManager * setm;

- (void)startIconDownload:(id<ListingObjectDelegate>)listing forIndexPath:(NSIndexPath *)indexPath;
- (void)invokeParserforPage:(int)page;
@end


@implementation BusinessListViewController

@synthesize tmpCell;
@synthesize orderSegmentControl;
@synthesize BusinessArray;
@synthesize searching;
@synthesize tableView;

//For pagination pourposes
@synthesize moreDataCell;
@synthesize paggingCell;

@synthesize previousButton;
@synthesize nextButton;
@synthesize actualPageLabel;

@synthesize totalNumberOfPageResults;
@synthesize actualPageNumber;
@synthesize categoryId;
@synthesize keyword;

@synthesize setting;

@synthesize pLatitude, pLongitude;
@synthesize edirectoryUserLocation;

@synthesize loadingLabel, loadMoreListings;
@synthesize imageDownloadsInProgress;

@synthesize bgView;
@synthesize searchView;

@synthesize alertLabel;

@synthesize setm;
@synthesize cellNib;
@synthesize userLocation;
@synthesize searchTextField;
@synthesize lblKeywordObligation;

@synthesize placeHolderCategName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    
    
	//For pagination pourposes
	[moreDataCell       release];
	[paggingCell        release];
	
	[previousButton     release];
	[nextButton         release];
	[actualPageLabel    release];
    [keyword            release];
    
    [searching          release];
    [BusinessArray         release];
    [tmpCell            release];

    [setting            release];
    [edirectoryUserLocation release];
    [loadingLabel       release];
    [loadMoreListings   release];
    
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];    
    [imageDownloadsInProgress release];
    
    [bgView                 release];
    [setm                   release];
    [searchView             release];

    [orderSegmentControl    release];
    [cellNib                release];
    [alertLabel release];
    tableView.delegate = nil;
    [tableView release];
    [searchTextField release];
    [lblKeywordObligation release];
    [placeHolderCategName release];
    [super              dealloc];
}


- (void) removeAllInvisibleButtons {
    for (id buttons in self.view.subviews) {
        if ([buttons isKindOfClass:[UIButton class]]) {
            UIButton *tmp = (UIButton *) buttons;
            if (tmp.tag == 999) {
                [tmp removeFromSuperview];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void)applyTheme {
    
    
    //gets a reference to application delegate
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIColor * themeColor = [appDelegate.themeSettings createColorForTheme:THEME_DEFAULTS];

    self.nextButton.titleLabel.textColor = themeColor;
    self.previousButton.titleLabel.textColor = themeColor;   
    self.actualPageLabel.textColor = themeColor;
    self.loadMoreListings.textColor = themeColor;
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self applyTheme];
    //adds the serach view
	CGRect searchViewFrame =  CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, 320.0f, self.view.bounds.size.height);
    self.searchView.frame = searchViewFrame;
    [self.searchView setAutoresizingMask:UIViewAutoresizingNone];
    
	[self.tableView addSubview:searchView];    
    
    //INFO: Alloc settings manager
    SettingsManager *smTemp = [[SettingsManager alloc] initWithNoWhait];
    
    [self setSetm: smTemp];
    
    [smTemp release];
    
    //setup the backgroundView for this table
    [self.tableView setBackgroundView:self.bgView];
    
	self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
	//Configures the footer for this table. This footer will show the "loading" screen
	[self.tableView setTableFooterView:self.searching];
    
	//Initializes the EdirectoryUserLocation
	EdirectoryUserLocation * tmpUserLocation = [EdirectoryUserLocation alloc];
	self.edirectoryUserLocation = tmpUserLocation;
	self.edirectoryUserLocation.delegate = self;
	
	[tmpUserLocation release];
	
    [self.edirectoryUserLocation setupEdirectoryUserLocation];
    
	self.tableView.rowHeight = kNormalRowHeight;
    
	[loadingLabel setText:NSLocalizedString(@"Loading", @"")];
    [loadMoreListings setText:NSLocalizedString(@"LoadNextListings", @"")];
    
    
    self.cellNib = [UINib nibWithNibName:@"BusinessCell" bundle:nil];    
    
    [self.searchTextField setText: self.keyword];
    
    [self.lblKeywordObligation setText:NSLocalizedString(@"MustTypeKeyword", @"")];
    
    if(!isEmpty(self.placeHolderCategName)) {
        [self.searchTextField setPlaceholder:[NSString stringWithFormat:NSLocalizedString(@"SearchProductOrServicePlaceholder", @""), self.placeHolderCategName]];
    } else {
        [self.searchTextField setPlaceholder: NSLocalizedString(@"SearchProductOrService", @"")];
    }

}

- (void)viewDidUnload
{
    [self setSearchTextField:nil];
    [self setLblKeywordObligation:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    
	if ([BusinessArray count] > 0) {
		//[self.searching setHidden:YES];
		return;
	}
    
    [[[self tableView] searchTextField] setText: keyword];
	
	//shows the "loading" screen every time that loads
	//[self.searching setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //WS-SOAP access bridge    
    EdirectoryParserToWSSoapAdapter * adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];    
    [adapter cancel];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)updateText:(NSString *)newText
{
    self.alertLabel.text = newText;
}
- (void)removeAlert
{
    [self.searching removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    self.searching.alpha = 1.0;
}
-(void)addWaitingAlertOverCurrentView{
    [self.view setUserInteractionEnabled:NO];
    
    [self.view addSubview: searching];
    searching.backgroundColor = [UIColor clearColor];
    
    CGRect alertR = searching.frame;
    alertR.size.width = 180;
    [searching setFrame:alertR];
    
    CALayer *viewLayer = self.searching.layer;
    searching.center = self.view.center;
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 0.35555555;
    animation.values = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:0.6],
                        [NSNumber numberWithFloat:1.1],
                        [NSNumber numberWithFloat:.9],
                        [NSNumber numberWithFloat:1],
                        nil];
    animation.keyTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:0.6],
                          [NSNumber numberWithFloat:0.8],
                          [NSNumber numberWithFloat:1.0], 
                          nil];    
    [viewLayer addAnimation:animation forKey:@"transform.scale"];
    [self performSelector:@selector(updateText:) withObject:NSLocalizedString(@"Wait", @"") afterDelay:0.0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	if ([self.BusinessArray count]>0 && self.totalNumberOfPageResults > 1) {
		return 2;
	}else {
		return 1;
	}
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	if (section == 0) {
		return [self.BusinessArray count];
	}else if (section == 1) {
		return 1;
	}else {
		return 0;
	}
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 92.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"BusinessCell";
	
    
    UITableViewCell* returnCell = nil;
    
	if (indexPath.section == 0) {
        
		ARCABusinesses *business = [BusinessArray objectAtIndex:indexPath.row];
		

		BusinessCell *cell = (BusinessCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
		if (cell == nil) {
				//[[NSBundle mainBundle] loadNibNamed:@"BusinessCell" owner:self options:nil];
            [cellNib instantiateWithOwner:self options:nil];
                
            
			cell = tmpCell;
			self.tmpCell = nil;		
		} 
		
		/* ------------------------------------------------------------- 
		 populate the cell
		 */
		
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
                

		cell.businessTitle.text = [NSString stringWithFormat:@"%@",[business title]];
        //TODO: obter distancia da Business
        //cell.businessDistance.text = [NSString stringWithFormat:@"%0.2f", [business promotionDistance]];
        /*if([business distance] == [NSDecimalNumber notANumber]) {
            cell.businessDistance.text = @"";
        } else {
            cell.businessDistance.text = [NSString stringWithFormat: NSLocalizedString(@"XDistance", @""), [[business distance] floatValue], NSLocalizedString(@"DistancePlural", @"")];
        }*/
        cell.businessSummaryText.text = [business description];
        cell.businessAddress.text = [business address];
        cell.bgView.alpha = ((indexPath.row % 2 == 0) ? kNormalAlpha : kOddAlpha);
        //NSLog(@"A business %@ tem rate review = %0.2f", [business title], [[business avg_review] floatValue]);
        cell.rating = [[business avg_review] floatValue];
        
        
        UIView * selectedView = [[UIView alloc] initWithFrame:cell.frame];
        selectedView.backgroundColor = [UIColor colorWithRed:115.0/255.0 green:255.0/255.0 blue:138.0/255.0 alpha:0.3];        
        [cell setSelectedBackgroundView:selectedView];
        [selectedView release];
        
        
        if ( isEmpty(business.imageObject) ) {					
            [self startIconDownload:business forIndexPath:indexPath];
        }else{
            cell.businessImage = business.imageObject;
        }
        
        
		[cell applyTheme];
		returnCell = cell;
        
	} else if (indexPath.section == 1) {
		
		if (self.actualPageNumber == 1){
            
			return self.moreDataCell;
            
		}else {
			[self.nextButton setTitle:[NSString stringWithFormat:@"%@ %i", NSLocalizedString(@"Page", @"")  ,((self.actualPageNumber) +1)] forState:UIControlStateNormal];
			[self.previousButton setTitle:[NSString  stringWithFormat:@"%@ %i", NSLocalizedString(@"Page", @"") , ((self.actualPageNumber) -1)] forState:UIControlStateNormal];
			self.actualPageLabel.text = [NSString stringWithFormat:@"%@ %i %@ %i", NSLocalizedString(@"Page", @"") ,self.actualPageNumber, NSLocalizedString(@"of", @"") ,self.totalNumberOfPageResults];
			
			//determines if the next button can appear or not
			if (self.actualPageNumber ==self.totalNumberOfPageResults) {
				[self.nextButton setHidden:YES];
			}else {
				[self.nextButton setHidden:NO];
			}
            
            self.paggingCell.backgroundView.alpha = 1.0;
            self.paggingCell.backgroundColor = [UIColor whiteColor];
			returnCell = self.paggingCell;
			
		}
        
	}

    return returnCell;
	
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BusinessCell * dealsCell = (BusinessCell *)cell ;
    
	if (indexPath.section == 0) {
        dealsCell.bgView.alpha = ((indexPath.row % 2 == 0) ? kNormalAlpha : kOddAlpha);
	}	
}


- (void) handleLoadedListings:(NSArray *)loadedListings {
	[self setBusinessArray: loadedListings];
    
    [self removeAlert];
    
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark EdirectoryXMLParserDelegate Methods
-(void) parserEndWithError:(BOOL)hasErrors {
}

- (void) parserDidReceiveSearchResultsPosition:(double)latitude withLongitude:(double)longitude {
    
}

//Called by the parser when the results array was created
- (void)parserDidCreatedResultsArray:(NSArray *)objectResults{
	//receives a reference to Array from the Parser
	self.BusinessArray = objectResults;
}

//Called by the parser when the numbers for paging navigation is received
- (void)parserDidReceivePagingNumbers:(int)totalNumberOfPages wichPage:(int)actualPage{
	self.actualPageNumber = actualPage;
	self.totalNumberOfPageResults = totalNumberOfPages;
}

//Called by the parser everytime that listingResults is updated with a batch of data
- (void)parserDidUpdateData:(NSArray *)objectResults{
	//Just reloads the data beacuse the listingResults is already referenced by this class
	//[self.tableView reloadData];
}


// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(NSArray *)objectResults{
	
    
    //[self removeAlert];
    
	[self performSelectorOnMainThread:@selector(handleLoadedListings:) withObject:objectResults waitUntilDone:NO];
	//self.listings = listingResults;
	//[self.tableView reloadData];
}


// Called by the parser when no listingResults were found
- (void)noResultsWereFound{
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoResults", @"")
													message:NSLocalizedString(@"NoResultsFound", @"")
												   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	//return to the previous view
    [self.navigationController popViewControllerAnimated:YES];
    [self removeAlert];
    
}

/*
- (EdirectoryXMLParser *) edirectoryXMLParser {
	
	if (edirectoryXMLParser != nil) {
		return edirectoryXMLParser;
	}
	
	self.BusinessArray = [NSArray array];
	
	EdirectoryXMLParser * tmpParser = [[EdirectoryXMLParser alloc] initXMLParserDelegate];
	tmpParser.delegate = self;
	self.edirectoryXMLParser = tmpParser;
    [self.edirectoryXMLParser setRootElementName:@"eDirectoryData"];
	
	[tmpParser release];
	
	return edirectoryXMLParser;
	
}
*/

-(void)invokeParserforPage:(int)page{
	
	// Remove all data from table
	// and show spash wait
	self.BusinessArray = nil;
	[self.tableView reloadData];
    
	//[self.searching setHidden:NO];
    [self addWaitingAlertOverCurrentView];
	
	//manages all the images download
	NSArray *allDownloads = [self.imageDownloadsInProgress allValues];	
	[allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
	self.imageDownloadsInProgress = [NSMutableDictionary dictionary];    
    
    //WS-SOAP access bridge    
    EdirectoryParserToWSSoapAdapter * adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [adapter setDelegate:self];   
    
    NSNumber *categID = [NSNumber numberWithInteger:self.categoryId];
    NSDecimalNumber * categIDDec = [NSDecimalNumber decimalNumberWithDecimal:[categID decimalValue]];
    
    NSNumber *oderBy = [NSNumber numberWithInteger:[orderSegmentControl selectedSegmentIndex]];
    NSDecimalNumber * oderByDec = [NSDecimalNumber decimalNumberWithDecimal:[oderBy decimalValue]];
    
    NSNumber *pageNum = [NSNumber numberWithInt:page];
    NSDecimalNumber * pageDec = [NSDecimalNumber decimalNumberWithDecimal:[pageNum decimalValue]];
    
    
    NSString *nearType = @"";
	if ([[[self setting ]isNearMe] boolValue]) {
		nearType = @"nearme";
	} else {
		if (self.setting.zipCode != NULL && (![self.setting.zipCode isEqualToString:@""])  ) {
			nearType = @"zipcode";
		}else {
			//nearType = @"location";
            nearType = [NSString stringWithFormat:@"%i", [self.setting.city.city_id intValue]];
		}
	}

    [adapter getAllBusinessForKeyword:self.keyword orderBy:oderByDec categoryID:categIDDec latitude:self.pLatitude longitude:self.pLongitude page: pageDec nearbyType:nearType zipcode:self.setting.zipCode];

}


-(IBAction)gotoNextPageOfResults{
	[self invokeParserforPage:(self.actualPageNumber +1)];
}

-(IBAction)gotoPreviousPageOfResults{
	[self invokeParserforPage:(self.actualPageNumber -1)];
}


- (Setting *)setting {
	
	EdirectoryAppDelegate *thisDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.setting = [thisDelegate setting];
	return setting;
	
}

-(void)handleBackButton{

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
        
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		ARCABusinesses *business = [BusinessArray objectAtIndex:indexPath.row];
        
        
        //puts the icon image inside the business object
        

         //Declares and instantiates this application loader view
         BusinessDetailsViewController *detailViewController = [[BusinessDetailsViewController alloc]
         initWithNibName:@"BusinessDetailsViewController" bundle:nil];
        

         //Sets the title for the listingDetailViewController
         [detailViewController setTitle:NSLocalizedString(@"Details", @"")];
        
         //sets the SettingsManager object
         [detailViewController setSetm: self.setm];

         //Sets the business object
         [detailViewController setBusinessObject:business];

        
        [detailViewController setUserLocation: self.userLocation];
        
        UIBarButtonItem *browseButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"dealBarBackItemTitle", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(handleBackButton) ] autorelease];
        [[self navigationItem] setBackBarButtonItem:browseButton];
    

        
         //Pushes the ListinDetailViewController into the navigationController	
         [[self navigationController]  pushViewController:detailViewController animated:YES];
        
        [detailViewController release];
        

	} else if (indexPath.section == 1 && self.actualPageNumber == 1) {
		[self gotoNextPageOfResults];
	}
	
}

#pragma mark -
#pragma mark EdirectoryUserLocationDelegate Methods
//This is called by the eDirectoryUserLocation when a new GPS location was successfully received
-(void) didReceivedNewLocation:(CLLocationCoordinate2D)newUserLocation{
	
	self.pLatitude = newUserLocation.latitude;
	self.pLongitude = newUserLocation.longitude;
    self.userLocation = newUserLocation;
	
	NSString *url;
	
	
	//Gets the URL string from a plist file
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
    
	
	// Remove all data from table
	// and show splash wait
	self.BusinessArray = nil;
	[self.tableView reloadData];
	[self.searching setHidden:NO];

    url = [NSString stringWithFormat:
           [connPlist objectForKey:@"DealsByCategory"]
           ,@"nearme", 
           [[[self setting] zipCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
           isEmpty(self.keyword)?@"":self.keyword,
           self.pLatitude, self.pLongitude,
           self.categoryId ,0,
           self.actualPageNumber];
	
	
	//call parser
	//[[self edirectoryXMLParser] loadObjectsData:url];
	
	if ((self.categoryId) || (self.keyword)) {
		[self invokeParserforPage:1];
	}
	
	
}
//This is called by the eDirectoryUserLocation when an Error message was received
-(void) didReceiveAnErrorMessage:(NSError *)error{
    [self.searching setHidden:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//This is called by the eDirectoryUserLocation to inform a delegate that the Locations service for iPhone is disabled
-(void) locationsServiceIsNotEnable{    
    [self.searching setHidden:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//This is called by the eDirectoryUserLocation when LocationManager is still waiting to Location results after 30 secs.
-(void) didHitTheMaximumTimeIntervalWithNoResults{
    
    [self.searching setHidden:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    
	UIAlertView *maximumTimeIntervalAlert = [[UIAlertView alloc] 
                                             initWithTitle:NSLocalizedString(@"NoGPSResults", @"")
                                             message:NSLocalizedString(@"NoGPSResultsMessage", @"")
                                             delegate:nil 
                                             cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                             otherButtonTitles:nil
                                             ];
	[maximumTimeIntervalAlert show];
	[maximumTimeIntervalAlert release];
	
}

#pragma mark -
#pragma mark maked to manager download icons
- (void)startIconDownload:(id<ListingObjectDelegate>)listing forIndexPath:(NSIndexPath *)indexPath {
		
	if (indexPath.section != 0) {
		return;
	}
	
	IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
	if (iconDownloader == nil) {
		iconDownloader = [[IconDownloader alloc] init];
		iconDownloader.listing = listing;
		iconDownloader.indexPathInTableView = indexPath;
		iconDownloader.delegate = self;
		[imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
		[iconDownloader startDownload];
		[iconDownloader release];   
	}
	
}

- (void)appImageDidLoad:(NSIndexPath *)indexPath {
    NSLog(@"appImageDidLoad");
    ARCABusinesses *business = [BusinessArray objectAtIndex:indexPath.row];
    //retain the image inside the Business object
    [business setImageObject:business.listingIcon]; 
	if (business.listingIcon != nil) {
		BusinessCell *cell = (BusinessCell *)[self.tableView cellForRowAtIndexPath:indexPath];       
		cell.businessImage = business.listingIcon;
	}
    
	[self.tableView setNeedsDisplay];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}



// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.1];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
	
        if (scrollView.contentOffset.y < -90.0f) {
            self.tableView.contentInset = UIEdgeInsetsMake(90.0f, 0.0f, 0.0f, 0.0f);
        }else{
            self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);            
        }

		[UIView commitAnimations];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}


#pragma mark - TextFieldDelegate Methods
- (IBAction)textFieldFinishedEditing:(id)sender
{
	//UITextField *whichTextField = (UITextField *)sender;
	//[whichTextField resignFirstResponder];
}

// called when 'return' key pressed. 
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
	UITextField *whichTextField = (UITextField *)textField;
	[whichTextField resignFirstResponder];
    [self removeAllInvisibleButtons];
    
    NSLog(@"Texto pesquisado: %@", [whichTextField text] );
    
    if (!isEmpty([whichTextField text])) {
        self.keyword = [whichTextField text];
        [self invokeParserforPage:1];
    } else if(self.categoryId > 0) {
        self.keyword = @"";
        [self invokeParserforPage:1];
    }
    
    return NO;
}

- (IBAction)handleOrderByMenuValueChanged:(id)sender {
    [self invokeParserforPage:1];
}


- (IBAction)textfieldValueChanged:(id)sender {
    UITextField *txt = (UITextField *) sender;
    if (isEmpty(txt.text) && self.categoryId == 0) {
        [lblKeywordObligation setHidden:NO];
        [orderSegmentControl setEnabled:NO];
    } else {
        [lblKeywordObligation setHidden:YES];
        [orderSegmentControl setEnabled:YES];
    }
}

-(IBAction)handleButtonDismissKeyboard:(id)sender {
    [searchTextField resignFirstResponder];
    [self removeAllInvisibleButtons];
}

- (IBAction)textSearchEditBegin:(id)sender {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 320, 480)];
    [button setTag:999];
    [button addTarget:self action:@selector(handleButtonDismissKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
    [button release];
}

@end
