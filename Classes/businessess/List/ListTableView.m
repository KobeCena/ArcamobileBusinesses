//
//  ListTableView.m
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 8/19/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "ListTableView.h"

@implementation ListTableView

@synthesize searchTextField;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        //initialization code here.
    }
    return self;
}



- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
	//catches the UIView that received the event

    if ([[self searchTextField] isFirstResponder]) {
        [[self searchTextField] resignFirstResponder];
    }
    

    [self becomeFirstResponder];
    
	return [super hitTest:point withEvent:event];;
}

- (void)dealloc {
    if (searchTextField) {
        searchTextField.delegate = nil;
        [searchTextField release];
    }

    [super dealloc];
}

@end
