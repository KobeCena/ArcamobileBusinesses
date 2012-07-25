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

#import <UIKit/UIKit.h>


@interface AppLoaderViewController : UIViewController {
	UIImageView *imageView;
	UIActivityIndicatorView *activityIndicatorView;

    
    IBOutlet UILabel *copyrightLabel;
    
    IBOutlet UIButton *cancelButton;
    UIImageView *loadingTextImageView;
    
}

@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIImageView *loadingTextImageView;


-(IBAction)handleCancelButton:(id)sender;
@end
