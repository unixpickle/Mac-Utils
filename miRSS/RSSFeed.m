//
//  RSSFeed.m
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RSSFeed.h"


@implementation RSSFeed

@synthesize rssVersion, rssChannels;

- (id)initWithString:(NSString *)rssString {
	if (self = [super init]) {
		// parse the XML
		NSXMLDocument * feed = [[NSXMLDocument alloc] initWithXMLString:rssString
																options:0
																  error:nil];
		if (!feed) {
			NSLog(@"Could not parse XML.");
			[super dealloc];
			self = nil;
			return nil;
		}
		
		// read the RSS
		NSArray * rssElements = [feed children];
		for (int i = 0; i < [rssElements count]; i++) {
			NSXMLNode * node = [rssElements objectAtIndex:i];
			if ([[node name] isEqual:@"rss"]) {
				rssElements = [NSArray arrayWithObject:node];
				break;
			}
		}
		if ([rssElements count] != 1) {
			NSLog(@"Invalid number off RSS elements: %d", [rssElements count]);
			[feed release];
			[super dealloc];
			self = nil;
			return self;
		}
		
		NSMutableArray * channelList = [[NSMutableArray alloc] init];
		NSXMLElement * rssElement = [rssElements lastObject];
		for (int i = 0; i < [rssElement childCount]; i++) {
			NSXMLNode * node = [[rssElement children] objectAtIndex:i];
			if ([[node name] isEqual:@"channel"]) {
				// we got one
				RSSChannel * channel = [[RSSChannel alloc] initWithXML:node];
				[channelList addObject:channel];
				[channel release];
			}
		}
		
		// make sure they can't modify it
		self.rssChannels = [NSArray arrayWithArray:channelList];
		[channelList release];
		
		[feed release];
	}
	return self;
}

- (id)description {
	NSMutableString * humanReadable = [NSMutableString string];
	int i = 0;
	for (RSSChannel * channel in self.rssChannels) {
		// print it
		[humanReadable appendFormat:@"Channel #%d: %@", ++i, channel];
	}
	return humanReadable;
}

- (void)dealloc {
	self.rssChannels = nil;
	[super dealloc];
}

@end
