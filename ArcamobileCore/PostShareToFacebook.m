//
//  PostShareToFacebook.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 7/1/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "PostShareToFacebook.h"


@implementation PostShareToFacebook


@synthesize authToken;
@synthesize promotionID;
@synthesize profileID;


- (id)initWithToken:(NSString *)token fromDeal:(NSInteger) promoID whithProfileID:(NSString *)authID {
    self = [super init];
    if (self) {
        [self setAuthToken:token];
        [self setPromotionID:promoID];
        NSLog(@"FACEBOOK ID: %@ ", authID);        
        [self setProfileID:authID];
    }
    return self;
}


-(void)share{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
    NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSLog(@"FACEBOOK ID: %@ ", self.profileID);
    NSLog(@"URL: %@ ", [connPlist objectForKey:@"FacebookPost"]);    
    
    NSString *url = [NSString stringWithFormat:[connPlist objectForKey:@"FacebookPost"], 
                     self.profileID,                          
                     [self.authToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
                     self.promotionID ];
    
    NSMutableURLRequest *mutableRequest = [[[NSMutableURLRequest alloc] init] autorelease];
    [mutableRequest setURL: [NSURL URLWithString:url]];
    
    [mutableRequest setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)" forHTTPHeaderField:@"User-Agent"];
    [[[NSURLConnection alloc] initWithRequest:mutableRequest delegate:self] autorelease];
    
    
}


- (void)dealloc {
    [authToken      release];
    [profileID      release];
    [super          dealloc];
}


#pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    NSLog(@"SHAREToFACEBOOK RESPONSE : %@", data);
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection didFailWithError trying to share to Twitter");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSLog(@"Successful share to FACEBOOK");
}



@end
