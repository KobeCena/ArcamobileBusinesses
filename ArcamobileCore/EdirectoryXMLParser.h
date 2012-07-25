/*
 ######################################################################
 #                                                                    #
 # Copyright 2005 Arca Solutions, Inc. All Rights Reserved.           #
 #                                                                    #
 # This file may not be redistributed in whole or part.               #
 # eDirectory is licensed on a per-domain basis.                      #
 #                                                                    #
 # ---------------- eDirectory IS NOT FREE SOFTWARE ----------------- #
 #                                                                    #
 # http://www.edirectory.com | http://www.edirectory.com/license.html #
 ######################################################################
 
 ClassDescription:
 Author:
 Since:
 */

#import <Foundation/Foundation.h>
#import "CoreUtility.h"


// Protocol for the parser to communicate with its delegate.
@protocol EdirectoryXMLParserDelegate <NSObject>


@optional
//Called by the parser when the latitude and logitude of the searchable region is received
- (void)parserDidReceiveSearchResultsPosition:(double)latitude withLongitude:(double)longitude;
//Called by the parser when the results array was created
- (void)parserDidCreatedResultsArray:(NSArray *)objectResults;
//Called by the parser when the numbers for paging navigation is received
- (void)parserDidReceivePagingNumbers:(int)totalNumberOfPages wichPage:(int)actualPage;
//Called by the parser everytime that listingResults is updated with a batch of data
- (void)parserDidUpdateData:(NSArray *)objectResults;
- (void)parserDidReceivedRawData:(NSData *)data;
// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(NSArray *)objectResults;
//Parser will call this method just to notify delegates that an error was occurred.
//This method will be usefull for further delegates that will need to know when an error occurred
//during the data parsing to be able to release any holded objects or release/dismiss any graphic Object.
- (void)parserEndWithError:(BOOL)hasErrors;

// Called by the parser when no listingResults were found
- (void)noResultsWereFound;

@end


@interface EdirectoryXMLParser : NSObject <NSXMLParserDelegate> {
	
	id <EdirectoryXMLParserDelegate> delegate;
	
	NSMutableArray *objectList;
	
	double searchResultsLatitude;
	double searchResultsLongitude;	
	
    // for downloading the xml data
    NSURLConnection *eDirectoryConnection;
    NSMutableData *eDirectoryData;
	
	// these variables are used during parsing
    NSMutableArray *currentParseBatch;
    NSUInteger parsedObjectsCounter;
    NSMutableString *currentParsedCharacterData;
	BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
	BOOL hasListingData;
	
	// Limit the number of parsed listings. The default value is 20.
	NSUInteger maximumNumberOfObjectsToParse;
	
	NSObject *currentObject;
	NSString *currentObjectName;
	
    NSDate *lastUpdate;
	
	BOOL entry;
	NSString *setSelector;
	NSString *selector;

	NSMutableDictionary *dicPropertiesObject;
    

}

@property (nonatomic, retain) NSMutableDictionary *dicPropertiesObject;
@property (nonatomic, retain) NSDate *lastUpdate;
@property (nonatomic, retain) NSObject *currentObject;
@property (nonatomic, retain) NSString *currentObjectName;
@property (nonatomic, retain) NSString *setSelector;
@property (nonatomic, retain) NSString *selector;

@property (nonatomic, assign) BOOL logEnabled;
@property (nonatomic, retain) NSString *rootElementName;

@property (nonatomic, assign) id <EdirectoryXMLParserDelegate> delegate;
@property (nonatomic, assign) NSUInteger maximumNumberOfObjectsToParse;

@property (nonatomic, retain) NSMutableArray *objectList;
@property (nonatomic, retain) NSURLConnection *eDirectoryConnection;
@property (nonatomic, retain) NSMutableData *eDirectoryData;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;

-(void)invokeSignature:(NSString *)newSelector withClassName:(NSString *)newClassName withObject:(NSObject *)newObject withArgument:(void *)newArgumentLocation;

- (NSMutableDictionary *)propertDictionary:(NSObject *) objt withSuperClassProperties:(BOOL) getPropertiesFromSuperClass;
- (EdirectoryXMLParser *) initXMLParserDelegate;
- (void)loadObjectsDataFromDisk:(NSString *)fileName;
- (void)loadObjectsData:(NSString *)parameters;
- (double) getSearchResultsLatitude;
- (double) getSearchResultsLongitude;
- (void)handleError:(NSError *)error;

@end
