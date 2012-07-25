//
//  RecordInstall.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/22/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "RecordInstall.h"
#import "ARCAserver_businesses.h"

@interface RecordInstall() 

    // Properties that don't need to be seen by the outside world.
    @property (nonatomic, retain) NSURLConnection * connection;
    @property (nonatomic, retain) NSString * applicationPath;
    @property (nonatomic, retain) NSString * url;

@end

@implementation RecordInstall

@synthesize connection = _connection;
@synthesize applicationPath;
@synthesize url;


- (id)init {
    self = [super init];
    if (self) {
        
        //gets the application Path
        [self setApplicationPath:[[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"]];        
        NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:[self applicationPath]];
        [self setUrl:[connPlist objectForKey:@"RecordInstall"]];

    }
    return self;
}



-(void)callServerAndRegisterInstallation:(NSString*)uniqueID{
    
    //gets a reference to this device
    //UIDevice *thisDevice = [UIDevice currentDevice];
    //NSDateFormatter * df = [[NSDateFormatter alloc] init];
    //[df setDateFormat:@"MM/dd/yyyy"];
    
	// Create the service
	ARCAserver_businesses* service = [ARCAserver_businesses service];
	service.logging = NO;
    
    
	[service recordInstall:self 
                    action:@selector(recordInstallHandler:) 
                       uid: uniqueID
                    device: @"iphone" 
                    module: @"businesses"];
     
    //[df release];
    
    /*
     
    //defines the user agent
	NSString* userAgent = @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
    //build the parameters
	NSString *params = [NSString stringWithFormat:@"uid=%@&install_date=%@",
                        [thisDevice uniqueIdentifier],//device's guid 
                        [df stringFromDate:[NSDate date]] //actual install date
                        ];
	
    [df release];
    
	NSLog(@" RECORD INSTALL PARAMS: %@", params);
	
	NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat: @"%d", [postData length]];
	NSMutableURLRequest *eDirectoryURLRequest = [[[NSMutableURLRequest alloc] init] autorelease];
    NSLog(@"URL for INSTALL: %@", url);
	[eDirectoryURLRequest setURL: [NSURL URLWithString:url]];
	[eDirectoryURLRequest setHTTPMethod:@"POST"];
	[eDirectoryURLRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[eDirectoryURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; 
	[eDirectoryURLRequest setHTTPBody:postData];  
	[eDirectoryURLRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    self.connection = [NSURLConnection connectionWithRequest:eDirectoryURLRequest delegate:self];
    [self.connection start];
     */
}

#pragma mark - just finish the connection
- (void)_stopSendWithStatus:(NSString *)statusString
{
    //just ignores the statusString param since I'm not providing any visual feedback to the user
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    
}


// Handle the response from recordInstall.
- (void) recordInstallHandler: (BOOL) value {
    
    
	// Do something with the BOOL result
    
	NSLog(@"recordInstall returned the value: %@", [NSNumber numberWithBool:value]);
    
}


#pragma mark - NSURLConnection delegate methods
/*
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    // do nothing
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
    // do nothing
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    [self _stopSendWithStatus:@"Connection failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    [self _stopSendWithStatus:nil];
    NSLog(@"FInalizou RECORD INSTALL");
}

*/

@end
