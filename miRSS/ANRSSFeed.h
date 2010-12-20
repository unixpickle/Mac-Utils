//
//  ANRSSFeed.h
//  miRSS
//
//  Created by Alex Nichol on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RSSChannel.h"


@interface ANRSSFeed : NSObject {
	NSString * title;
	NSString * url;
	int index;
	int nunread;
}
+ (NSMutableDictionary *)feeds;
- (void)setRsstitle:(NSString *)newTitle;
- (void)setIndexnumber:(int)index;
- (void)setRssurl:(NSString *)url;
- (void)setUnread:(NSNumber *)_unread;
- (NSNumber *)uniqueID;
- (void)setUniqueID:(NSNumber *)string;
- (NSString *)rsstitle;
- (NSString *)rssurl;
- (NSNumber *)indexnumber;
- (NSNumber *)unread;
@end
