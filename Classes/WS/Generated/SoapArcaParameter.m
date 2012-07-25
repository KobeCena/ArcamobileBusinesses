//
//  SoapArcaParameter.m
//  SudzCExamples
//
//  Created by Ricardo Silva on 3/30/12.
//  Copyright (c) 2012 Arca Solutions Inc. All rights reserved.
//

#import "SoapArcaParameter.h"
#import "Soap.h"

@implementation SoapArcaParameter

-(NSString*)xml{
	if(self.value == nil) {
		return [NSString stringWithFormat:@"<%@ xsi:nil=\"true\"/>", name];
	} else {
        return [NSString stringWithFormat:@"<%@>%@</%@>", name, [Soap serialize: self.value], name];
	}
}

@end
