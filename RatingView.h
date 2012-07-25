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

@interface RatingView : UIView {

	UIImageView *bgImgView;
	UIImageView *fgImgView;
	float rating;
	
}

@property (nonatomic, assign) float rating;
@property (nonatomic, retain) UIImageView *bgImgView;
@property (nonatomic, retain) UIImageView *fgImgView;

@end
