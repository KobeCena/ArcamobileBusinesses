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

#import <Foundation/Foundation.h>


@interface Category : NSObject {
	NSString *name;
    NSString *iconURL;
    NSString *label;
    NSNumber *categoryID;
	

}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *iconURL;
@property(nonatomic, retain) NSString *label;
@property(nonatomic, retain) NSNumber *categoryID;

@end
