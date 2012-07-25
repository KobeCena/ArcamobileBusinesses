//
//  PushCategoriesViewController.m
//  ArcaMobileDeals
//
//  Created by Rafael Gustavo Gali on 06/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PushCategoriesViewController.h"



@implementation PushCategoriesViewController

@synthesize categoriesTableView;
@synthesize edirectoryXMLParser;
@synthesize xmlOperation;
@synthesize dashBoardItems;
@synthesize dictCategories;
@synthesize delegate;


#define KOPerationDasboard @"DashBoard"


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [delegate release];
    [dictCategories release];
    [edirectoryXMLParser    release];
    [dashBoardItems         release];
    [xmlOperation           release];

    [categoriesTableView release];
    [super dealloc];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dashBoardItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    Category *ct = (Category*)[self.dashBoardItems objectAtIndex:[indexPath row]];
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:16.0f]];
    
    NSString *str = [[ct label] stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
    
    [cell.textLabel setText:str];
    
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(206, 8, 94, 27)];
        
//    BOOL b = [[dictCategories objectForKey:[ct categoryID]] boolValue];
    
    NSString *objValue = [dictCategories objectForKey: [NSString stringWithFormat:@"%i", [[ct categoryID] integerValue]]];
    
//    NSLog(@"objValue: %@", objValue);
    
    [s setOn:[objValue boolValue]];

    [s addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
    [s setTag: [[ct categoryID] intValue]];
    
    [cell addSubview:s];
    
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    
    return cell;
}

-(void)switchPressed:(id)sender {
    
    UISwitch *s = (UISwitch *)sender;
    
    NSLog(@"switch pressed: %i", [s tag]);
    
    [dictCategories setValue: [s isOn] ? @"YES" : @"NO"  forKey: [NSString stringWithFormat:@"%i", [s tag]]];
    
//    [Utility writeMutableDictionaryToPlist:dictCategories withName:@"dictCategories.plist"];
    
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
    
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)] autorelease];

    
    
	//Initializes the parser
	EdirectoryXMLParser * tmpParser = [[EdirectoryXMLParser alloc] initXMLParserDelegate];
	//tmpParser.delegate = self;
	self.edirectoryXMLParser = tmpParser;
	self.edirectoryXMLParser.delegate = self;
    [self.edirectoryXMLParser setRootElementName:@"eDirectoryData"];
	
	[tmpParser release];
	
	
    
    
    
	//Gets the URL string from a plist file
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
    
    
    BOOL b1 = [RpCacheController cacheisExpired];
    BOOL b2 = [RpCacheController fileExistInCache:[[connPlist objectForKey:@"DealDashboard"] lastPathComponent]] ;
    
    //call RpCacheController to see if we need request the dashboard items from server
    if ( b1 || !(b2) ) {
        //sets the operation DASHBOARD for parser
        self.xmlOperation = KOPerationDasboard;
        [self.edirectoryXMLParser loadObjectsData:[connPlist objectForKey:@"DealDashboard"]];
    }else{
        
        if (b2) {
            //There's a cached copy for the dashboard XML structure. So, load it.
            
            //sets the operation DASHBOARD for parser
            self.xmlOperation = KOPerationDasboard;
            [self.edirectoryXMLParser loadObjectsDataFromDisk:[[connPlist objectForKey:@"DealDashboard"] lastPathComponent]];
        }
    }
    
    
    
    
    
    
}


//Called by the parser everytime that listingResults is updated with a bunch of data
- (void)parserDidUpdateData:(NSArray *)objectResults{
    
    self.dashBoardItems = objectResults;

    NSLog(@"parserDidUpdateData: %i", [objectResults count]);
    
}

// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(NSArray *)objectResults{
    
	
//        [self.dashboard reloadData];
//        [self.dashboardLock setHidden:YES];
    NSLog(@"parserDidEndParsingData: %i", [objectResults count]);
	
    [self setDashBoardItems:objectResults];
    
    
    [self syncResultsWithPlist];
    
    [categoriesTableView reloadData];
    
}

-(void)syncResultsWithPlist {
    
    dictCategories = [CoreUtility loadPlistToDictionaryWithName:@"dictCategories.plist"];
    
    BOOL createdPlist = NO;
    
    if (dictCategories == nil) {
        dictCategories = [[NSMutableDictionary alloc] init];
        createdPlist = YES;
    }

    
    for (int i = 0; i < [dashBoardItems count]; i++) {
        
        Category *ct = (Category*)[self.dashBoardItems objectAtIndex:i];
        
        BOOL containsKey = ([dictCategories objectForKey: [NSString stringWithFormat:@"%i",  [[ct categoryID] integerValue]]] != nil);
        
        if (createdPlist) {
            [dictCategories setValue:@"YES" forKey: [NSString stringWithFormat:@"%i", [[ct categoryID] integerValue]]];
        } else
        
        if (!containsKey) {
            [dictCategories setValue:@"NO" forKey: [NSString stringWithFormat:@"%i", [[ct categoryID] integerValue]]];
        }
        
    }

}

- (void)parserDidReceivedRawData:(NSData *)data{
    
    /*
    NSLog(@"parserDidReceivedRawData");
    
	//Gets the URL string from a plist file
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSString *name = [[connPlist objectForKey:@"DealDashboard"] lastPathComponent];
    
    //writes the rawfile into cache
    RpCacheController* cacheController = [[RpCacheController alloc] initForCheck];
    [cacheController writeDataIntoCache:data withName:name];
    [cacheController release];*/
    
}


- (void)viewDidUnload
{
    [self setCategoriesTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)doneButtonClicked:(id)sender {
    
    [CoreUtility writeMutableDictionaryToPlist:dictCategories withName:@"dictCategories.plist"];
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"%@[SELF] == 'YES'",dictCategories];
    NSArray *keys = [dictCategories allKeys];
    NSArray *filteredKeys = [keys filteredArrayUsingPredicate:p];
    NSDictionary *matchingDictionary = [dictCategories dictionaryWithValuesForKeys:filteredKeys];
    
//    [Utility writeDictionaryToPlist:matchingDictionary];
    
    if ([matchingDictionary count] > 0) {
        
        NSMutableString *catParam = [[NSMutableString alloc] init];
        
        NSArray *allKeys = [matchingDictionary allKeys];

        
        for (int i = 0; i < [allKeys count]; i++) {
            
            [catParam appendFormat:@"cat%i=%i&", i, [[allKeys objectAtIndex:i] integerValue]];
            
            NSLog(@"%@", catParam);
        }
        
//        [catParam stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&"]];
        
        [delegate pushCategoriesDoneWithCount:[matchingDictionary count] andOptions:catParam];
        
        [catParam release];
        
        
    } else {
        
        [delegate pushCategoriesDoneWithCount:0 andOptions:nil];
        
    }
    
    
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

@end
