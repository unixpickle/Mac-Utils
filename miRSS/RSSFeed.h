//
//  RSSFeed.h
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RSSChannel.h"


@interface RSSFeed : NSObject {
	NSArray * rssChannels;
	float rssVersion;
}

@property (nonatomic, retain) NSArray * rssChannels;
@property (readwrite) float rssVersion;

// applescript
- (int)itemCount;

- (id)initWithString:(NSString *)rssString;

@end
