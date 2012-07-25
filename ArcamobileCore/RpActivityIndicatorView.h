//
//  RpActivityIndicatorView.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/29/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RpActivityIndicatorView : UIActivityIndicatorView {
    NSNumber *activityIndex;    
}


@property (nonatomic, retain) NSNumber *activityIndex;
@end
