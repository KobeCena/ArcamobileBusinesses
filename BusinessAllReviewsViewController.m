//
//  ProductsAllReviewsViewController.m
//  ArcaMobileBusinesses
//
//  Created by GiJoe on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BusinessAllReviewsViewController.h"
#import "ARCAReview.h"
#import "ReviewCell.h"
#import "ReviewDetailViewController.h"
#import "SettingsManager.h"
#import "Listing.h"

@interface BusinessAllReviewsViewController()

-(void)handleBackButton;
-(void)addWaitingAlertOverCurrentView;
- (void)updateText:(NSString *)newText;
- (void)removeAlert;

@property(nonatomic,retain) SettingsManager * setm;

- (void)startIconDownload:(id<ListingObjectDelegate>)listing forIndexPath:(NSIndexPath *)indexPath;
- (void)invokeParserforPage:(int)page;

@end

@implementation BusinessAllReviewsViewController

@synthesize tableReviews;
@synthesize arrReviews;
@synthesize tmpCell;
@synthesize itemType;
@synthesize itemID;
@synthesize setm;
@synthesize adapter = _adapter;
@synthesize actualPageNumber;
@synthesize totalNumberOfPageResults;
@synthesize imageDownloadsInProgress;
@synthesize searching;
@synthesize alertLabel;
@synthesize paggingCell;
@synthesize moreDataCell;
@synthesize cellNib;
@synthesize lblLoadMore;
@synthesize foursquare_id;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle: NSLocalizedString(@"Reviews", @"")];
    
    self.arrReviews = [[NSMutableArray alloc] initWithArray:nil];
    self.cellNib = [UINib nibWithNibName:@"ReviewCell" bundle:nil];
    
    [self.lblLoadMore setText:NSLocalizedString(@"LoadMore", nil)];
    
    [self invokeParserforPage:1];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setSearching:nil];
    [self setAlertLabel:nil];
    [self setLblLoadMore:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [tableReviews release];
    [arrReviews release];
    [tmpCell release];
    [itemType release];
    [itemID release];
    
    [cellNib release];
    
    [searching release];
    [alertLabel release];
    [lblLoadMore release];
    [foursquare_id release];
    [super dealloc];
}


- (void) handleLoadedReviews:(NSArray *)loadedReviews {
    for (id elem in loadedReviews) {
        [self.arrReviews addObject:elem];
    }
	[self setArrReviews:(NSMutableArray *) self.arrReviews];
    [self removeAlert];
	[self.tableReviews reloadData];
}

#pragma mark - Table Delegate
- (void) refreshTableData {
    [tableReviews reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([self.arrReviews count]>0 && self.totalNumberOfPageResults > 1 && self.actualPageNumber < self.totalNumberOfPageResults) {
		return 2;
	}else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [arrReviews count];
    } else {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 92.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"ReviewCell";
	
    
    UITableViewCell* returnCell = nil;
    
	if (indexPath.section == 0) {
        
		ARCAReview *reviewObject = [arrReviews objectAtIndex:indexPath.row];
		
		ReviewCell *cell = (ReviewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
		if (cell == nil) {[cellNib instantiateWithOwner:self options:nil];
            
            
			cell = tmpCell;
			self.tmpCell = nil;		
		} 
		
		/* ------------------------------------------------------------- 
		 populate the cell
		 */
        
        
        //Creates the formatter for the date        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: NSLocalizedString(@"dateFormat", nil) ];
        
        
        cell.rating = [[reviewObject rating] floatValue];
        cell.reviewerName.text = [reviewObject reviewer_name];
        cell.reviewDate.text = [dateFormatter stringFromDate: [reviewObject added] ] ;
        cell.reviewText.text = [reviewObject review];
        cell.reviewImageURL = [reviewObject galleryImage];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        
        
        [dateFormatter release];
		returnCell = cell;
        
	} else if (indexPath.section == 1) {
        
        returnCell = self.moreDataCell;
        
	}
    UIView * selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 92)];
    selectedView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.3];        
    [returnCell setSelectedBackgroundView:selectedView];
    [selectedView release];
    
    return returnCell;
	
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        ReviewCell * reviewCell = (ReviewCell *)cell ;
        UIColor *oddColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:((indexPath.row % 2 == 0) ? 0.2f : 0.0f)];
        [[reviewCell bgView] setBackgroundColor: oddColor];
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
        ARCAReview *review = [arrReviews objectAtIndex: indexPath.row];
        ReviewDetailViewController *reviewDetail = [[ReviewDetailViewController alloc] initWithNibName:@"ReviewDetailViewController" bundle:nil];
        [reviewDetail setReviewObject: review];
        [self.navigationController pushViewController:reviewDetail animated:YES];
        [reviewDetail release];
        
    } else if (indexPath.section == 1) {
        [self gotoNextPageOfResults];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}








-(void)invokeParserforPage:(int)page{
	
	// Remove all data from table
	// and show spash wait
	//self.arrReviews = nil;
	[self.tableReviews reloadData];
    
	//[self.searching setHidden:NO];
    [self addWaitingAlertOverCurrentView];
	
	//manages all the images download
	NSArray *allDownloads = [self.imageDownloadsInProgress allValues];	
	[allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
	self.imageDownloadsInProgress = [NSMutableDictionary dictionary];    
    
    //WS-SOAP access bridge    
    if ([self adapter] == nil) {
        EdirectoryParserToWSSoapAdapter * tempAdapter = [[EdirectoryParserToWSSoapAdapter alloc] init];
        [self setAdapter:tempAdapter];
        [tempAdapter release];
    }
    
    [[self adapter] setDelegate:self];
    
    
    NSDecimalNumber * itemIdDec = [NSDecimalNumber decimalNumberWithDecimal:[itemID decimalValue]];
    
    NSNumber *pageNum = [NSNumber numberWithInt:page];
    NSDecimalNumber * pageDec = [NSDecimalNumber decimalNumberWithDecimal:[pageNum decimalValue]];
    
    [[self adapter] getReviews:@"" businessID:itemIdDec foursquare_id:self.foursquare_id module:self.itemType page:pageDec];
    
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
	//self.arrReviews = (NSMutableArray *) objectResults;
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
    
	[self performSelectorOnMainThread:@selector(handleLoadedReviews:) withObject:objectResults waitUntilDone:NO];
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


-(IBAction)gotoNextPageOfResults{
	[self invokeParserforPage:(self.actualPageNumber +1)];
}

-(IBAction)gotoPreviousPageOfResults{
	[self invokeParserforPage:(self.actualPageNumber -1)];
}

@end
