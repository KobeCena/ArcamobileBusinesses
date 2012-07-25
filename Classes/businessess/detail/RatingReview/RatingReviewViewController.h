//
//  RatingReviewViewController.h
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 8/31/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayViewController.h"
#import "EdirectoryParserToWSSoapAdapter.h"
#import "SA_OAuthTwitterEngine.h"
#import "SA_OAuthTwitterController.h"
#import "SettingsManager.h"

@protocol RatingReviewControllerDelegate <NSObject>

-(void) didFinishPostReview;

@end

@interface RatingReviewViewController : UIViewController <OverlayViewControllerDelegate, EdirectoryXMLParserDelegate, UIAlertViewDelegate, UITextFieldDelegate, SA_OAuthTwitterEngineDelegate, SA_OAuthTwitterControllerDelegate> {
    
    id<RatingReviewControllerDelegate> delegate;
    
    NSString * businessTittle;
    int businessID;
    int reviewNote;
    UIView *reviewStarsView;
    UIView *cameraMediaView;
    UIButton *starButton1;
    UIButton *starButton2;
    UIButton *starButton3;
    UIButton *starButton4;
    UIButton *starButton5;
    
    OverlayViewController *overlayViewController; // the camera custom overlay view    
    UIImage *capturedImage; // the image captured from the camera   
    UIButton *cameraButton;
    UITextView *reviewTextView;
    UIImageView *imagetakenBadge;
    UISwitch *facebookSwitch;
    UISwitch *twitterSwitch;
    UILabel *businessTitleLabel;
    UILabel *alertLabel;
    UIView *alertView;
    UIImageView *imageTestView;
    IBOutlet UIButton *btnEmailInsert;
    
    UITextField *emailPromptText;
    UIAlertView *promptView;
    UILabel *lblRateIt;
    UILabel *lblShareFacebook;
    UILabel *lblShareTwitter;
    UIButton *btnFromLibrary;
    UIButton *btnCameraCancel;
    
    EdirectoryParserToWSSoapAdapter *_adapter;
    
    NSString *_moduleName;
    
    UIViewController * parentDetailViewController;  
    
    SettingsManager             *setm;
    
    NSString *twitter_oauth_token;
    NSString *twitter_oauth_secret;
    
    NSString *foursquare_id;
}

@property(nonatomic,retain) NSString *moduleName;

@property(nonatomic,retain) NSString * businessTittle;
@property(nonatomic,assign) int businessID;
@property(nonatomic,assign) int reviewNote;

@property (nonatomic, retain) IBOutlet UIView *reviewStarsView;
@property (nonatomic, retain) IBOutlet UIView *cameraMediaView;

@property (nonatomic, retain) OverlayViewController *overlayViewController;
@property (nonatomic, retain) UIImage *capturedImage;
@property (nonatomic, retain) IBOutlet UIButton *cameraButton;
@property (nonatomic, retain) IBOutlet UITextView *reviewTextView;
@property (nonatomic, retain) IBOutlet UIImageView *imagetakenBadge;

@property (nonatomic, retain) IBOutlet UISwitch *facebookSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *twitterSwitch;
@property (nonatomic, retain) IBOutlet UILabel *businessTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *alertLabel;
@property (nonatomic, retain) IBOutlet UIView *alertView;
@property (nonatomic, retain) IBOutlet UIImageView *imageTestView;
@property (nonatomic, retain) UITextField *emailPromptText;
@property (nonatomic, retain) UIAlertView *promptView;
@property (nonatomic, retain) IBOutlet UILabel *lblRateIt;
@property (nonatomic, retain) IBOutlet UILabel *lblShareFacebook;
@property (nonatomic, retain) IBOutlet UILabel *lblShareTwitter;
@property (nonatomic, retain) IBOutlet UIButton *btnFromLibrary;
@property (nonatomic, retain) IBOutlet UIButton *btnCameraCancel;
@property (nonatomic, retain) EdirectoryParserToWSSoapAdapter *adapter;
@property (nonatomic, assign) UIViewController * parentDetailViewController;
@property (retain, nonatomic) IBOutlet UIButton *btnShareEmail;

@property(nonatomic,retain) SettingsManager             *setm;

@property(nonatomic,retain) NSString *foursquare_id;

@property(nonatomic,retain) id<RatingReviewControllerDelegate> delegate;

- (IBAction)photoLibraryAction:(id)sender;
- (IBAction)cameraAction:(id)sender;
- (IBAction)handleEmailInsertButton:(id)sender;
- (IBAction)handleReviewTextPress:(id)sender;

- (void)storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username;
- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username;
- (IBAction)handleTwitterSwitch:(id)sender;

@end
