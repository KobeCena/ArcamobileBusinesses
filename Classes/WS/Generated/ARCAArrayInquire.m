/*
	ARCAArrayInquire.h
	The implementation of properties and methods for the ARCAArrayInquire object.
	Generated by SudzC.com
*/
#import "ARCAArrayInquire.h"

@implementation ARCAArrayInquire
	@synthesize typeofinquire = _typeofinquire;
	@synthesize imageURL = _imageURL;
	@synthesize title = _title;
	@synthesize sku = _sku;
	@synthesize rating = _rating;

	- (id) init
	{
		if(self = [super init])
		{
			self.typeofinquire = nil;
			self.imageURL = nil;
			self.title = nil;
			self.sku = nil;
			self.rating = nil;

		}
		return self;
	}

	+ (ARCAArrayInquire*) newWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return (ARCAArrayInquire*)[[[ARCAArrayInquire alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.typeofinquire = [Soap getNodeValue: node withName: @"typeofinquire"];
			self.imageURL = [Soap getNodeValue: node withName: @"imageURL"];
			self.title = [Soap getNodeValue: node withName: @"title"];
			self.sku = [Soap getNodeValue: node withName: @"sku"];
			self.rating = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"rating"]];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"ArrayInquire"];
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
		if (self.typeofinquire != nil) [s appendFormat: @"<typeofinquire>%@</typeofinquire>", [[self.typeofinquire stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.imageURL != nil) [s appendFormat: @"<imageURL>%@</imageURL>", [[self.imageURL stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.title != nil) [s appendFormat: @"<title>%@</title>", [[self.title stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.sku != nil) [s appendFormat: @"<sku>%@</sku>", [[self.sku stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.rating != nil) [s appendFormat: @"<rating>%@</rating>", [NSString stringWithFormat: @"%@", self.rating]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[ARCAArrayInquire class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}
	
	- (void) dealloc
	{
		if(self.typeofinquire != nil) { [self.typeofinquire release]; }
		if(self.imageURL != nil) { [self.imageURL release]; }
		if(self.title != nil) { [self.title release]; }
		if(self.sku != nil) { [self.sku release]; }
		if(self.rating != nil) { [self.rating release]; }
		[super dealloc];
	}

@end
