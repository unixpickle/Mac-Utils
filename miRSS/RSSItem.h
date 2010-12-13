//
//  RSSItem.h
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RSSItem : NSObject {
	NSDate * postDate;
	NSString * postTitle;
	NSString * postGuid;
	NSString * postContent;
	NSString * postURL;
}

@property (nonatomic, retain) NSDate * postDate;
@property (nonatomic, retain) NSString * postTitle;
@property (nonatomic, retain) NSString * postGuid;
@property (nonatomic, retain) NSString * postContent;
@property (nonatomic, retain) NSString * postURL;

- (id)initWithXML:(NSXMLNode *)document;

@end
