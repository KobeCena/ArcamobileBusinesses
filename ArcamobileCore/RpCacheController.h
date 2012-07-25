//
//  RpCacheController.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/28/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RpAsyncImageDownloader.h"




@protocol RpCacheControllerDelegate <NSObject>

- (void) appImageDidLoad:(NSData *)imageData forIndex:(int)index;
- (void) appImageLoadFailed: (int)index;

@end


@interface RpCacheController : NSObject <RpAsyncImageDownloaderDelegate>{
    
    id <RpCacheControllerDelegate> delegate;
    
	NSString *dataPath;
	NSString *filePath;
	NSDate *cacheDate;
	NSMutableArray *urlArray;
	NSURLConnection *connection;
	NSError *error;
    
    //holds all images download in background
    NSMutableDictionary *imageDownloadsInProgress;
    
    int buttonIndex;
    
    NSDate *lastUpdate;
    
    UIProgressView *progressView;
    
}

@property (nonatomic, assign) id <RpCacheControllerDelegate> delegate;

@property (nonatomic, copy)   NSString *dataPath;
@property (nonatomic, copy)   NSString *filePath;
@property (nonatomic, retain) NSDate *cacheDate;
@property (nonatomic, retain) NSMutableArray *urlArray;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSDate *lastUpdate;
@property (nonatomic, retain) UIProgressView *progressView;

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

/*
 ------------------------------------------------------------------------
 Public methods
 ------------------------------------------------------------------------
 */
- (id) initWhithLastUpdateFromServer:(NSDate *)aDate;
- (id) initForCheck;
- (void) prepareCachedImage:(NSURL *)imageURL forThisIndex:(int)index;
- (void) writeDataIntoCache:(NSData *)data withName:(NSString *)name;
- (void) preventCacheOverflow: (NSNumber *) newFileSize;

/*
 ------------------------------------------------------------------------
 Public static method
 ------------------------------------------------------------------------
 */

+ (BOOL) cacheisExpired;
+ (BOOL) fileisExpired: (NSString *)filename;
+ (BOOL) fileExistInCache:(NSString *)fileName;
+ (BOOL) removeFile: (NSString *)filename;
+ (NSData *) getFileFromCache:(NSString *)fileName;

+ (NSNumber *) cacheSize;
+ (NSNumber *) freeDiskSpace;

@end
