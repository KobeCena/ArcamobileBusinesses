//
//  PostShareToTwitter.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 7/1/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "PostShareToTwitter.h"

@implementation PostShareToTwitter

@synthesize pin, promotionID;

- (id)initWithPin:(NSString *)tPin fromDeal:(NSInteger)tPromotionID {
    self = [super init];
    if (self) {
        [self setPin:tPin];
        [self setPromotionID:tPromotionID];
    }
    return self;
}


-(void)share{

    NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
    NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSMutableString *url = [NSMutableString stringWithFormat:[connPlist objectForKey:@"TwitterPost"],self.promotionID];
    
    [url appendFormat:@"&%@", [self.pin stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    

    NSMutableURLRequest *mutableRequest = [[[NSMutableURLRequest alloc] init] autorelease];
    [mutableRequest setURL: [NSURL URLWithString:url]];
    
    [mutableRequest setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)" forHTTPHeaderField:@"User-Agent"];
    [[[NSURLConnection alloc] initWithRequest:mutableRequest delegate:self] autorelease];
    
    
}


- (void)dealloc {
    [pin            release];
    [super          dealloc];
}


#pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
 
    NSLog(@"SHAREToTWITTER RESPONSE : %@", data);
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection didFailWithError trying to share to Twitter");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSLog(@"Successful share to Twitter");
}

@end
