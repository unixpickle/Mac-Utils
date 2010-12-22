//
//  RSSItem.m
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RSSItem.h"
#import "RSSFeed.h"

@implementation RSSItem

@synthesize postDate;
@synthesize postTitle;
@synthesize postGuid;
@synthesize postContent;
@synthesize postURL;
@synthesize parentChannel;
@synthesize isRead;

- (id)initWithItem:(RSSItem *)item {
	// create a copy
	// parentChannel needs to be set seperately
	if (self = [super init]) {
		self.postDate = [NSDate dateWithTimeIntervalSince1970:[[item postDate] timeIntervalSince1970]];
		if (item.postTitle)
			self.postTitle = [NSString stringWithString:[item postTitle]];
		if (item.postGuid)
			self.postGuid = [NSString stringWithString:[item postGuid]];
		if (item.postContent)
			self.postContent = [NSString stringWithString:[item postContent]];
		if (item.postURL)
			self.postURL = [NSString stringWithString:[item postURL]];
		self.isRead = item.isRead;
	}
	return self;
}

- (id)initWithXML:(NSXMLNode *)document {
	if (self = [super init]) {
		// read the XML data here
		isRead = NO;
		for (NSXMLNode * information in [document children]) {
			if ([[information name] isEqual:@"title"] &&
				[information kind] == NSXMLElementKind) {
				// set the title
				self.postTitle = [information stringValue];
			}
			if ([[information name] isEqual:@"link"] &&
				[information kind] == NSXMLElementKind) {
				// set the title
				self.postURL = [information stringValue];
			}
			if ([[information name] isEqual:@"pubDate"] &&
				[information kind] == NSXMLElementKind) {
				// set the title
				NSString * dateString = [information stringValue];
				NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
				//Sat, 11 Dec 2010 17:16:16 EST
				//Sat, 11 Dec 2010 16:07:08 -0700
				[formatter setDateFormat:@"E, dd LLL yyyy HH:mm:ss Z"];
				self.postDate = [formatter dateFromString:dateString];
				if (!self.postDate) {
					[formatter setDateFormat:@"E, dd LLL yyyy HH:mm:ss zzzz"];
					self.postDate = [formatter dateFromString:dateString];
				}
				[formatter release];
			}
			if ([[information name] isEqual:@"guid"] &&
				[information kind] == NSXMLElementKind) {
				// set the title
				self.postGuid = [information stringValue];
			}
			if ([[information name] isEqual:@"description"] &&
				[information kind] == NSXMLElementKind) {
				// set the title
				self.postContent = [information stringValue];
			}
			if (!self.postGuid) {
				self.postGuid = self.postURL;
			}
		}
	}
	return self;
}

- (id)initWithAtom:(NSXMLElement *)elem {
	if (self = [super init]) {
		// read the atom
		for (int i = 0; i < [elem childCount]; i++) {
			NSXMLNode * node = [elem childAtIndex:i];
			if ([node kind] == NSXMLElementKind) {
				// read it
				if ([[node name] isEqual:@"title"]) {
					[self setPostTitle:[node stringValue]];
					self.postTitle = [self.postTitle stringByReplacingOccurrencesOfString:@"\n" 
																			   withString:@""];
				} else if ([[node name] isEqual:@"summary"]) {
					[self setPostContent:[node stringValue]];
				} else if ([[node name] isEqual:@"link"]) {
					NSDictionary * props = [RSSFeed elementAttributes:(NSXMLElement *)node];
					NSString * href = [props objectForKey:@"href"];
					// use it
					[self setPostURL:href];
					[self setPostGuid:href];
				}
			}
		}
	}
	return self;
}

- (id)description {
	return [NSMutableString stringWithFormat:@"%@: %@", self.postDate, [self.postContent substringToIndex:([self.postContent length] > 50 ? 50 : [self.postContent length]-1)]];
}

- (void)dealloc {
	self.postDate = nil;
	self.postTitle = nil;
	self.postGuid = nil;
	self.postContent = nil;
	self.postURL = nil;
	[super dealloc];
}

@end