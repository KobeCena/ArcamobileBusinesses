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

#import <QuartzCore/QuartzCore.h>
#import "IconDownloader.h"


#define kListingIconWidthDetail 92
#define kListingIconHeightDetail 91

#define kListingIconWidth 65
#define kListingIconHeight 65

@implementation IconDownloader

@synthesize listing;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize newWidth, newHeight;
@synthesize isDetail;

#pragma mark 
- (void)dealloc {

	[self setDelegate:nil];
	[indexPathInTableView release];
	[activeDownload release];
	[imageConnection cancel];
	[imageConnection release];
	[super dealloc];
}

#pragma mark -
#pragma mark calculate dimentions

- (void) calculateNewDimentions:(float)width height:(float)height {
	
	self.newWidth = (isDetail) ? kListingIconWidthDetail : kListingIconWidth;
	self.newHeight = self.newWidth / width * height;
	
	float h = (isDetail) ? kListingIconHeightDetail : kListingIconHeight;
	
	if (self.newHeight > h) {
		
		self.newHeight = (isDetail) ? kListingIconHeightDetail : kListingIconHeight;
		self.newWidth = self.newHeight / height * width;
		
	}
	
}

#pragma mark -
#pragma mark download support
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	self.activeDownload = nil;
	self.imageConnection = nil;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
	
	[self calculateNewDimentions:image.size.width height:image.size.height];
	
	if (image.size.width != self.newWidth && image.size.height != self.newHeight) {
		
		CGSize itemSize = CGSizeMake(newWidth, newHeight);
		
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		
		[image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1.0];
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.0); 
		CGContextStrokeRect(context, imageRect);
		
		if (isDetail) {
            [self.listing setListingIconDetail:UIGraphicsGetImageFromCurrentImageContext()];
		} else {
            [self.listing setListingIcon:UIGraphicsGetImageFromCurrentImageContext()];
		}		
		
		UIGraphicsEndImageContext();
		
	} else {
        [self.listing setListingIcon:image];
	}
	
	
	self.activeDownload = nil;

	[image release];
	
	self.imageConnection = nil;
	
	
	NSLog(@"%@", (delegate != nil) ? @"delegate is not null" : @"delegate is null");
	
	NSLog(@"Call <appImageDidLoad> delegate");
	[delegate appImageDidLoad:self.indexPathInTableView];
	

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}



#pragma mark -
#pragma mark download starter and canceler
- (void)startDownload {
	
	if ([listing imageURLString]==nil || [[listing imageURLString] length] < 1) {
        [self.listing setListingIcon:[UIImage imageNamed:@"bg_noimage.jpg"]];
        [self.listing setListingIconDetail: [self.listing listingIcon] ];
		[delegate appImageDidLoad:self.indexPathInTableView];
		return;
	}
	
	self.activeDownload = [NSMutableData data];
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:[listing imageURLString]]] delegate:self];
	
	self.imageConnection = conn;
	
	[conn release];
	
	
	
	NSAssert(self.imageConnection != nil, @"Failure to create URL connection.");
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)cancelDownload {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.imageConnection cancel];
	self.imageConnection = nil;
	self.activeDownload = nil;
}



@end
