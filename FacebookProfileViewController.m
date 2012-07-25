//
//  DirectoryProfileViewController.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 05/11/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "FacebookProfileViewController.h"

@implementation FacebookProfileViewController

@synthesize isViewPushed;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	loginData = [[LoginData alloc] init];
	//self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancel_Clicked:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancel_Clicked:)] autorelease];

}

-(void) cancel_Clicked:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
	
	NSLog(@"USER ID: %@",  [[loginData facebookProfile] profileID]);
	
    if (indexPath.row == 0) {
		cell.textLabel.text = NSLocalizedString(@"UserName", nil);
		cell.detailTextLabel.text = [[loginData facebookProfile] userName];
	} else if (indexPath.row == 1) {
		cell.textLabel.text = NSLocalizedString(@"Name", nil);
		cell.detailTextLabel.text = [[loginData facebookProfile] name];
	} else if (indexPath.row == 2) {
		cell.textLabel.text = NSLocalizedString(@"Email", nil) ;
		cell.detailTextLabel.text = [[loginData facebookProfile] email];
	} else if (indexPath.row == 3) {
		cell.textLabel.text = NSLocalizedString(@"Location", nil);
		cell.detailTextLabel.text = [[loginData facebookProfile] location];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedString(@"FacebookAccountDetails", nil);
}

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
    [super dealloc];
}

@end