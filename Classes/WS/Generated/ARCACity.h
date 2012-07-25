/*
	ARCACity.h
	The interface definition of properties and methods for the ARCACity object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface ARCACity : SoapObject
{
	NSDecimalNumber* __id;
	NSDecimalNumber* _location_3;
	NSDecimalNumber* _location_2;
	NSDecimalNumber* _location_1;
	NSString* _name;
	NSString* _abbreviation;
	NSString* _friendly_url;
	NSString* _seo_description;
	NSString* _seo_keywords;
	
}
		
	@property (retain, nonatomic) NSDecimalNumber* _id;
	@property (retain, nonatomic) NSDecimalNumber* location_3;
	@property (retain, nonatomic) NSDecimalNumber* location_2;
	@property (retain, nonatomic) NSDecimalNumber* location_1;
	@property (retain, nonatomic) NSString* name;
	@property (retain, nonatomic) NSString* abbreviation;
	@property (retain, nonatomic) NSString* friendly_url;
	@property (retain, nonatomic) NSString* seo_description;
	@property (retain, nonatomic) NSString* seo_keywords;

	+ (ARCACity*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
