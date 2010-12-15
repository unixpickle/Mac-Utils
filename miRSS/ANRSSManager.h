//
//  ANRSSManager.h
//  miRSS
//
//  Created by Alex Nichol on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RSSChannel.h"
#import "RSSFeed.h"
#import "RSSItem.h"
#import "ANTimeoutConnection.h"

// for channel dictionaries
#define ANRSSManagerChannelURLKey @"url"
#define ANRSSManagerChannelRSSChannelKey @"channel"
#define ANRSSManagerChannelReadGUIDSKey @"guids"
#define ANRSSManagerChannelWasFound @"found"
#define ANRSSManagerChannelWasModified @"changed"

@protocol ANRSSManagerDelegate

// one method
// not optional
// deal with it
- (void)articlesUpdated:(id)sender;

@end


@interface ANRSSManager : NSObject {
	NSMutableArray * channels;
	int channelCount;
	NSThread * fetchThread;
	NSLock * lock;
	id <ANRSSManagerDelegate> delegate;
	BOOL modified;
}

@property (nonatomic, assign) id <ANRSSManagerDelegate> delegate;

- (int)unreadInChannelIndex:(int)index lock:(BOOL)doLock;
- (BOOL)modified;
- (int)channelCount;
- (void)addRSSURL:(NSString *)url;
- (void)removeAtIndex:(int)i;
- (void)changeToRead:(int)channelIndex articleIndex:(int)article lock:(BOOL)doLock;
- (void)save;
- (void)lock;
- (void)unlock;
- (void)startFetchThread;
- (void)fetchThreadMethod;
// in order to call this
// you must call -lock before the call
// and -unlock after you are done
// using the result
- (NSDictionary *)channelAtIndex:(int)i;
@end
