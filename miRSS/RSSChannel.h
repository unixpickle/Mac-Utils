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
	NSArray * items;
	NSString * channelDescription;
	NSString * channelLink;
	NSString * channelTitle;
	NSXMLNode * xmlNode;
	int uniqueID;
}
@property (nonatomic, retain) NSXMLNode * xmlNode;
@property (nonatomic, retain) NSArray * items;
@property (nonatomic, retain) NSString * channelDescription;
@property (nonatomic, retain) NSString * channelLink;
@property (nonatomic, retain) NSString * channelTitle;

- (BOOL)isEqual:(id)object;

- (int)uniqueID;
- (void)setUniqueID:(int)uid;
- (id)initWithChannel:(RSSChannel *)channel;
- (id)initWithString:(NSString *)rssData;
- (id)initWithXML:(NSXMLNode *)rssDocument;
@end
