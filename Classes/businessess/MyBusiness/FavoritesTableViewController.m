//
//  FavoritesTableViewController.m
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/15/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "FavoriteBusiness.h"
#import "FavoritesCell.h"
#import "Utility.h"
#import "MyBusinessViewController.h"

#define kOddAlpha 0.0
#define kNormalAlpha 0.2

@implementation FavoritesTableViewController

@synthesize tmpCell;
@synthesize datasourceArray;
@synthesize cellNib;
@synthesize reviewParentViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

    self.cellNib = [UINib nibWithNibName:@"FavoritesCellView" bundle:nil];
}

- (void)viewDidUnload
{
    [self setTmpCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source "swipe to delete" methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //get a favorite object from our datasource array
        FavoriteBusiness * favoriteObj = [self.datasourceArray objectAtIndex:indexPath.row];
        int favoriteID = [[favoriteObj BusinessId] intValue];
        
        [[self datasourceArray] removeObjectAtIndex:indexPath.row];
        NSArray *deleteIndexPaths = [NSArray arrayWithObjects: indexPath, nil];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
        
        //delete favorite using CoreData
        [Utility deleteFavoriteBusiness:favoriteID];
        
    }
    
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"willBeginEditingRowAtIndexPath");
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didEndEditingRowAtIndexPath");
}

#pragma mark - Table view data source "usual" delete methods
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [datasourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoriteCell";
    
    UITableViewCell* returnCell = nil;
    
	if (indexPath.section == 0) {
        
		FavoriteBusiness *favorite = [datasourceArray objectAtIndex:indexPath.row];
		
        
		FavoritesCell *cell = (FavoritesCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
		if (cell == nil) {
            [cellNib instantiateWithOwner:self options:nil];
			cell = tmpCell;
			self.tmpCell = nil;		
		} 
        
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setDateFormat:NSLocalizedString(@"dateFormat", @"")];

        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        cell.bgView.alpha = ((indexPath.row % 2 == 0) ? kNormalAlpha : kOddAlpha);        
        
        [[cell businessTitle] setText: [favorite Title] ];
        [[cell favoriteDate] setText: [df stringFromDate: [favorite DateRecorded] ] ];
        [cell applyTheme];
        
        UIView * selectedView = [[UIView alloc] initWithFrame:cell.frame];
        selectedView.backgroundColor = [UIColor colorWithRed:115.0/255.0 green:255.0/255.0 blue:138.0/255.0 alpha:0.3];        
        [cell setSelectedBackgroundView:selectedView];
        [selectedView release];
        
        [df release];
        
        returnCell = cell;
    }
    
    
    return returnCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    FavoriteBusiness * businessObject = (FavoriteBusiness *)[self.datasourceArray objectAtIndex:indexPath.row];    
    MyBusinessViewController * parent = (MyBusinessViewController *) self.reviewParentViewController;
    [parent proceedWithBusinessDetails:businessObject];

}

- (void)dealloc {
    [tmpCell release];
    [datasourceArray release];
    [cellNib release];
    [super dealloc];
}
@end
