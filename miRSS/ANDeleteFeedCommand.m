//
//  ANDeleteFeedCommand.m
//  miRSS
//
//  Created by Alex Nichol on 12/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANDeleteFeedCommand.h"


@implementation ANDeleteFeedCommand

@synthesize feed;

- (id)executeCommand {
	// delete it
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	int index = -1;
	int count = [manager channelCount];
	[manager lock];
	
	for (int i = 0; i < count; i++) {
		NSDictionary * dict = [manager channelAtIndex:i];
		NSString * url = [dict objectForKey:ANRSSManagerChannelURLKey];
		NSLog(@"URL: %@", [self.feed rssurl]);
		if ([url isEqual:[self.feed rssurl]]) {
			// we have a match
			index = i;
			break;
		}
	}
	
	[manager unlock];
	
	if (index > -1) {
		// here we will delete it
		[manager removeAtIndex:index];
	}
	
	return nil;
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

@end
