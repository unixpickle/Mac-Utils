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

+ (NSDictionary *)elementAttributes:(NSXMLElement *)node {
	NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
	for (int j = 0; j < [[node attributes] count]; j++) {
		NSXMLNode * linkAttribute = [[node attributes] objectAtIndex:j];
		// read the name
		if ([linkAttribute kind] == NSXMLAttributeKind) {
			// got rel
			[attributes setObject:[linkAttribute stringValue] forKey:[linkAttribute name]];
		}
	}
	return attributes;
}

+ (RSSChannel *)atomChannelWithNode:(NSXMLElement *)rssElement {
	RSSChannel * channel = [[RSSChannel alloc] init];
	// deal with the channel
	for (int i = 0; i < [rssElement childCount]; i++) {
		NSXMLNode * node = [[rssElement children] objectAtIndex:i];
		// read the title
		if ([[node name] isEqual:@"link"]) {
			// got the URL
			if ([node kind] == NSXMLElementKind) {
				// read the subnodes
				NSString * href = nil;
				NSString * rel = nil;
				NSDictionary * attributes = [RSSFeed elementAttributes:(NSXMLElement *)node];
				// read it
				href = [attributes objectForKey:@"href"];
				rel = [attributes objectForKey:@"rel"];
				if ([rel isEqual:@"self"]) {
					[channel setChannelLink:href];
					// NSLog(@"Link: %@", href);
				}
			} else {
				NSLog(@"Invalid type for 'link' element");
			}
		} else if ([[node name] isEqual:@"title"]) {
			[channel setChannelTitle:[node stringValue]];
		} else if ([[node name] isEqual:@"subtitle"]) {
			[channel setChannelDescription:[node stringValue]];
		} else if ([[node name] isEqual:@"entry"]) {
			// read the entry here
			[[channel items] addObject:[[[RSSItem alloc] initWithAtom:(NSXMLElement *)node] autorelease]];
		}
	}
	return [channel autorelease];
}

- (int)itemCount {
	if ([rssChannels count] < 1) {
		return -1;
	}
	return [(NSArray *)[(RSSChannel *)[rssChannels objectAtIndex:0] items] count];
}

- (id)initWithString:(NSString *)rssString {
	if (self = [super init]) {
		// parse the XML
		NSXMLDocument * feed = [[NSXMLDocument alloc] initWithXMLString:rssString
																options:NSXMLDocumentTidyXML
																  error:nil];
		if (!feed) {
			NSLog(@"Could not parse XML.");
			[super dealloc];
			self = nil;
			return nil;
		}
		
		// read the RSS
		BOOL isAtom = NO;
		NSArray * rssElements = [feed children];
		for (int i = 0; i < [rssElements count]; i++) {
			NSXMLNode * node = [rssElements objectAtIndex:i];
			if ([[node name] isEqual:@"rss"]) {
				rssElements = [NSArray arrayWithObject:node];
				break;
			} else if ([[node name] isEqual:@"feed"]) {
				//NSLog(@"Found atom feed");
				rssElements = [NSArray arrayWithObject:node];
				isAtom = YES;
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
		
		if (isAtom) {
			// create atom channels
			NSXMLElement * rssElement = [rssElements lastObject];
			// read it
			RSSChannel * channel = [RSSFeed atomChannelWithNode:rssElement];
			[channelList addObject:channel];
		} else {
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
