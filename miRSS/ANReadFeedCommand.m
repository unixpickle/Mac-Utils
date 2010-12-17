//
//  ANReadFeedCommand.m
//  miRSS
//
//  Created by Alex Nichol on 12/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANReadFeedCommand.h"


@implementation ANReadFeedCommand

@synthesize feed;

- (id)executeCommand {
	// do the stuff with the index
	
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	int count = [manager channelCount];
	int uid = -1;
	[manager lock];
	
	for (int i = 0; i < count; i++) {
		NSDictionary * dict = [manager channelAtIndex:i];
		RSSChannel * channel = [dict objectForKey:ANRSSManagerChannelRSSChannelKey];
		if ([[channel channelLink] isEqual:[self.feed rssurl]]) {
			// we have a match
			uid = [channel uniqueID];
		}
	}
	
	[manager unlock];
	
	if (uid > 0) {
		NSMenuItem * item = [[NSMenuItem alloc] init];
		[item setTag:uid];
		id appDelegate = [[NSApplication sharedApplication] delegate];
		// open it
		[appDelegate performSelector:@selector(showFeed:) withObject:item];
		[item release];
	} else {
		NSLog(@"RSS Feed no longer in the list, but was opened by a script.");
	}
	
	return [NSNull null];
}

- (void)setArguments:(NSDictionary *)args {
	// NSLog(@"Set arguments: %@", args);
	if ([args objectForKey:@"Feed"]) {
		// find the feed
		NSUniqueIDSpecifier * spec = [args objectForKey:@"Feed"];
		//we got the index
		int index = [[spec uniqueID] intValue];
		self.feed = [[ANRSSFeed feeds] objectForKey:[NSNumber numberWithInt:index]];
		if (!self.feed) {
			// FFFFFFFFFFFFFFFUUUUUUUUUUUUU
			NSLog(@"No feed for index: %d", index);
			NSException * ex = [NSException exceptionWithName:@"FeedNotFound"
													   reason:[NSString stringWithFormat:@"No feed for index: %d", index]
													 userInfo:nil];
			@throw ex;
		}
	}
}

- (id)initWithCommandDescription:(NSScriptCommandDescription *)description {
	if (self = [super initWithCommandDescription:description]) {
		// read the description
	}
	return self;
}

- (void)dealloc {
	self.feed = nil;
	[super dealloc];
}


@end
