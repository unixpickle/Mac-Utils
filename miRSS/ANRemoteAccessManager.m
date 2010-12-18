//
//  ANRemoteAccessManager.m
//  miRSS
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANRemoteAccessManager.h"


@implementation ANRemoteAccessManager

+ (ANRemoteAccessManager *)sharedRemoteAccess {
	static ANRemoteAccessManager * manager = nil;
	if (!manager) {
		manager = [[ANRemoteAccessManager alloc] init];
	}
	return manager;
}

- (id)init {
	if (self = [super init]) {
		NSConnection * theConnection = [[NSConnection alloc] init];
		[theConnection setRootObject:self];
		[theConnection setRequestTimeout:10];
		[theConnection setReplyTimeout:10];
		if (![theConnection registerName:@"ANRemoteAccessManager(miRSS)"]) {
			NSLog(@"Cannot register ANRemoteAccessManager.");
		}
	}
	return self;
}

- (NSNumber *)numberOfChannels {
	// read the number of channels
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	return [NSNumber numberWithInt:[manager channelCount]];
}
- (NSArray *)channels {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	// loop through and create custom dictionaries
	int count = [manager channelCount];
	NSMutableArray * returnValue = [[NSMutableArray alloc] init];
	[manager lock];
	for (int i = 0; i < count; i++) {
		NSDictionary * dictionary = [manager channelAtIndex:i];
		RSSChannel * channel = [dictionary objectForKey:ANRSSManagerChannelRSSChannelKey];
		// read and copy the keys
		NSString * channelURL = [NSString stringWithString:[dictionary objectForKey:ANRSSManagerChannelURLKey]];
		int unread = [manager unreadInChannelIndex:i lock:NO];
		NSString * channelName = @"";
		if ([channel channelTitle]) {
			channelName = [NSString stringWithString:[channel channelTitle]];
		}
		NSDictionary * channelDictionary = [NSDictionary dictionaryWithObjectsAndKeys:channelURL, @"url",
											channelName, @"name", [NSNumber numberWithInt:unread], @"unread", nil];
		[returnValue addObject:channelDictionary];
	}
	[manager unlock];
	[pool drain];
	return [returnValue autorelease];
}
- (NSArray *)channelURLs {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	// loop through and create custom dictionaries
	int count = [manager channelCount];
	NSMutableArray * returnValue = [[NSMutableArray alloc] init];
	[manager lock];
	for (int i = 0; i < count; i++) {
		NSDictionary * dictionary = [manager channelAtIndex:i];
		RSSChannel * channel = [dictionary objectForKey:ANRSSManagerChannelRSSChannelKey];
		// read and copy the keys
		NSString * channelURL = [NSString stringWithString:[dictionary objectForKey:ANRSSManagerChannelURLKey]];
		[returnValue addObject:channelURL];
	}
	[manager unlock];
	[pool drain];
	return [returnValue autorelease];
}
- (NSArray *)channelNames:(BOOL)defaultURLs {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	// loop through and create custom dictionaries
	int count = [manager channelCount];
	NSMutableArray * returnValue = [[NSMutableArray alloc] init];
	[manager lock];
	for (int i = 0; i < count; i++) {
		NSDictionary * dictionary = [manager channelAtIndex:i];
		RSSChannel * channel = [dictionary objectForKey:ANRSSManagerChannelRSSChannelKey];
		// read and copy the keys
		if ([channel channelTitle]) {
			NSString * channelName = [NSString stringWithString:[channel channelTitle]];
			[returnValue addObject:channelName];
		} else {
			if (defaultURLs) {
				NSString * channelURL = [NSString stringWithString:[dictionary objectForKey:ANRSSManagerChannelURLKey]];
				[returnValue addObject:channelURL];
			} else {
				[returnValue addObject:@""];
			}
		}
	}
	[manager unlock];
	[pool drain];
	return [returnValue autorelease];
}
- (void)addChannelURL:(NSString *)url {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	
	[manager addRSSURL:url];
	
	[pool drain];
}
- (void)removeChannelURL:(NSString *)url {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	
	int count = [manager channelCount];
	int index = -1;
	// find the URL
	[manager lock];

	for (int i = 0; i < count; i++) {
		NSDictionary * dictionary = [manager channelAtIndex:i];
		// read and copy the keys
		NSString * channelURL = [NSString stringWithString:[dictionary objectForKey:ANRSSManagerChannelURLKey]];
		if ([channelURL isEqual:url]) {
			index = i;
			break;
		}
	}
	
	[manager unlock];
	
	if (index > -1) {
		[manager removeAtIndex:index];
	}
	
	[pool drain];
}
- (NSNumber *)totalUnread {
	NSArray * list = [self channels];
	int total = 0;
	for (NSDictionary * dict in list) {
		total += [[dict objectForKey:@"unread"] intValue];
	}
	return [NSNumber numberWithInt:total];
}

- (void)dealloc {
	[[NSPortNameServer systemDefaultPortNameServer] removePortForName:@"ANRemoteAccessManager(miRSS)"];
	[super dealloc];
}

@end
