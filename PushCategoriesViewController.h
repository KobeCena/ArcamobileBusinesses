//
//  PushCategoriesViewController.h
//  ArcaMobileDeals
//
//  Created by Rafael Gustavo Gali on 06/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EdirectoryXMLParser.h"
#import "RpCacheController.h"
#import "Category.h"
#import "CoreUtility.h"

@protocol PushCategoriesDelegate <NSObject>

@required
-(void)pushCategoriesDoneWithCount:(NSInteger)count andOptions:(NSString *)newOptions;

@end


@interface PushCategoriesViewController : UIViewController<EdirectoryXMLParserDelegate> {
    
    EdirectoryXMLParser *edirectoryXMLParser;

    
    NSArray *dashBoardItems;

    UITableView *categoriesTableView;
    
    NSMutableDictionary *dictCategories;
    
    id<PushCategoriesDelegate>delegate;
    
}

@property (retain) id<PushCategoriesDelegate>delegate;

@property (nonatomic, retain) IBOutlet UITableView *categoriesTableView;
@property (nonatomic, retain) EdirectoryXMLParser *edirectoryXMLParser;
@property (nonatomic, retain) NSString *xmlOperation;
@property (nonatomic, retain) NSArray *dashBoardItems;
@property (retain) NSMutableDictionary *dictCategories;

-(void)syncResultsWithPlist;

-(IBAction)doneButtonClicked:(id)sender;

@end
