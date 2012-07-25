/*
	ARCACategories.h
	The implementation of properties and methods for the ARCACategories object.
	Generated by SudzC.com
*/
#import "ARCACategories.h"

@implementation ARCACategories
	@synthesize _id = __id;
	@synthesize title = _title;
	@synthesize icon = _icon;
	@synthesize lastUpdate = _lastUpdate;

	- (id) init
	{
		if(self = [super init])
		{
			self._id = nil;
			self.title = nil;
			self.icon = nil;
			self.lastUpdate = nil;

		}
		return self;
	}

	+ (ARCACategories*) newWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return (ARCACategories*)[[[ARCACategories alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self._id = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"id"]];
			self.title = [Soap getNodeValue: node withName: @"title"];
			self.icon = [Soap getNodeValue: node withName: @"icon"];
			self.lastUpdate = [Soap dateFromString: [Soap getNodeValue: node withName: @"lastUpdate"]];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"Categories"];
	}
  
	- (NSMutableString*) serialize: (NSString*) nodeName
	{
		NSMutableString* s = [[NSMutableString alloc] init];
		[s appendFormat: @"<%@", nodeName];
		[s appendString: [self serializeAttributes]];
		[s appendString: @">"];
		[s appendString: [self serializeElements]];
		[s appendFormat: @"</%@>", nodeName];
		return [s autorelease];
	}
	
	- (NSMutableString*) serializeElements
	{
		NSMutableString* s = [super serializeElements];
		if (self._id != nil) [s appendFormat: @"<id>%@</id>", [NSString stringWithFormat: @"%@", self._id]];
		if (self.title != nil) [s appendFormat: @"<title>%@</title>", [[self.title stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.icon != nil) [s appendFormat: @"<icon>%@</icon>", [[self.icon stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.lastUpdate != nil) [s appendFormat: @"<lastUpdate>%@</lastUpdate>", [Soap getDateString: self.lastUpdate]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[ARCACategories class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}
	
	- (void) dealloc
	{
		if(self._id != nil) { [self._id release]; }
		if(self.title != nil) { [self.title release]; }
		if(self.icon != nil) { [self.icon release]; }
		if(self.lastUpdate != nil) { [self.lastUpdate release]; }
		[super dealloc];
	}

@end