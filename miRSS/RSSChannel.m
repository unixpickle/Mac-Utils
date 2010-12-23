//
//  RSSChannel.m
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RSSChannel.h"
#import "Debugging.h"

@implementation RSSChannel

@synthesize channelDescription;
@synthesize channelTitle;
@synthesize channelLink;
@synthesize items;
@synthesize xmlNode;
@synthesize isAtom;

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[self class]]) {
		RSSChannel * channel = object;
		if ([[channel channelTitle] isEqual:[self channelTitle]] && [[channel channelLink] isEqual:[self channelLink]]) {
			return YES;
		}
		return NO;
	} else {
		return [super isEqual:object];
	}
}

- (BOOL)articlesVary:(RSSChannel *)channel {
	NSArray * array1 = [self items];
	NSArray * array2 = [channel items];
	if ([array1 count] != [array2 count]) {
		return YES;
	}
	for (int i = 0; i < [array1 count]; i++) {
		RSSItem * item = [array1 objectAtIndex:i];
		RSSItem * item1 = [array2 objectAtIndex:i];
		if (![[item postGuid] isEqual:[item1 postGuid]]) {
			return YES;
		}
	}
	return NO;
}

+ (int)getUniqueID {
	static int uid = 192; // random number
	uid += 1;
	return uid;
}

- (int)uniqueID {
	return uniqueID;
}

- (void)setUniqueID:(int)uid {
	uniqueID = uid;
}

- (id)init {
	if (self = [super init]) {
		uniqueID = [RSSChannel getUniqueID];
		self.items = [NSMutableArray array];
		self.isAtom = YES;
	}
	return self;
}

- (id)initWithString:(NSString *)rssData {
	NSXMLDocument * document = [[NSXMLDocument alloc] initWithXMLString:rssData
																options:0
																  error:nil];
	if (!document) {
		return nil;
	}
	if (self = [self initWithXML:[document rootElement]]) {
		// we read it perfectly
		// uniqueID = [self getUniqueID];
	}
	return self;
}
- (id)initWithXML:(NSXMLNode *)rssDocument {
	if (self = [super init]) {
		// read the node
		self.isAtom = NO;
		self.xmlNode = rssDocument;
		uniqueID = [RSSChannel getUniqueID];
		NSMutableArray * itemArray = [[NSMutableArray alloc] init];
		for (int i = 0; i < [rssDocument childCount]; i++) {
			NSXMLNode * subnode = [[rssDocument children] objectAtIndex:i];
			// read the node name
			if ([[subnode name] isEqual:@"title"]) {
				if ([subnode kind] == NSXMLElementKind)
					self.channelTitle = [subnode stringValue];
				else {
					NSLog(@"Invalid node type for 'title' node: %d", [subnode kind]);
					[super dealloc];
					return nil;
				}
			}
			if ([[subnode name] isEqual:@"link"]) {
				if ([subnode kind] == NSXMLElementKind)
					self.channelLink = [subnode stringValue];
				else {
					NSLog(@"Invalid node type for 'link' node.");
					[super dealloc];
					return nil;
				}
			}
			if ([[subnode name] isEqual:@"description"]) {
				if ([subnode kind] == NSXMLElementKind)
					self.channelDescription = [subnode stringValue];
				else {
					NSLog(@"Invalid node type for 'description' node.");
					[super dealloc];
					return nil;
				}
			}
			if ([[subnode name] isEqual:@"item"]) {
				if ([subnode kind] == NSXMLElementKind) {
					RSSItem * item = [[RSSItem alloc] initWithXML:subnode];
					[itemArray addObject:item];
					[item setParentChannel:self];
					[item release];
				} else {
					NSLog(@"Invalid node type for 'item' node.");
					[super dealloc];
					return nil;
				}
			}
		}
		// don't make it global
		self.items = itemArray;
		[itemArray release];
	}
	return self;
}

- (id)initWithChannel:(RSSChannel *)channel {
	if (channel.isAtom) {
		if (self = [super init]) {
			self.isAtom = YES;
			if (channel.channelLink)
				self.channelLink = [NSString stringWithString:channel.channelLink];
			if (channel.channelTitle)
				self.channelTitle = [NSString stringWithString:channel.channelTitle];
			if (channel.channelDescription)
				self.channelDescription = [NSString stringWithString:channel.channelDescription];
			self.items = [NSMutableArray array];
			for (int i = 0; i < [[channel items] count]; i++) {
				RSSItem * item = [[RSSItem alloc] initWithItem:[[channel items] objectAtIndex:i]];
				item.parentChannel = self;
				[self.items addObject:item];
				[item release];
			}
		}
		return self;
	}
	if (self = [self initWithXML:[channel xmlNode]]) {
		// do nothing
		self.isAtom = NO;
	}
	return self;
}

- (id)description {
	NSMutableString * humanReadable = [NSMutableString string];
	[humanReadable appendFormat:@"{ "];
	int i = 0;
	for (RSSItem * item in self.items) {
		[humanReadable appendFormat:@"Item #%d: %@,\n  ", ++i, item];
	}
	[humanReadable appendFormat:@" }"];
	return humanReadable;
}

- (void)dealloc {
	self.channelLink = nil;
	self.channelTitle = nil;
	self.channelDescription = nil;
	self.xmlNode = nil;
	self.items = nil;
	[super dealloc];
}

@end
