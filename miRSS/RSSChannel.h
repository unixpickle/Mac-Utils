//
//  RSSChannel.h
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RSSItem.h"


@interface RSSChannel : NSObject {
	NSMutableArray * items;
	NSString * channelDescription;
	NSString * channelLink;
	NSString * channelTitle;
	NSXMLNode * xmlNode;
	int uniqueID;
	BOOL isAtom;
}
@property (readwrite) BOOL isAtom;
@property (nonatomic, retain) NSXMLNode * xmlNode;
@property (nonatomic, retain) NSMutableArray * items;
@property (nonatomic, retain) NSString * channelDescription;
@property (nonatomic, retain) NSString * channelLink;
@property (nonatomic, retain) NSString * channelTitle;

- (BOOL)isEqual:(id)object;
- (BOOL)articlesVary:(RSSChannel *)channel;

+ (int)getUniqueID;

- (int)uniqueID;
- (void)setUniqueID:(int)uid;
- (id)init;
- (id)initWithChannel:(RSSChannel *)channel;
- (id)initWithString:(NSString *)rssData;
- (id)initWithXML:(NSXMLNode *)rssDocument;
@end
