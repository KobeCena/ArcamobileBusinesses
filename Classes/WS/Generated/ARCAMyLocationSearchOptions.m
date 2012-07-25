/*
	ARCAMyLocationSearchOptions.h
	The implementation of properties and methods for the ARCAMyLocationSearchOptions object.
	Generated by SudzC.com
*/
#import "ARCAMyLocationSearchOptions.h"

@implementation ARCAMyLocationSearchOptions
	@synthesize range = _range;
	@synthesize page = _page;
	@synthesize order = _order;
	@synthesize categoryID = _categoryID;
	@synthesize keyword = _keyword;
	@synthesize latitude = _latitude;
	@synthesize longitude = _longitude;

	- (id) init
	{
		if(self = [super init])
		{
			self.range = nil;
			self.page = nil;
			self.order = nil;
			self.categoryID = nil;
			self.keyword = nil;

		}
		return self;
	}

	+ (ARCAMyLocationSearchOptions*) newWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return (ARCAMyLocationSearchOptions*)[[[ARCAMyLocationSearchOptions alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.range = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"range"]];
			self.page = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"page"]];
			self.order = [Soap getNodeValue: node withName: @"order"];
			self.categoryID = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"categoryID"]];
			self.keyword = [Soap getNodeValue: node withName: @"keyword"];
			self.latitude = [[Soap getNodeValue: node withName: @"latitude"] floatValue];
			self.longitude = [[Soap getNodeValue: node withName: @"longitude"] floatValue];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"MyLocationSearchOptions"];
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
		if (self.range != nil) [s appendFormat: @"<range>%@</range>", [NSString stringWithFormat: @"%@", self.range]];
		if (self.page != nil) [s appendFormat: @"<page>%@</page>", [NSString stringWithFormat: @"%@", self.page]];
		if (self.order != nil) [s appendFormat: @"<order>%@</order>", [[self.order stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.categoryID != nil) [s appendFormat: @"<categoryID>%@</categoryID>", [NSString stringWithFormat: @"%@", self.categoryID]];
		if (self.keyword != nil) [s appendFormat: @"<keyword>%@</keyword>", [[self.keyword stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<latitude>%@</latitude>", [NSString stringWithFormat: @"%f", self.latitude]];
		[s appendFormat: @"<longitude>%@</longitude>", [NSString stringWithFormat: @"%f", self.longitude]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[ARCAMyLocationSearchOptions class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}
	
	- (void) dealloc
	{
		if(self.range != nil) { [self.range release]; }
		if(self.page != nil) { [self.page release]; }
		if(self.order != nil) { [self.order release]; }
		if(self.categoryID != nil) { [self.categoryID release]; }
		if(self.keyword != nil) { [self.keyword release]; }
		[super dealloc];
	}

@end