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
	int uniqueID;
}

@property (nonatomic, retain) NSArray * items;
@property (nonatomic, retain) NSString * channelDescription;
@property (nonatomic, retain) NSString * channelLink;
@property (nonatomic, retain) NSString * channelTitle;

- (int)uniqueID;
- (void)setUniqueID:(int)uid;
- (id)initWithString:(NSString *)rssData;
- (id)initWithXML:(NSXMLNode *)rssDocument;
@end
