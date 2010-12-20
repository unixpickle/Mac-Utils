//
//  ANRSSFeed.m
//  miRSS
//
//  Created by Alex Nichol on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANRSSFeed.h"


@implementation ANRSSFeed

- (id)init {
	if (self = [super init]) {
		index = -1;
		// index = [RSSChannel getUniqueID];
		[self setIndexnumber:[RSSChannel getUniqueID]];
	}
	return self;
}

+ (NSMutableDictionary *)feeds {
	static NSMutableDictionary * feeds = nil;
	if (!feeds) {
		feeds = [[NSMutableDictionary alloc] init];
	}
	return feeds;
}

- (NSString *)rsstitle {
	return title;
}
- (NSNumber *)indexnumber {
	return [NSNumber numberWithInt:index];
}
- (NSString *)rssurl {
	return url;
}

- (void)setRsstitle:(NSString *)newTitle {
	[title release];
	title = [newTitle retain];
}
- (void)setIndexnumber:(int)_index {
	if ([[ANRSSFeed feeds] objectForKey:[NSNumber numberWithInt:index]] && index > -1) {
		[[ANRSSFeed feeds] removeObjectForKey:[NSNumber numberWithInt:index]];
	}
	index = _index;
	[[ANRSSFeed feeds] setObject:self forKey:[NSNumber numberWithInt:index]];
}
- (void)setRssurl:(NSString *)_url {
	[url release];
	// NSLog(@"Setting url: %@", _url);
	url = [_url retain];
}

- (void)setUnread:(NSNumber *)_unread {
	nunread = [_unread intValue];
}

- (NSNumber *)unread {
	return [NSNumber numberWithInt:nunread];
}

- (NSNumber *)uniqueID {
	return [self indexnumber];
}
- (void)setUniqueID:(NSNumber *)string {
	[self setIndexnumber:[string intValue]];
}


- (id)objectSpecifier {
	NSUniqueIDSpecifier * specifier = [[NSUniqueIDSpecifier alloc] initWithContainerClassDescription:(NSScriptClassDescription *)[NSApp classDescription]
																			containerSpecifier:[NSApp objectSpecifier]
																						   key:@"rssfeeds"
																						 uniqueID:[self indexnumber]];
	return [specifier autorelease];
}

- (void)dealloc {
	[title release];
	[url release];
	[super dealloc];
}

@end
