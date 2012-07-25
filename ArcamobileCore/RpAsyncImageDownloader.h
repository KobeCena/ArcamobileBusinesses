//
//  RpAsyncImageDownloader.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/28/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol RpAsyncImageDownloaderDelegate <NSObject,ASIHTTPRequestDelegate>

- (void) appImageDidLoad:(NSData *)imageData forIndex:(int)index;
- (void) appImageLoadFailed: (int)index;

@end



@interface RpAsyncImageDownloader : NSObject {
    
    id <RpAsyncImageDownloaderDelegate> delegate;
	NSNumber *indexForElement;
	NSMutableData *activeDownload;
	NSURLConnection *imageConnection;
    NSString * filePath;
    NSOperationQueue *queue;
    
}

@property (nonatomic, assign) id <RpAsyncImageDownloaderDelegate> delegate;
@property (nonatomic, retain) NSNumber *indexForElement;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSOperationQueue *queue;

- (void)startDownload:(NSURL *)url withProgress: (UIProgressView **) progressView;
- (void)cancelDownload;

@end
