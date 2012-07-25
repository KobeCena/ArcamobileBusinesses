//
//  RpDashBoard.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 5/24/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "RpDashBoard.h"
#import "MarqueeLabel.h"
#import "RpDashBoardButton.h"
#import "CoreUtility.h"
#import "RpDashBoardBadge.h"

@interface RpDashBoard()

@property (nonatomic, retain) NSArray       *itemViews;
@property (nonatomic, retain) NSArray       *labelViews;
@property (nonatomic, retain) UIScrollView  *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, assign) NSUInteger    numberOfPages;
@property (nonatomic, retain) NSArray       *viewControllers;
@property (nonatomic, assign) BOOL pageControlUsed;// To be used when scrolls originate from the UIPageControl
@property (nonatomic, retain) RpCacheController *cacheController;
@property (nonatomic, assign) CGPoint       customInitialPoint;


@end

@implementation RpDashBoard


//#define kInitalXPoint 11.0f
//#define kInitalYPoint 20.0f

#define kDefaultInitalXPoint 40.0f
#define kDefaultInitalYPoint 20.0f
#define kDefaultItemSize 55.0f


@synthesize dataSource;
@synthesize delegate;
@synthesize numberOfItems;
@synthesize numberOfCollumns;
@synthesize horizontalSpace;
@synthesize verticalSpace;
@synthesize itemViews;
@synthesize labelViews;
@synthesize scrollView;
@synthesize pageControl;
@synthesize itemSize;
@synthesize initialPoint;
@synthesize numberOfPages;
@synthesize viewControllers;
@synthesize pageControlUsed;
@synthesize cacheController;
@synthesize customInitialPoint;
@synthesize selectedItemIndex = _selectedItemIndex;

-(void)setup{
    
    //call the datasource to get the lastUpdateFromServer date
    NSDate *aDate =[self.dataSource lastUpdateFromServer:self];
    
    //init the cacheController
    self.cacheController = [[RpCacheController alloc] initWhithLastUpdateFromServer:aDate];
    //sets the delegate
    self.cacheController.delegate = self;
    
    
    CGPoint tempPoint = CGPointZero;
    CGSize  tempSize = CGSizeZero;
    
    if ([self.dataSource respondsToSelector:@selector(dashboardInitialPoint)]) {
        tempPoint = [self.dataSource dashboardInitialPoint];                
    }
    
    
    NSLog(@"custom point (%0.2f , %0.2f)", tempPoint.x, tempPoint.y);
    if ([self.dataSource respondsToSelector:@selector(dashboardItemSize)]) {    
        tempSize = [self.dataSource dashboardItemSize];
    }
    NSLog(@"custom size (%0.2f , %0.2f)", tempSize.width, tempSize.height);
    
    
    if ( CGPointEqualToPoint(tempPoint, CGPointZero) ) {
        initialPoint = CGPointMake(kDefaultInitalXPoint, kDefaultInitalYPoint);
        customInitialPoint = CGPointMake(kDefaultInitalXPoint, kDefaultInitalYPoint);
    }else{
        initialPoint = tempPoint;
        customInitialPoint = tempPoint;
    }
    
    if (CGSizeEqualToSize(tempSize, CGSizeZero)) {
        itemSize     = CGSizeMake(kDefaultItemSize, kDefaultItemSize);
    }else{
        itemSize = tempSize;
    }    
    
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.multipleTouchEnabled = NO;
    scrollView.alwaysBounceHorizontal= YES;
    scrollView.scrollsToTop = NO;
    scrollView.scrollEnabled=YES;
    scrollView.delegate = self;
    
    [self addSubview:scrollView];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height-10, self.frame.size.width, 10)];
    pageControl.currentPage = 0;
    
    [self addSubview:pageControl];
}


- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= numberOfPages) return;
    

    @try {
        UIView *controller = [viewControllers objectAtIndex:page];
        
        // add the controller's view to the scroll view
        if (nil == controller.superview) {
            
            CGRect frame = scrollView.frame;
            frame.origin.x = frame.size.width * page;
            frame.origin.y = 0;
            controller.frame = frame;
            [scrollView addSubview:controller];
        }
        
    }
    @catch (NSException *exception) {
        return;
    }

    
    
}

#pragma mark - Hide button bagde
-(void)hideButtonBadgedForIndex:(int)badgeIndex{
    @try {
        //iterate through each page of scroller
        for (UIView *viewObject in self.viewControllers) {
            //iterate through each button of view
            for (UIView *subView in [viewObject subviews]) {
                
                if ([subView isKindOfClass:[RpDashBoardBadge class]] 
                    && [[(RpDashBoardBadge *)subView badgeIndex] isEqualToNumber:[NSNumber numberWithInt:badgeIndex]]) {                                                        
                    [subView removeFromSuperview];
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", [exception reason]);
    }

    
}

#pragma mark - Handle button events
-(IBAction)handleButtonPress:(id)sender{

    RpDashBoardButton *dashBoardButton = (RpDashBoardButton *) sender;
    
    [self hideButtonBadgedForIndex: [[dashBoardButton buttonIndex] intValue] ];

    _selectedItemIndex = [[dashBoardButton buttonIndex] intValue];
    
    if ([delegate respondsToSelector:@selector(dashboardDidPressButton:atIndex:)])
    {
		[delegate dashboardDidPressButton:self atIndex: [[dashBoardButton buttonIndex] intValue] ];
	}
    
}

/* 
 ------------------------------------------------------------------------------
 Layout all items into the dashboard
 ------------------------------------------------------------------------------
*/
-(void)layoutDashboarditems{
    
    numberOfPages = 0;
    
    NSUInteger collumns = numberOfCollumns;
    
    
    //counts the number of pages
    for (int i =0; i<numberOfItems; i++) {
        //next line
        if (collumns == 0) {
            initialPoint = CGPointMake(customInitialPoint.x, initialPoint.y + itemSize.height + verticalSpace);
            
            if ( (initialPoint.y + itemSize.height) > self.frame.size.height ) {
                //increments the number of pages
                ++numberOfPages;
                //resets the initial point
                initialPoint = CGPointMake(customInitialPoint.x, customInitialPoint.y);                
            }            
            collumns = numberOfCollumns;
        }        
        initialPoint = CGPointMake(initialPoint.x + itemSize.width + horizontalSpace, initialPoint.y);
        collumns--;
        
        if (i==0 && collumns > 0) {
            //increments the number of pages
            ++numberOfPages;
        }
    }

    //resets the number of collumns
    collumns = numberOfCollumns;

    //resets the initial point
    initialPoint = CGPointMake(customInitialPoint.x, customInitialPoint.y);
    
    
    //adjusts the pageControl and scrollView
    pageControl.numberOfPages = numberOfPages;
    scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    scrollView.contentSize = CGSizeMake(self.frame.size.width * numberOfPages, self.frame.size.height);
    
    //load the array with views (Pages for the scrollView)
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (int i = 0; i < numberOfPages; i++) {
        UIView * view = [[[UIView alloc] initWithFrame:scrollView.frame] autorelease];
        [controllers addObject: view ];
    }
    self.viewControllers = controllers;
    [controllers release];
    
    
    if ([self.viewControllers count] == 0) {
        return;
    }
    
    unsigned internNumberOfPages=0;
    
    for (int i =0; i<numberOfItems; i++) {
        
        //next line
        if (collumns == 0) {
            
            initialPoint = CGPointMake(customInitialPoint.x, initialPoint.y + itemSize.height + verticalSpace);
            
            
            if ( (initialPoint.y + itemSize.height) > self.frame.size.height ) {
                //increments the number of pages
                internNumberOfPages++;
                //resets the initial point
                initialPoint = CGPointMake(customInitialPoint.x, customInitialPoint.y);
            }
            collumns = numberOfCollumns;
        }
        
        CGRect newFrame = CGRectMake(initialPoint.x, initialPoint.y, itemSize.width, itemSize.height);
        
        //gets the button from Array
        RpDashBoardButton *button = [itemViews objectAtIndex:i];
        //attachs an Action to Button
        [button addTarget:self action:@selector(handleButtonPress:) forControlEvents:UIControlEventTouchUpInside];

        //call the cacheController to load the imageButton 
        //[self.cacheController prepareCachedImage:[button buttonImageURL] forThisIndex:[[button buttonIndex] intValue]];
        
        
        CGRect buttonLabelRect = CGRectMake(button.frame.origin.x-10,
                                            button.frame.origin.y + button.frame.size.height + 2,
                                            button.frame.size.width+20, 15.0f);
        
        //UILabel * buttonLabel = [[[UILabel alloc] initWithFrame:buttonLabelRect] autorelease];
        UILabel * buttonLabel = [labelViews objectAtIndex:i];
        [buttonLabel setFrame:buttonLabelRect];
        
        buttonLabel.numberOfLines = 1;
        buttonLabel.text = [dataSource dashboard:self titleForItemAtIndex:i];
        buttonLabel.textColor = [UIColor whiteColor];
        buttonLabel.backgroundColor = [UIColor clearColor];
        buttonLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.000f];
        buttonLabel.textAlignment = UITextAlignmentCenter;


        RpActivityIndicatorView * activityView = [[[RpActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        [activityView startAnimating];
        [activityView setHidesWhenStopped:YES];
        [activityView setActivityIndex:[button buttonIndex]];
        

        //allocs a badge for this button
        RpDashBoardBadge * badge = [[[RpDashBoardBadge alloc] 
                                     initWithFrame: CGRectMake(button.frame.origin.x + (button.frame.size.width - 5), button.frame.origin.y - 5, 20.0f, 20.0f) 
                                     andNumber: [button.badgeNumber intValue]] autorelease];
        [badge setBadgeIndex:button.buttonIndex];
        
        
        [(UIView *)[viewControllers objectAtIndex:internNumberOfPages] addSubview:button];
        [(UIView *)[viewControllers objectAtIndex:internNumberOfPages] addSubview:activityView];
        [(UIView *)[viewControllers objectAtIndex:internNumberOfPages] bringSubviewToFront:activityView];
        [(UIView *)[viewControllers objectAtIndex:internNumberOfPages] sendSubviewToBack:button];
        //adds the label
        [(UIView *)[viewControllers objectAtIndex:internNumberOfPages] addSubview:buttonLabel];
        //adds the badge
        [(UIView *)[viewControllers objectAtIndex:internNumberOfPages] addSubview:badge];
        [(UIView *)[viewControllers objectAtIndex:internNumberOfPages] bringSubviewToFront:badge];
        
        
        //only shows the badge if there's a number on it
        ([button.badgeNumber intValue] > 0)?[badge setHidden:NO]:[badge setHidden:YES];
        
        
        
        
        /*CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.2];*/
        
            [button setFrame:newFrame];
        

            [activityView setCenter:button.center];
            //adjust the label position
            [buttonLabel setFrame:CGRectMake(button.frame.origin.x - 10,
                                             button.frame.origin.y + button.frame.size.height + 1,
                                             button.frame.size.width+20, 15.0f)];
            
            //informs the delegate that the label was added for this dashboard item
            if ([delegate respondsToSelector:@selector(dashboardDidAddedLabelToItem:labelItem:atIndex:)])
            {
                [delegate dashboardDidAddedLabelToItem:self labelItem:buttonLabel atIndex:[[button buttonIndex] intValue]];
            }

        //[UIView commitAnimations];
        
        
        
        //correct the badge position
        [badge setFrame:CGRectMake(button.frame.origin.x + (button.frame.size.width - 5),
                                   button.frame.origin.y - 5,
                                   20.0f, 20.0f)];
        //NSLog(@"Badge Added: %0.2f, %0.2f", badge.frame.origin.x, badge.frame.origin.y);

        //call the cacheController to load the imageButton
        [self.cacheController prepareCachedImage:[button buttonImageURL] forThisIndex:[[button buttonIndex] intValue]];
        initialPoint = CGPointMake(initialPoint.x + newFrame.size.width + horizontalSpace, initialPoint.y);
        
        collumns--;
        
    }
    

}


-(void)reloadData{
    
	//remove old views
	for (UIView *view in itemViews)
    {
		[view removeFromSuperview];
	}
    for (UIView * view in self.viewControllers) {
        [view removeFromSuperview];
    }

    CGPoint tempPoint = CGPointZero;
    CGSize  tempSize = CGSizeZero;

    if ([self.dataSource respondsToSelector:@selector(dashboardInitialPoint)]) {
        tempPoint = [self.dataSource dashboardInitialPoint];                
    }
    

    if ([self.dataSource respondsToSelector:@selector(dashboardItemSize)]) {    
        tempSize = [self.dataSource dashboardItemSize];
    }
    
    if ( CGPointEqualToPoint(tempPoint, CGPointZero) ) {
        initialPoint = CGPointMake(kDefaultInitalXPoint, kDefaultInitalYPoint);
        customInitialPoint = CGPointMake(kDefaultInitalXPoint, kDefaultInitalYPoint);
    }else{
        initialPoint = tempPoint;
        customInitialPoint = tempPoint;
    }
    
    if (CGSizeEqualToSize(tempSize, CGSizeZero)) {
        itemSize     = CGSizeMake(kDefaultItemSize, kDefaultItemSize);
    }else{
        itemSize = tempSize;
    }    
    
    horizontalSpace = [dataSource amountOfHorizontalSpace:self];
    verticalSpace = [dataSource amountOfVerticalSpace:self];    
    numberOfCollumns = [dataSource numberOfCollumnsInDashBoard:self];

	
	//load new views
	numberOfItems = [dataSource numberOfItemsInDashBoard:self];
    
	self.itemViews = [NSMutableArray arrayWithCapacity:numberOfItems];
    self.labelViews = [NSMutableArray arrayWithCapacity:numberOfItems];
    
	for (NSUInteger i = 0; i < numberOfItems; i++)
    {
        UIButton *view = (UIButton *)[dataSource dashboard:self viewForItemAtIndex:i];
        if (view == nil)
        {
			view = [[[UIButton alloc] init] autorelease];
        }
        
		[(NSMutableArray *)itemViews addObject:view];
		[(NSMutableArray *)labelViews addObject: [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease] ];
	}
    
    
    [self layoutDashboarditems];
    
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
}

- (void)repaintLayout{
    if ([itemViews count] > 0) {
        
        CGPoint tempPoint = CGPointZero;
        CGSize  tempSize = CGSizeZero;
        
        
        if ([self.dataSource respondsToSelector:@selector(dashboardInitialPoint)]) {
            tempPoint = [self.dataSource dashboardInitialPoint];                
        }
        
        
        if ([self.dataSource respondsToSelector:@selector(dashboardItemSize)]) {    
            tempSize = [self.dataSource dashboardItemSize];
        }
        
        if ( CGPointEqualToPoint(tempPoint, CGPointZero) ) {
            initialPoint = CGPointMake(kDefaultInitalXPoint, kDefaultInitalYPoint);
            customInitialPoint = CGPointMake(kDefaultInitalXPoint, kDefaultInitalYPoint);
        }else{
            initialPoint = tempPoint;
            customInitialPoint = tempPoint;
        }
        
        if (CGSizeEqualToSize(tempSize, CGSizeZero)) {
            itemSize     = CGSizeMake(kDefaultItemSize, kDefaultItemSize);
        }else{
            itemSize = tempSize;
        }    
        
        horizontalSpace = [dataSource amountOfHorizontalSpace:self];
        verticalSpace = [dataSource amountOfVerticalSpace:self];    
        numberOfCollumns = [dataSource numberOfCollumnsInDashBoard:self];
        numberOfItems = [dataSource numberOfItemsInDashBoard:self];
        
        
        [self layoutDashboarditems];        
        [self loadScrollViewWithPage:self.pageControl.currentPage];
        
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * self.pageControl.currentPage;
        frame.origin.y = 0;
        [scrollView scrollRectToVisible:frame animated:YES];        
    }
    
}

- (UIView *)viewForItemAtIndex:(NSUInteger)index{
    
    BOOL activityStopped, buttonFound, badgeFound;
    
    activityStopped = NO;
    buttonFound = NO;
    badgeFound = NO;
    
    UIView * result;
    
    @try {
        //iterate through each page of scroller
        for (UIView *viewObject in self.viewControllers) {
            //iterate through each button of view
            for (UIView *subView in [viewObject subviews]) {
                //NSLog(@"WANT [%d] Object is: [%@]", index, [subView description] );
                
                if ([subView isKindOfClass:[RpActivityIndicatorView class]]
                    && [[(RpActivityIndicatorView *)subView activityIndex] isEqualToNumber:[NSNumber numberWithInt:index]]) {
                    
                    RpActivityIndicatorView * activity = (RpActivityIndicatorView *)subView;
                    NSLog(@"Stopping Activity");
                    [activity stopAnimating];
                    [[subView superview] sendSubviewToBack:subView];
                    activityStopped = YES;
                }
                
                if ([subView isKindOfClass:[RpDashBoardButton class]] ) {

                    if ([[(RpDashBoardButton *)subView buttonIndex] isEqualToNumber:[NSNumber numberWithInt:index]]) {
                        [[subView superview] bringSubviewToFront:subView];                        
                        result = subView;
                        buttonFound = YES;
                    }
                }
                
                if ([subView isKindOfClass:[RpDashBoardBadge class]] 
                    && [[(RpDashBoardBadge *)subView badgeIndex] isEqualToNumber:[NSNumber numberWithInt:index]]) {                                                        
                    [[subView superview] bringSubviewToFront:subView];
                    badgeFound = YES;
                }
                
                if ([subView isKindOfClass:[UILabel class]]) {
                    [[subView superview] bringSubviewToFront:subView];                    
                }
                
                
                
                if (activityStopped && buttonFound && badgeFound) {
                    return result;
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", [exception reason]);
    }
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{	
	if ((self = [super initWithCoder:aDecoder]))
    {
		[self setup];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)dealloc
{
    [itemViews          release];
    [labelViews         release];
    [pageControl        release];
    [scrollView         release];
    [viewControllers    release];
    [cacheController    release];
    [super              dealloc];
}


- (void)setDataSource:(id<RpDashBoardDataSource>)_dataSource
{
    dataSource = _dataSource;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}


// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}


#pragma mark - RpCacheControllerDelegate Method
- (void) appImageDidLoad:(NSData *)imageData forIndex:(int)index{
    
    @synchronized(imageData){
        //UIButton *dashBoardbutton = (UIButton *)[self.itemViews objectAtIndex:index];
        UIButton *dashBoardbutton = (UIButton *)[self viewForItemAtIndex:index];
        
        if (!dashBoardbutton) {
            NSLog(@"DashBoardButton NULO para o indice %d", index);
        }
        
        [dashBoardbutton setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        
//        [dashBoardbutton setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        
//        [[dashBoardbutton superview] bringSubviewToFront:dashBoardbutton];
        [[dashBoardbutton superview] sendSubviewToBack:dashBoardbutton];
    }
}

@end
