//
//  ImagePageViewController.h
//  iTravleNZ
//
//  Created by Rafael Gustavo Gali on 22/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InternetImage.h"


@interface ImagePageViewController : UIViewController {
    int pageNumber;
	IBOutlet UIImageView * pageImage;

    NSMutableArray *dataSource;
    InternetImage *asynchImage;
    
    UIActivityIndicatorView *loading;
    
    NSString *imageCaption;
    NSString *thumbCaption;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loading;
@property (nonatomic, retain) InternetImage *asynchImage;
@property (nonatomic, retain) NSMutableArray *dataSource;
@property(nonatomic, retain) IBOutlet UIImageView * pageImage;


@property (nonatomic, retain) NSString *imageCaption;
@property (nonatomic, retain) NSString *thumbCaption;

- (id)initWithPageNumber:(int)page;
- (id)initWithPageNumber:(int)page withSource:(NSMutableArray *)source;


-(void) downloadImageFromInternet:(NSString*)  urlToImage;
-(void) internetImageReady:(InternetImage*) internetImage;

@end
