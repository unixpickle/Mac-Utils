//
//  ANRSSProxy.m
//  miRSS
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANRSSProxy.h"


@implementation ANRSSProxy

+ (id<ANRemoteAccessManagerProtocol>)connectionProxy {
	id theProxy;
	theProxy = [[NSConnection
				 rootProxyForConnectionWithRegisteredName:@"ANRemoteAccessManager(miRSS)"
				 host:nil] retain];
	[theProxy setProtocolForProxy:@protocol(ANRemoteAccessManagerProtocol)];
	return [theProxy autorelease];
}

@end
