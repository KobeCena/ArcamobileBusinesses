/*
	ARCAStandardReturn.h
	The implementation of properties and methods for the ARCAStandardReturn object.
	Generated by SudzC.com
*/
#import "ARCAStandardReturn.h"

@implementation ARCAStandardReturn
	@synthesize Status = _Status;
	@synthesize Code = _Code;
	@synthesize Message = _Message;

	- (id) init
	{
		if(self = [super init])
		{
			self.Code = nil;
			self.Message = nil;

		}
		return self;
	}

	+ (ARCAStandardReturn*) newWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return (ARCAStandardReturn*)[[[ARCAStandardReturn alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.Status = [[Soap getNodeValue: node withName: @"Status"] boolValue];
			self.Code = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"Code"]];
			self.Message = [Soap getNodeValue: node withName: @"Message"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"StandardReturn"];
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
		[s appendFormat: @"<Status>%@</Status>", (self.Status)?@"true":@"false"];
		if (self.Code != nil) [s appendFormat: @"<Code>%@</Code>", [NSString stringWithFormat: @"%@", self.Code]];
		if (self.Message != nil) [s appendFormat: @"<Message>%@</Message>", [[self.Message stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[ARCAStandardReturn class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}
	
	- (void) dealloc
	{
		if(self.Code != nil) { [self.Code release]; }
		if(self.Message != nil) { [self.Message release]; }
		[super dealloc];
	}

@end
