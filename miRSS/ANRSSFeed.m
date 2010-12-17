//
//  ANRSSFeed.m
//  miRSS
//
//  Created by Alex Nichol on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANRSSFeed.h"


@implementation ANRSSFeed

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
	index = _index;
}
- (void)setRssurl:(NSString *)_url {
	[url release];
	url = [_url retain];
}


- (id)objectSpecifier {
	NSIndexSpecifier * specifier = [[NSIndexSpecifier alloc] initWithContainerClassDescription:(NSScriptClassDescription *)[NSApp classDescription]
																			containerSpecifier:[NSApp objectSpecifier]
																						   key:@"rssfeeds"
																						 index:[[self indexnumber] intValue]];
	return [specifier autorelease];
}

- (void)dealloc {
	[title release];
	[url release];
	[super dealloc];
}

@end
