/**
 *  EdirectoryParserToWSSoapAdapter.h
 *  ArcaMobileBusinesses
 *  Created by Ricardo Silva on 8/24/11.
 *  Copyright 2011 Arca Solutions Inc. All rights reserved. 

 
    This class acts as an Adpater for the entire application,
    converting the responses from WS-SOAP to EdirectoryXMParserDelegate calls.
 
    Since this class is used from all over the places inside the entire application code,  
    It implements the Singleton pattern for better memory management.
 
 */


#import <Foundation/Foundation.h>
#import "EdirectoryXMLParser.h"
#import "SoapDelegate.h"
#import "SoapRequest.h"

@interface EdirectoryParserToWSSoapAdapter : NSObject <SoapDelegate>{
    id <EdirectoryXMLParserDelegate> delegate;
    //hold any possible error message
    NSString * errorMessage;
}


#pragma mark -
#pragma mark Methods
+ (id) sharedInstance;
- (void) cancel;
- (NSDictionary *) getDomainToken;
- (void) getAllCategories;
- (void) getAllBusinessForCategory:(NSDecimalNumber *)categoryID forPage:(int) pageNumber;
- (void) getAllNearbyBusiness:(NSString *) keyword nearbyType:(NSString *)nearbyType zipCode:(NSString *)zipcode nearbyRange:(int)nearbyRange latitude:(float)latitude longitude:(float)longitude page:(int)page;

- (void) postReview:(NSString *) moduleName itemID: (NSDecimalNumber *) itemID userName:(NSString *) userName rateValue:(NSDecimalNumber *) rateValue shareInFacebook:(BOOL)shareInFacebook shareInTwitter:(BOOL)shareInTwitter twitter_oauth_token:(NSString *) twitter_oauth_token twitter_oauth_secret: (NSString *) twitter_oauth_secret shareInEmail:(NSString *)shareInEmail reviewText:(NSString *) reviewText reviewImage:(NSData *)reviewImage imagetype:(NSString *)imagetype foursquare_id: (NSString *) foursquare_id;
- (void)getReviews:(NSString *) username businessID:(NSDecimalNumber *) businessID foursquare_id: (NSString *) foursquare_id module: (NSString *) module page: (NSDecimalNumber *)page;
-(void) getAllBusinessForKeyword: (NSString *)keyword orderBy:(NSDecimalNumber *)order_by categoryID:(NSDecimalNumber *)categoryID latitude: (float)latitude longitude: (float)longitude page: (NSDecimalNumber*) page nearbyType: (NSString *)nearbyType zipcode:(NSString *)zipcode;

- (void) getAllCountries;
- (void) getStatesForCountry:(NSDecimalNumber *)countryID;
- (void) getCitiesForState:(NSDecimalNumber *)stateID andLetter:(NSString *) letter;

#pragma mark -
#pragma mark Properties
@property(nonatomic, assign) id <EdirectoryXMLParserDelegate> delegate;
@property(nonatomic, retain) NSString * errorMessage;

@end
