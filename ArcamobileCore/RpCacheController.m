//
//  RpCacheController.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/28/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "RpCacheController.h"

/* cache update interval in seconds - EVERY 30 minutes */
const double URLCacheInterval = 60 * 60;

/* cache size - 3 GB */
const double CacheMaxSize = 1024 * 1024 * 1024 * 3;

@interface RpCacheController (PrivateMethods)

- (void) proceedWithDownloadAndCache;
- (void) createImageWithURL:(NSURL *)theURL;
- (void) displayCachedImage;
- (void) initCache;
- (void) clearCache;
- (void) initComponents;
- (BOOL) cacheExists;

@end


@implementation RpCacheController

@synthesize delegate;

@synthesize dataPath;
@synthesize filePath;
@synthesize cacheDate;
@synthesize urlArray;
@synthesize connection;
@synthesize lastUpdate;
@synthesize imageDownloadsInProgress;
@synthesize progressView;

#pragma mark - Custom init code
- (id)initWhithLastUpdateFromServer:(NSDate *)aDate {
    self = [super init];
    if (self) {
        [self setLastUpdate:aDate];
        [self initComponents];
    }
    return self;
}


- (id)initForCheck {
    if (self) {
    }
    return self;
}


- (void)dealloc {
    [dataPath release];
	[filePath release];
	[cacheDate release];
	[urlArray release];
	[connection release];
    [lastUpdate release];
    
    //cancels all downloads before release the object
    [[self.imageDownloadsInProgress allValues] makeObjectsPerformSelector:@selector(cancelDownload)];
    [imageDownloadsInProgress release];
    
    [progressView release];
    
    [super dealloc];
}

- (void)preventCacheOverflow:(NSNumber *)newFileSize {
    
    double testCacheSize = [newFileSize doubleValue] + [[RpCacheController cacheSize] doubleValue];
    
    if (testCacheSize > CacheMaxSize) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *cacheDataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RpCache"];
        
        NSArray *arrFiles = [[NSFileManager defaultManager] subpathsAtPath: cacheDataPath];
        for (NSString *strFilePath in arrFiles) {
            if([RpCacheController fileisExpired: strFilePath]) {
                [RpCacheController removeFile: strFilePath];
            }
        }
        
    }
    
}

- (void) writeDataIntoCache:(NSData *)data withName:(NSString *)name{
    
    [self initCache];
    
    [self preventCacheOverflow: [NSNumber numberWithUnsignedInteger:[data length]]];
    [[NSFileManager defaultManager] createFileAtPath:[dataPath stringByAppendingPathComponent:name]
                                            contents:data
                                          attributes:nil];
    
}

/*
 ------------------------------------------------------------------------
 Public static method
 ------------------------------------------------------------------------
*/

+ (BOOL) fileExistInCache:(NSString *)fileName{

    BOOL result = NO;
    
    /* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RpCache"];
    
    result = [[NSFileManager defaultManager] fileExistsAtPath:[dataPath stringByAppendingPathComponent:fileName]];
    
    return result;
}

+ (NSData *) getFileFromCache:(NSString *)fileName{
    
    NSData * result = [NSData data];
    
    /* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RpCache"];
    
    if ([self fileExistInCache:fileName]) {

        result = [[NSFileManager defaultManager] contentsAtPath:[dataPath stringByAppendingPathComponent:fileName]];
    }else{
        //NSLog(@"The file [%@] doesn't exists in the cache",fileName);
    }
    
    return result;
    
}

+ (BOOL) cacheisExpired{

    BOOL result;
    NSDate * cacheDate = [NSDate date];
    NSError * error;
    
    /* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RpCache"];

    
    /* checks te file existanceto update cacheDate property*/
    result = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
    
	/* check for existence of cache directory */
	if (result) {
        
		/* retrieve file attributes from Cache */
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:dataPath error:&error];
		if (attributes != nil) {
			cacheDate = [attributes fileModificationDate];
		}
        
	}else{
        return YES;
    }
    
    if (cacheDate) {
        /* get the elapsed time since last file update */
        NSTimeInterval time = fabs([cacheDate timeIntervalSinceNow]);
        
        /* verify if we need to erquest server to update cache*/
        (time > URLCacheInterval)?(result=YES):(result=NO);
    }else{
        result = YES;
    }
    

    
    return result;
}

+ (BOOL) fileisExpired: (NSString *) filename {
    
    BOOL result;
    NSDate * cacheDate = [NSDate date];
    NSError * error;
    
    /* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RpCache"];
    
    dataPath = [dataPath stringByAppendingPathComponent:filename];
    
    //NSLog(@"Verifying file at %@...", dataPath);
    
    /* checks te file existance to update cacheDate property*/
    result = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
    
	/* check for existence of cache directory */
	if (result) {
        
		/* retrieve file attributes from Cache */
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:dataPath error:&error];
		if (attributes != nil) {
			cacheDate = [attributes fileModificationDate];
		}
        
	}else{
        return YES;
    }
    
    if (cacheDate) {
        /* get the elapsed time since last file update */
        NSTimeInterval time = fabs([cacheDate timeIntervalSinceNow]);
        
        /* verify if we need to erquest server to update cache*/
        (time > URLCacheInterval)?(result=YES):(result=NO);
    }else{
        result = YES;
    }
    
    
    
    return result;
}
+ (BOOL) removeFile: (NSString *)filename {
    
    BOOL result;
    
    /* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RpCache"];
    
    dataPath = [dataPath stringByAppendingPathComponent:filename];
    
    /* checks te file existance to update cacheDate property*/
    result = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
    
	/* check for existence of cache directory */
	if (result) {
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
	}else{
        return YES;
    }
    
    return result;
}

+ (NSNumber *) cacheSize {
    double size = 0;
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RpCache"];
    
    NSArray *arrFiles = [[NSFileManager defaultManager] subpathsAtPath: dataPath];
    for (NSString *filePath in arrFiles) {
        NSString *fullPath = [dataPath stringByAppendingPathComponent: filePath];
        NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error: &error];
        size += [[NSNumber numberWithUnsignedLongLong: [attribs fileSize]] doubleValue];
    }
    
    return [NSNumber numberWithDouble:size];
}

+ (NSNumber *) freeDiskSpace {
    double size;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attribs = [fileManager attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
    size = [[attribs objectForKey:NSFileSystemFreeSize] doubleValue];
    
    return [NSNumber numberWithDouble:size];
}

/*
 ------------------------------------------------------------------------
 Private methods used only in this file
 ------------------------------------------------------------------------
 */
#pragma mark - Public Methods
-(void)initComponents{
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    /* turn off the NSURLCache shared cache */
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];    
    
    /* prepare to use our own on-disk cache */
	[self initCache];    
    
}

/* prepare a cached image */
- (void) prepareCachedImage:(NSURL *)imageURL forThisIndex:(int)index
{    
    
    //updates the button Index
    buttonIndex = index;    
    
	/* get the path to the cached image */
	[filePath release]; /* release previous instance */
	NSString *fileName = [[imageURL path] lastPathComponent];
	filePath = [[dataPath stringByAppendingPathComponent:fileName] retain];
    
    //verifies of the file exist in the path
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
        //NSLog(@"001 fileExistsAtPath ");
        //calls delegate
        if ([self.delegate respondsToSelector:@selector(appImageDidLoad:forIndex:)]) {
            //NSLog(@"002 appImageDidLoad ");
            [self.delegate appImageDidLoad:[NSData dataWithContentsOfFile:filePath] forIndex:index];
        }
    }else{
        //call a second thread to download the image
        //[self performSelectorOnMainThread:@selector(createImageWithURL:) withObject:imageURL waitUntilDone:NO];
                    //NSLog(@"003 createImageWithURL ");
        //[self performSelectorInBackground:@selector(createImageWithURL:) withObject:imageURL];
        [self createImageWithURL:imageURL];
        
    }
    
}


- (void) initCache
{
	/* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RpCache"];
    
    if (![self cacheExists]) {
        /* create a new cache directory */
        if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error]) {
            //URLCacheAlertWithError(error);
            //TODO: Inform user that error occurred
            return;
        }
    }
}


-(BOOL) cacheExists{
    
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
    
	/* check for existence of cache directory */
	if (result) {
        
		/* retrieve file attributes from Cache */
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
		if (attributes != nil) {
			self.cacheDate = [attributes fileModificationDate];
		}

	}
    
    return result;
    
}

/* removes every file in the cache directory */
- (void) clearCache
{
	/* remove the cache directory and its contents */
	if (![[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error]) {
		//TODO: Inform user that error occurred
		return;
	}
    
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath
								   withIntermediateDirectories:NO
													attributes:nil
														 error:&error]) {
		//TODO: Inform user that error occurred
		return;
	}
    
}


/* display new or existing cached image */
- (void) createImageWithURL:(NSURL *)theURL
{
    
    /* file doesn't exist, so call the RpAsyncImageDownloader */
    NSString * keyStr = [NSString stringWithFormat:@"Button_%d", buttonIndex ];  
    
        RpAsyncImageDownloader *imageDownloader = [self.imageDownloadsInProgress objectForKey:keyStr];
        if (imageDownloader == nil) {
            //NSLog(@"Starting image download for object with key [%@]", keyStr);
            imageDownloader = [[RpAsyncImageDownloader alloc] init];
            [self.imageDownloadsInProgress setObject:imageDownloader forKey:keyStr ];
            [imageDownloader setIndexForElement:[NSNumber numberWithInt:buttonIndex]];
            [imageDownloader setDelegate:self];
            [imageDownloader setFilePath:self.filePath];
            [imageDownloader startDownload:theURL withProgress: &progressView];
            [imageDownloader release];
        }else{
            //NSLog(@"There's a RpAsyncImageDownloader object allocated already for the key [%@]", keyStr);
        }

}

- (void) appImageDidLoad:(NSData *)imageData forIndex:(int)index{
    
    NSString * keyStr = [NSString stringWithFormat:@"Button_%d", buttonIndex ];  
    
    RpAsyncImageDownloader *imageDownloader = [self.imageDownloadsInProgress objectForKey:keyStr];
    
    [imageDownloader cancelDownload];
    
    // notifies the delegate
    if ([self.delegate respondsToSelector:@selector(appImageDidLoad:forIndex:)]) {
        [self.delegate appImageDidLoad:imageData forIndex:index];
    }
}

- (void) appImageLoadFailed: (int)index{
    
    // notifies the delegate
    if ([self.delegate respondsToSelector:@selector(appImageLoadFailed:)]) {
        [self.delegate appImageLoadFailed: index];
    }
}



@end
