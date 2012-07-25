/*
	ARCAResultsInfo.h
	The interface definition of properties and methods for the ARCAResultsInfo object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface ARCAResultsInfo : SoapObject
{
	NSDecimalNumber* _AmountOfPages;
	NSString* _BaseLatitude;
	NSString* _BaseLongitude;
	NSDecimalNumber* _ActualPage;
	NSDate* _LastUpdate;
	
}
		
	@property (retain, nonatomic) NSDecimalNumber* AmountOfPages;
	@property (retain, nonatomic) NSString* BaseLatitude;
	@property (retain, nonatomic) NSString* BaseLongitude;
	@property (retain, nonatomic) NSDecimalNumber* ActualPage;
	@property (retain, nonatomic) NSDate* LastUpdate;

	+ (ARCAResultsInfo*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
