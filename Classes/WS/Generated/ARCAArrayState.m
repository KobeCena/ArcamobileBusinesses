/*
	ARCAArrayState.h
	The implementation of properties and methods for the ARCAArrayState array.
	Generated by SudzC.com
*/
#import "ARCAArrayState.h"
#import "ARCAState.h"

@implementation ARCAArrayState

	+ (id) newWithNode: (CXMLNode*) node
	{
		return [[[ARCAArrayState alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node
	{
		if(self = [self init]) {
			for(CXMLElement* child in [node children])
			{
				ARCAState* value = [[ARCAState newWithNode: child] object];
				if(value != nil) {
					[self addObject: value];
				}
			}
		}
		return self;
	}
	
	+ (NSMutableString*) serialize: (NSArray*) array
	{
		NSMutableString* s = [NSMutableString string];
		for(id item in array) {
			[s appendString: [item serialize: @"State"]];
		}
		return s;
	}
@end
