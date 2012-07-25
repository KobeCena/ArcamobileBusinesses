//
//  Language.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 06/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Language : NSObject {
	NSString *id;
	NSString *name;
	char *enabled;

}

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, readwrite) char *enabled;

@end
