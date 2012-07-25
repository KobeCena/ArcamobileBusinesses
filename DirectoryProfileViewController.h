//
//  DirectoryProfileViewController.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 05/11/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginData.h"

@interface DirectoryProfileViewController : UIViewController {
	LoginData *loginData;
	BOOL       isViewPushed;

}

@property (nonatomic, readwrite) BOOL isViewPushed;


@end
