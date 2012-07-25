//
//  LocationFactory.h
//  Gayborhood
//
//  Created by Roberto on 30/07/10.
//  Copyright 2010 Arca Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EdirectoryXMLParser.h"

@class Country;
@class State;

@protocol LocationFactoryDelegate

- (void) locationDidFinishWithArray:(NSArray *)locations;

@end


@interface LocationFactory : NSObject <EdirectoryXMLParserDelegate> {

	id <LocationFactoryDelegate> delegate;
	NSArray *results;
	NSArray *locations;
	EdirectoryXMLParser *xmlParser;
	NSString *urlString;
	BOOL done;
	int locationType;
	NSManagedObjectContext *managedObjectContext;
	Country *currentCountry;
	State *currentState;
}

@property (nonatomic, assign) id <LocationFactoryDelegate> delegate;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSArray *results;
@property (nonatomic, retain) NSArray *locations;
@property (nonatomic, retain) EdirectoryXMLParser *xmlParser;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(EdirectoryXMLParser *) loadXmlParser;
- (void) retrieveAllCountries;
- (void) retrieveAllStatesFromCountry:(Country *) country;
- (void) retrieveAllCitiesFromState:(State *) state;
- (void) retrieveAllCitiesFromStateAndLetter:(State *) state letter:(NSString *)letter;

@end
