//
//  RecordInstall.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/22/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

@interface RecordInstall : NSObject {
    
    NSURLConnection * _connection;
    
}

-(void)callServerAndRegisterInstallation:(NSString*)uniqueID;
@end
