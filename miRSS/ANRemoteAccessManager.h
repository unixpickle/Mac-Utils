//
//  ANRemoteAccessManager.h
//  miRSS
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANCommandCounter.h"
#import "ANRSSManager.h"
#import "RSSChannel.h"
#import "ANRSSProxy.h"


@interface ANRemoteAccessManager : NSObject <ANRemoteAccessManagerProtocol> {

}

+ (ANRemoteAccessManager *)sharedRemoteAccess;

@end
