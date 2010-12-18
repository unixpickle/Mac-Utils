//
//  ANRSSProxy.h
//  miRSS
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ANRemoteAccessManagerProtocol

- (NSNumber *)numberOfChannels;
- (NSArray *)channels;
- (NSArray *)channelURLs;
- (NSArray *)channelNames:(BOOL)defaultURLs;
- (void)addChannelURL:(NSString *)url;
- (void)removeChannelURL:(NSString *)url;
- (NSNumber *)totalUnread;

@end

@interface ANRSSProxy : NSObject {
	
}
+ (id<ANRemoteAccessManagerProtocol>)connectionProxy;
@end
