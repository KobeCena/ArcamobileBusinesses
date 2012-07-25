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

#import "Listing.h"

@protocol IconDownloaderDelegate <NSObject>

- (void) appImageDidLoad:(NSIndexPath *)indexPath;

@end

@interface IconDownloader : NSObject {
	
	id <IconDownloaderDelegate> delegate;
    
	
	NSIndexPath *indexPathInTableView;
	NSMutableData *activeDownload;
	NSURLConnection *imageConnection;
	
    id<ListingObjectDelegate> listing;
	
	float newWidth, newHeight;
	BOOL isDetail;
	
}

@property (nonatomic, assign) BOOL isDetail;
@property (nonatomic, assign) float newWidth;
@property (nonatomic, assign) float newHeight;

@property (nonatomic, assign) id<ListingObjectDelegate> listing;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <IconDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;
- (void) calculateNewDimentions:(float)width height:(float)height;

@end

