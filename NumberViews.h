//
//  NumberViews.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 15/12/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ModuleTypeListing    = 0,
	ModuleTypeEvent      = 1,
	ModuleTypePromotion  = 2,
	ModuleTypeClassified = 3,
	ModuleTypeArticle    = 4
} ModuleType;

@interface NumberViews : NSObject  {
}

+ (void) addNumberViews: (ModuleType)module withID:(NSInteger)itemID  ;

@end
