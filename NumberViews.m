//
//  NumberViews.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 15/12/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "NumberViews.h"

@implementation NumberViews

+ (void) addNumberViews: (ModuleType)module withID:(NSInteger)itemID {
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString *url = [NSString stringWithFormat:[connPlist objectForKey:@"AddNumberViews"], module , itemID];
	
	NSLog(@"Add numberView: %@", url);
	
	NSString* userAgent = @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
	NSMutableURLRequest *eDirectoryURLRequest = [[[NSMutableURLRequest alloc] init] autorelease];
	[eDirectoryURLRequest setURL: [NSURL URLWithString:url]];
	[eDirectoryURLRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	
	NSURLConnection *eDirectoryConnection = [[NSURLConnection alloc] initWithRequest:eDirectoryURLRequest delegate:self];
	[eDirectoryConnection autorelease];
	
}

#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"didReceiveData");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError");
}



@end
