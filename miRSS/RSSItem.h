//
//  RSSItem.h
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RSSChannel.h"

@class RSSChannel;

@interface RSSItem : NSObject {
	RSSChannel * parentChannel;
	NSDate * postDate;
	NSString * postTitle;
	NSString * postGuid;
	NSString * postContent;
	NSString * postURL;
	BOOL isRead;
}

@property (readwrite) BOOL isRead;
@property (nonatomic, assign) RSSChannel * parentChannel;
@property (nonatomic, retain) NSDate * postDate;
@property (nonatomic, retain) NSString * postTitle;
@property (nonatomic, retain) NSString * postGuid;
@property (nonatomic, retain) NSString * postContent;
@property (nonatomic, retain) NSString * postURL;

- (id)initWithItem:(RSSItem *)item;
- (id)initWithXML:(NSXMLNode *)document;
- (id)initWithAtom:(NSXMLElement *)elem;

@end
