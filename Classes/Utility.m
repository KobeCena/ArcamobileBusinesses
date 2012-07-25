//
//  Utility.m
//  JuridGen
//
//  Created by Ricardo Silva on 12/13/10.
//  Copyright 2010 Arca Solutions Inc. All rights reserved.
// nncsdsd

#import "Utility.h"
#import <CommonCrypto/CommonDigest.h>
#import "FavoriteBusiness.h"
#import "EdirectoryAppDelegate.h"
#import "Deal.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "ARCAserver_businesses.h"
#import "EdirectoryParserToWSSoapAdapter.h"
#import "PushBusinesses.h"


#import "ARCAZipLocationSearchOptions.h"
#import "ARCAMyLocationSearchOptions.h"
#import "ARCALocalLocationSearchOptions.h"

@implementation Utility


static NSString * const cRateAvgElementName = @"rateAvg";


#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]


//Constants defined to send notifications about deals
NSString *const DEALS_FINISHED = @"DealsFinished";
NSString *const DEALS_FINISHED_NO_RESULTS = @"DealsFinishedWithNoResults";
NSString *const DEALS_CANCELED = @"DealsCanceled";
NSString *const PIN_SELECTED = @"PinSelected";

NSString *const DEALS_HISTORY_OPERATION1 = @"operation1";
NSString *const DEALS_HISTORY_OPERATION2 = @"operation2";
NSString *const DEALS_HISTORY_OPERATION3 = @"operation3";

NSString *const DEALS_NEARBY_OPERATION1 = @"nearby";
NSString *const DEALS_NEARBY_OPERATION2 = @"refresh";


#pragma mark - DELETE operation for a ReviewsPosted
+ (void) deleteReviewsPosted:(int) ReviewsPostedID {
	
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReviewsPosted" inManagedObjectContext:context];
	
	[fetchRequest setEntity:entity];
	
	
	//Configures the NSPredicate for this query and sets it to NSFetchRequest
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(ReviewPostID == %@)", [NSNumber numberWithInt:ReviewsPostedID]];
	[fetchRequest setPredicate:pred];
	
	NSError *error;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	NSEnumerator *enums = [items objectEnumerator];
	
	id object;
	while (object = [enums nextObject]) {
		NSLog(@"Objeto encontrado: %@ - %@ - Será realizado DELETE", [object valueForKey:@"id"], [object valueForKey:@"nome"]);			
		//delete all objects that match the criteria
		[context deleteObject:object];
	}
	
	[fetchRequest release];
	[context save:nil];
	
}



#pragma mark - DELETE operation for a FavoriteBusiness
+ (void) deleteFavoriteBusiness:(int) favoriteBusinessID {
	
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FavoriteBusiness" inManagedObjectContext:context];
	
	[fetchRequest setEntity:entity];
	
	
	//Configures the NSPredicate for this query and sets it to NSFetchRequest
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(BusinessId == %@)", [NSNumber numberWithInt:favoriteBusinessID]];
	[fetchRequest setPredicate:pred];
	
	NSError *error;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	NSEnumerator *enums = [items objectEnumerator];
	
	id object;
	while (object = [enums nextObject]) {
		NSLog(@"Objeto encontrado: %@ - %@ - Será realizado DELETE", [object valueForKey:@"BusinessId"], [object valueForKey:@"Title"]);			
		//delete all objects that match the criteria
		[context deleteObject:object];
	}
	
	[fetchRequest release];
	[context save:nil];
	
}

#pragma mark - READ operation for a ReviewsPosted
+ (ReviewsPosted *) getReviewsPostedById:(NSNumber *) ReviewPostID{
	
	ReviewsPosted *reviewsPosted = nil;
	
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ReviewsPosted" inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:entityDesc];
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(ReviewPostID = %i)", [ReviewPostID intValue]];
	
	[request setPredicate:pred];
	
	NSError *error;
	
	NSArray *objects = [context executeFetchRequest:request error:&error];
	
	if ([objects count] == 0) {
		NSLog(@"Não encontrado!!");
	} else {
		NSLog(@"Array %i", [objects count] );
		reviewsPosted = [objects objectAtIndex:0];
	}
	[request release];
	
	return reviewsPosted;
}

#pragma mark - READ operation for all FavoriteBusiness

+ (NSArray *) getAllFavoriteBusiness{
	
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FavoriteBusiness" inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:entityDesc];
	
	//NSPredicate *pred = [NSPredicate predicateWithFormat:@"(BusinessId = %i)", [promotionID intValue]];
	//[request setPredicate:pred];
	
	NSError *error;
	
	NSArray *objects = [context executeFetchRequest:request error:&error];
	
	if ([objects count] == 0) {
		NSLog(@"Não encontrado!!");
	} else {
		NSLog(@"Array %i", [objects count] );
	}
	[request release];
	
	return objects;
}

#pragma mark - READ operation for a specific FavoriteBusiness
+ (FavoriteBusiness *) getFavoriteBusinessById:(NSNumber *) promotionID{
	
	FavoriteBusiness *favoriteBusiness = nil;
	
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FavoriteBusiness" inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:entityDesc];
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(BusinessId = %i)", [promotionID intValue]];
	
	[request setPredicate:pred];
	
	NSError *error;
	
	NSArray *objects = [context executeFetchRequest:request error:&error];
	
	if ([objects count] == 0) {
		NSLog(@"Não encontrado!!");
	} else {
		NSLog(@"Array %i", [objects count] );
		favoriteBusiness = [objects objectAtIndex:0];
	}
	[request release];
	
	return favoriteBusiness;
}

#pragma mark - INSERT operation for a GrabeedDeals
+ (FavoriteBusiness *) saveFavoriteBusiness:(ARCABusinesses *) favoriteBusiness{
    
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    
    
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	[context lock];
	
	NSManagedObject *newFavoriteBusiness = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteBusiness" inManagedObjectContext:context];
	
	//configuring the values for this new object
	[newFavoriteBusiness setValue:[favoriteBusiness _id]    forKey:@"BusinessId"];
	[newFavoriteBusiness setValue:[favoriteBusiness title]  forKey:@"Title"];
	[newFavoriteBusiness setValue:[NSDate date]             forKey:@"DateRecorded"];    
    
	[context save:&error];	
	[context unlock];
    
    return [self getFavoriteBusinessById:[NSNumber numberWithInt: [[favoriteBusiness _id] intValue] ]];
    
}

#pragma mark - INSERT operation for a ReviewsPosted
+ (ReviewsPosted *) saveReviewsPosted:(int) reviewNote forBusinessID:(int) businessID{
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	[context lock];
	
	NSManagedObject *newReviewsPosted = [NSEntityDescription insertNewObjectForEntityForName:@"ReviewsPosted" inManagedObjectContext:context];
	
	//configuring the values for this new object
	[newReviewsPosted setValue:[NSNumber numberWithInt:reviewNote]  forKey:@"ReviewNote"];
    [newReviewsPosted setValue:[NSNumber numberWithInt:businessID]  forKey:@"BusinessID"];
    [newReviewsPosted setValue:[NSDate date]                        forKey:@"DateRecorded"];
    
	[context save:&error];	
	[context unlock];
    
    return [ self getReviewsPostedById:[NSNumber numberWithInt:businessID] ];
    
}

#pragma mark - Queries all unused deals
+(NSArray *)getAllUnusedDeals{
    
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"GrabeedDeals" inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:entityDesc];
	
    NSDate *actualDate = [NSDate date];
    
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(promotionEnd >= %@)", actualDate];
	
	[request setPredicate:pred];
	
	NSError *error;
	
	NSArray *objects = [context executeFetchRequest:request error:&error];
	
	if ([objects count] == 0) {
		NSLog(@"Não encontrado!!");
	} else {
		NSLog(@"Foram Encontrados %i objetos", [objects count] );
	}
	[request release];
    
    return objects;
    
}

+(void)presentEmailComposer:(UIViewController *)viewController whithSubject:(NSString *) subjectStr withBody:(NSString *) bodyStr{
	
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = viewController;
	
    
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	[picker setSubject: [NSString stringWithFormat:@" %@ %@ ", [[appDelegate setm] defaultTagline]?[[appDelegate setm] defaultTagline]:@"", subjectStr]];
	
    
	// Set up recipients
//	NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
//	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
//	NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
//	
//	[picker setToRecipients:toRecipients];
//	[picker setCcRecipients:ccRecipients];	
//	[picker setBccRecipients:bccRecipients];
	
	// Attach an image to the email
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
//    NSData *myData = [NSData dataWithContentsOfFile:path];
//	[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
	
	// Fill out the email body text
//	NSString *emailBody = @"It is raining in sunny California!";
	[picker setMessageBody:bodyStr isHTML:NO];
	
	[viewController presentModalViewController:picker animated:YES];
    [picker release];
    
}

+(void)launchMailAppOnDevice:(NSString *) subjectStr
{

    EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    NSString *recipients = [NSString stringWithFormat:@"subject= %@ %@", [[appDelegate setm] defaultTagline], subjectStr ];

	NSString *email = [NSString stringWithFormat:@"%@", recipients];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


+(void)callServerForRegisterInstallation:(NSString *) uniqueID{
    
    RecordInstall * recordInstall = [[[RecordInstall alloc] init] autorelease];    
    [recordInstall callServerAndRegisterInstallation:uniqueID];
    
    
}

+(BOOL) verifyFirstRun{

	BOOL isFirstRun = NO;
	
    //gets a reference to application delegate
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	/* BEGIN SECTION: copy plist file to documents directory if it doesn't exists */
	NSString *storePath = [[appDelegate applicationDocumentsDirectory] stringByAppendingPathComponent: @"InstallationRecord.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:storePath]) {
        //file doesn't exist, so it's the first run
        isFirstRun = YES;
        [self registerInstallationRecord];
        
    }else{
        
        //Gets the plist content
        NSMutableDictionary*lastDict = [[NSMutableDictionary alloc] initWithContentsOfFile:storePath]; 
        
        for (NSString * currentkey in [lastDict objectForKey:@"RECORDS"]) {
            
            if ([currentkey isEqualToString:@"FIRST_RUN"]) {
                isFirstRun = [[ [lastDict objectForKey:@"RECORDS"] objectForKey:currentkey]  boolValue];
            }
        }
        
        if (isFirstRun) {
            [[lastDict objectForKey:@"RECORDS"] setObject:[NSNumber numberWithBool:NO] forKey:@"FIRST_RUN"];
        }
        
        //writes plist into disk (app documents folder)
        [lastDict writeToFile:storePath atomically: NO]; 	
        
        //releases the object
        [lastDict release];
        
    }
    
    
    return isFirstRun;
    
}

+ (NSString *)stringUniqueID {
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    result = [NSString stringWithFormat:@"%@", uuidStr];
    assert(result != nil);
    NSLog(@"UNIQUE ID %@", result);
    CFRelease(uuidStr);
    CFRelease(uuid);
    return result;
}


+(void) registerInstallationRecord{
    
	BOOL isAlreadyRecorded = NO;
	
    //gets a reference to application delegate
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	/* BEGIN SECTION: copy plist file to documents directory if it doesn't exists */
	NSString *storePath = [[appDelegate applicationDocumentsDirectory] stringByAppendingPathComponent: @"InstallationRecord.plist"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"InstallationRecord" ofType:@"plist"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	/* END SECTION */
	
	
	//Gets the plist content
	NSMutableDictionary*lastDict = [[NSMutableDictionary alloc] initWithContentsOfFile:storePath]; 
	
	for (NSString * currentkey in [lastDict objectForKey:@"RECORDS"]) {

        if ([currentkey isEqualToString:@"INSTALL"]) {
            isAlreadyRecorded = [[lastDict objectForKey:currentkey]  boolValue];
            NSLog(@"isAlreadyRecorded: %@", [[lastDict objectForKey:currentkey]  boolValue]);
            NSLog(@"isAlreadyRecorded: %@", [lastDict objectForKey:currentkey]);            
            NSLog(@"isAlreadyRecorded: %i", [[lastDict objectForKey:currentkey] intValue]);                        
        }
		
	}
	
	if ( ! isAlreadyRecorded) {
        
            //records the new rows of information into plist dictionary
            [[lastDict objectForKey:@"RECORDS"] setObject:[NSNumber numberWithBool:YES] forKey:@"INSTALL"];
            [[lastDict objectForKey:@"RECORDS"] setObject:[NSDate date] forKey:@"INSTALL_DATE"];
            NSString * uniqueID = [self stringUniqueID];
            [[lastDict objectForKey:@"RECORDS"] setObject:uniqueID forKey:@"UNIQUE_ID"];
        
        [self callServerForRegisterInstallation:uniqueID];
	}	
    
	//writes plist into disk (app documents folder)
	[lastDict writeToFile:storePath atomically: NO]; 	
	
	//releases the object
	[lastDict release];	
}


+ (void)showAnAlertMessage:(NSString *)i18NMessageKey withTitle:(NSString *) i18NTitleKey{
	NSLog(@"%@", NSLocalizedString(@"i18NKeyString", @"Title for alert displayed when download or parse error occurs.") );
	
    UIAlertView *alertErrorView = [[UIAlertView alloc] 
								   initWithTitle:NSLocalizedString(i18NTitleKey, @"Title for alert displayed when download or parse error occurs.") 
								   message:NSLocalizedString(i18NMessageKey, @"Message body for this alert view") 
								   delegate:nil
								   cancelButtonTitle:NSLocalizedString(@"OK", @"")
								   otherButtonTitles:nil
								   ];
	
    [alertErrorView show];
    [alertErrorView release];
}


// Handle the response from addToStatistic.

+ (void) addToStatisticHandler: (BOOL) value {
	// Do something with the BOOL result
	NSLog(@"addToStatistic returned the value: %@", [NSNumber numberWithBool:value]);
}

+ (void) proceedWithStatistics:(NSString *)item businessID:(NSDecimalNumber *) businessID foursquare_id:(NSString*)foursquare_id{
    //notifies server that user has favorited this business for statistics pourposes
    ARCAserver_businesses* service = [ARCAserver_businesses service];
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [service setHeaders:[adapter getDomainToken]];
    service.logging = NO;
    
    [service addToStatistic:self action:@selector(addToStatisticHandler:) businesses_id:businessID item:item];
    
    
}

+ (id)getLocationSearchOptionsObject:(int)page keyword:(NSString *)keyword order:(int)order categoryId:(int)categoryId zipCode:(NSString *)zipcode latitude:(float)latitude longitude:(float)longitude{
    
    
	EdirectoryAppDelegate *thisDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	Setting *setting = [thisDelegate setting];
    
    NSString *orderBy;

    switch (order) {
        case 0:
            orderBy = @"rating";
            break;
        case 1:
            orderBy = @"distance";
            break;
        case 2:
            orderBy = @"title";
            break;
                
        default:
            break;
    }
    
    id result;
    
	if ([[setting isNearMe] boolValue]) {
        //this is a nearme location
        ARCAMyLocationSearchOptions *nearmeLocationOptions = [[ARCAMyLocationSearchOptions alloc] init];
        
        [nearmeLocationOptions setRange:[NSDecimalNumber decimalNumberWithDecimal: [setting.distance decimalValue] ] ];
        [nearmeLocationOptions setPage:[NSDecimalNumber decimalNumberWithDecimal: [[NSNumber numberWithInt:page] decimalValue] ] ];
        [nearmeLocationOptions setOrder:orderBy];
        [nearmeLocationOptions setCategoryID:[NSDecimalNumber decimalNumberWithDecimal: [[NSNumber numberWithInt:categoryId] decimalValue]] ];
        [nearmeLocationOptions setLatitude:latitude];
        [nearmeLocationOptions setLongitude:longitude];
        
        result = nearmeLocationOptions;
        
	} else {
		if (setting.zipCode != NULL && (![setting.zipCode isEqualToString:@""])  ) {
            //this is a zipcode location
            ARCAZipLocationSearchOptions *zipcodeLoationOptions = [[ARCAZipLocationSearchOptions alloc] init];
            
            [zipcodeLoationOptions setRange:[NSDecimalNumber decimalNumberWithDecimal: [setting.distance decimalValue] ]];
            [zipcodeLoationOptions setPage:[NSDecimalNumber decimalNumberWithDecimal: [[NSNumber numberWithInt:page] decimalValue] ]];
            [zipcodeLoationOptions setOrder:orderBy];
            [zipcodeLoationOptions setCategoryID:[NSDecimalNumber decimalNumberWithDecimal: [[NSNumber numberWithInt:categoryId] decimalValue]]];
            [zipcodeLoationOptions setKeyword:keyword];
            [zipcodeLoationOptions setCountryID:[NSDecimalNumber decimalNumberWithDecimal: [setting.city.state.country.country_id decimalValue] ]];
            [zipcodeLoationOptions setZipcode:zipcode];
            
            result = zipcodeLoationOptions;
            
		}else {
            //this is a city based location 
            ARCALocalLocationSearchOptions *localLocationOptions = [[ARCALocalLocationSearchOptions alloc] init];
            
            [localLocationOptions setRange: [NSDecimalNumber decimalNumberWithDecimal:[setting.distance decimalValue]] ];
            [localLocationOptions setKeyword:keyword];
            [localLocationOptions setPage: [NSDecimalNumber decimalNumberWithDecimal: [[NSNumber numberWithInt:page] decimalValue] ]  ];
            [localLocationOptions setOrder:orderBy];
            [localLocationOptions setCategoryID: [NSDecimalNumber decimalNumberWithDecimal: [[NSNumber numberWithInt:categoryId] decimalValue] ] ];
            [localLocationOptions setCountryID: [NSDecimalNumber decimalNumberWithDecimal: [setting.city.state.country.country_id decimalValue] ] ];
            [localLocationOptions setStateID: [NSDecimalNumber decimalNumberWithDecimal: [setting.city.state.state_id decimalValue] ] ];
            [localLocationOptions setCityID: [NSDecimalNumber decimalNumberWithDecimal: [setting.city.city_id decimalValue] ] ];

            
            result = localLocationOptions;
		}
	}
    
    return result;
    
}
	
@end
