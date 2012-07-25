//
//  RpDashBoard.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 5/24/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RpCacheController.h"
#import "RpActivityIndicatorView.h"
@protocol RpDashBoardDataSource, RpDashBoardDelegate;


@interface RpDashBoard : UIView <UIScrollViewDelegate, RpCacheControllerDelegate>{    
    RpCacheController  *cacheController;
}

@property (nonatomic, assign) IBOutlet id<RpDashBoardDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<RpDashBoardDelegate> delegate;
@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, readonly) NSInteger numberOfCollumns;
@property (nonatomic, readonly) NSInteger horizontalSpace;
@property (nonatomic, readonly) NSInteger verticalSpace;
@property (nonatomic, readonly) NSInteger selectedItemIndex;
@property (nonatomic, retain, readonly) NSArray *itemViews;
@property (nonatomic, retain, readonly) UIScrollView *scrollView;
@property (nonatomic, retain, readonly) UIPageControl *pageControl;
@property (nonatomic, readonly) CGSize itemSize;
@property (nonatomic, readonly) CGPoint initialPoint;


- (void)reloadData;
- (void)repaintLayout;
@end



@protocol RpDashBoardDataSource <NSObject>

@required
- (NSUInteger)numberOfItemsInDashBoard:(RpDashBoard *)dashboard;
- (NSUInteger)numberOfCollumnsInDashBoard:(RpDashBoard *)dashboard;
- (UIView *)dashboard:(RpDashBoard *)dashboard viewForItemAtIndex:(NSUInteger)index;
- (NSString *)dashboard:(RpDashBoard *)dashboard titleForItemAtIndex:(NSUInteger)index;
- (NSUInteger)amountOfHorizontalSpace:(RpDashBoard *)dashboard;
- (NSUInteger)amountOfVerticalSpace:(RpDashBoard *)dashboard;
- (NSDate *)lastUpdateFromServer:(RpDashBoard *)dashboard;

@optional
- (CGPoint)dashboardInitialPoint;
- (CGSize)dashboardItemSize;

@end


@protocol RpDashBoardDelegate <NSObject>

@optional
- (void)dashboardDidPressButton:(RpDashBoard *)dashboard atIndex:(NSUInteger) index;
- (void)dashboardDidScrollToPage:(RpDashBoard *)dashboard atIndex:(NSUInteger) index;
- (void)dashboardDidAddedLabelToItem:(RpDashBoard *)dashboard labelItem:(UILabel *)label atIndex:(NSUInteger) index;
@end