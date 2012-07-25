//
//  RpAsyncImageDownloader.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/28/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "RpAsyncImageDownloader.h"


@implementation RpAsyncImageDownloader

@synthesize delegate;
@synthesize indexForElement;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize filePath;
@synthesize queue;


- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [indexForElement    release];
    [activeDownload     release];
    [imageConnection    release];
    [filePath           release];
    for (ASIHTTPRequest * requestObj in [queue operations]) {
        [requestObj setDelegate:nil];
    }
    [queue              release];
    [super dealloc];
}

- (void)startDownload:(NSURL *)url withProgress: (UIProgressView **) progressView {
    
    self.activeDownload = [NSMutableData data];
    
    if (![self queue]) {
        [self setQueue:  [[[NSOperationQueue alloc] init] autorelease]  ];
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    if (progressView != nil) {
        [request setDownloadProgressDelegate: *progressView];
    }
    [request setDelegate:self];
    
    //[request startAsynchronous];
    [[self queue] addOperation:request];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}	

- (void)cancelDownload {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.imageConnection cancel];
	self.imageConnection = nil;
	self.activeDownload = nil;
}

#pragma mark - ASIHTTPRequestDelegate Delegate Methods
- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    self.activeDownload = [NSMutableData dataWithData:[request responseData]];
    
    //records file in the given path
    [[NSFileManager defaultManager] createFileAtPath:filePath
                                            contents:self.activeDownload
                                          attributes:nil];
    
    
    if ([delegate respondsToSelector:@selector(appImageDidLoad:forIndex:)]) {
        [delegate appImageDidLoad:self.activeDownload forIndex:[self.indexForElement intValue]];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([delegate respondsToSelector:@selector(appImageLoadFailed:)]) {
        [delegate appImageLoadFailed: [self.indexForElement intValue]];
    }
    
}

@end
