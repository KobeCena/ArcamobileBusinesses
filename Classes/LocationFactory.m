//
//  LocationFactory.m
//  Gayborhood
//
//  Created by Roberto on 30/07/10.
//  Copyright 2010 Arca Solutions, Inc. All rights reserved.
//
#import "LocationFactory.h"
#import "Listing.h"
#import "Country.h"
#import "State.h"
#import "City.h"
#import "EdirectoryParserToWSSoapAdapter.h"


#import "ARCACountry.h"
#import "ARCAState.h"
#import "ARCACity.h"


@implementation LocationFactory

@synthesize locations, results, xmlParser, urlString, delegate, managedObjectContext;


static const int kLocatonTypeCountry = -1;
static const int kLocatonTypeState = 0;
static const int kLocatonTypeCity = 1;


-(void) startDownloadAndParse:(NSString *)url {
	
	self.xmlParser = [self loadXmlParser];
    [self.xmlParser setRootElementName:@"eDirectoryData"];
	[self.xmlParser setMaximumNumberOfObjectsToParse:2000];
	[self.xmlParser loadObjectsData:url];
	
}

-(EdirectoryXMLParser *) loadXmlParser {

	
	if (self.xmlParser != nil) {
		return	self.xmlParser;
	}
	
	EdirectoryXMLParser *tmpParser = [[EdirectoryXMLParser alloc] initXMLParserDelegate];
	tmpParser.delegate = self;
	self.xmlParser = tmpParser;
	[tmpParser release];
	return self.xmlParser;
}


#pragma mark -
-(void) parserDidReceivePagingNumbers:(int)totalNumberOfPages wichPage:(int)actualPage {
}


-(void) parserDidEndParsingData:(NSArray *)objectResults {
	[self performSelectorOnMainThread:@selector(setResults:) withObject:objectResults waitUntilDone:YES];
	[self convertLocations:locationType];
}

-(void) parserEndWithError:(BOOL)hasErrors {
	[self.delegate performSelectorOnMainThread:@selector(locationDidFinishWithArray:) withObject: [NSArray array]  waitUntilDone:YES];
}

// Called by the parser when no listingResults were found
- (void)noResultsWereFound{
	[self.delegate performSelectorOnMainThread:@selector(locationDidFinishWithArray:) withObject: [NSArray array]  waitUntilDone:YES];    
}


static const int CityOption = 0;

-(void)convertLocations:(int)objType {

	NSMutableArray *objs = [NSMutableArray array];
	
	Country *country;
	State *state;
	City *city;
	Listing *listing;
	
	switch (objType) {
			
		case 1:
			
			for (int i = 0; i < [self.results count]; i++) {
                    
				ARCACity * arcaCity = [self.results objectAtIndex:i];
                
				city = (City *)[NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:self.managedObjectContext];
				city.city_id = [NSNumber numberWithInteger: [arcaCity._id integerValue] ];
				city.name = [arcaCity name] ;
				city.state = currentState;
				[objs addObject:city];
				//[city release];
			}
			
			break;
			
		case 0:
			
			for (int i = 0; i < [self.results count]; i++) {
				
				ARCAState * arcaState = [self.results objectAtIndex:i];
                
				state = (State *)[NSEntityDescription insertNewObjectForEntityForName:@"State" inManagedObjectContext:self.managedObjectContext];
				state.state_id = [NSNumber numberWithInteger: [arcaState._id integerValue] ];
				state.name = [arcaState name];
				state.abbreviation = [arcaState abbreviation];
				state.country = currentCountry;
				[objs addObject:state];
				//[state release];
			}
			
			break;

			
		case -1:
			
			for (int i = 0; i < [self.results count]; i++) {
				
				
                ARCACountry * arcaCountry = [self.results objectAtIndex:i];
                
				country = (Country *)[NSEntityDescription insertNewObjectForEntityForName:@"Country" inManagedObjectContext:self.managedObjectContext];
				country.country_id = [NSNumber numberWithInteger: [arcaCountry._id integerValue] ];
				country.name = [arcaCountry name];
				[objs addObject:country];
				//[country release];
				
			}
			break;
	}
	
	self.locations = [NSArray arrayWithArray:objs];
	
	
	[self.delegate performSelectorOnMainThread:@selector(locationDidFinishWithArray:) withObject:self.locations waitUntilDone:YES];
}

/* ----------------------------------------*/
-(void) retrieveAllCountries {
	
	NSLog(@"retrieveAllCountries");
	
	//Gets the URL string from a plist file
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
		
	self.urlString = [NSString stringWithFormat:[connPlist objectForKey:@"LocationCountry"]];
	
	NSLog(@"urlString: %@", urlString);
	
	locationType = kLocatonTypeCountry;
	
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [adapter setDelegate:self];
    
    [adapter getAllCountries];
    
	//[self startDownloadAndParse:self.urlString];
	
}

-(void) retrieveAllStatesFromCountry:(Country *)country {
	
	NSLog(@"retrieveAllStatesFromCountry");
	
	//Gets the URL string from a plist file
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
		
	self.urlString = [NSString stringWithFormat:[connPlist objectForKey:@"LocationState"], [country.country_id intValue]];
	
	currentCountry = country;
	
	locationType = kLocatonTypeState;
	
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [adapter setDelegate:self];
    
    NSDecimalNumber * countryIDD = [NSDecimalNumber decimalNumberWithDecimal: [country.country_id decimalValue] ];
    
    [adapter getStatesForCountry:countryIDD];
        
	//[self startDownloadAndParse:self.urlString];
	
}


-(void) retrieveAllCitiesFromState:(State *)state {
	
	NSLog(@"retrieveAllCitiesFromState");
	
	//Gets the URL string from a plist file
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
	
	self.urlString = [NSString stringWithFormat:[connPlist objectForKey:@"LocationCity"], [state.state_id intValue]];
	
	currentState = state;
	
	locationType = kLocatonTypeCity;
	
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [adapter setDelegate:self];
    
    NSDecimalNumber * stateIDD = [NSDecimalNumber decimalNumberWithDecimal: [state.state_id decimalValue] ];
    
    [adapter getCitiesForState:stateIDD andLetter:@"*"];
	
    
    //[self startDownloadAndParse:self.urlString];

}

- (void) retrieveAllCitiesFromStateAndLetter:(State *) state letter:(NSString *)letter {
	
	NSLog(@"retrieveAllCitiesFromStateAndLetter");
	
	//Gets the URL string from a plist file

	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
	
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
	
	self.urlString = [NSString stringWithFormat:[connPlist objectForKey:@"LocationCity"], [state.state_id intValue]];
	
	
	self.urlString = [self.urlString stringByAppendingFormat:@"&letter=%@", letter];
	
	NSLog(@"URL %@", self.urlString);
	
	currentState = state;
	
	locationType = kLocatonTypeCity;
    
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [adapter setDelegate:self];
    
    NSDecimalNumber * stateIDD = [NSDecimalNumber decimalNumberWithDecimal: [state.state_id decimalValue] ];
    
    [adapter getCitiesForState:stateIDD andLetter:letter];    
	
	//[self startDownloadAndParse:self.urlString];
	
}

-(void) dealloc {
	[managedObjectContext release];
	[urlString release];
	[results release];
	[xmlParser release];
	[super dealloc];
}

@end
