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
	NSArray * articles;
	int index;
	int nunread;
}
- (id)objectSpecifier;
// feeds is a dictionary containing the feeds and sorting
// them by index (uniqueID)
+ (NSMutableDictionary *)feeds;

// this method is not part of the KVC
- (void)setArticles:(NSArray *)articles;
// <element type="article">
- (NSArray *)articles;
// none of these methods will do anything
// because you are not allowed to modify
// the articles in a feed you do not
// distribute!!!
- (void)insertInArticles:(id)feed;
- (void)insertInArticles:(id)feed atIndex:(unsigned)index;
- (void)removeFromArticlesAtIndex:(unsigned)index;

// KVC compliant methods
- (void)setRsstitle:(NSString *)newTitle;
- (NSString *)rsstitle;
- (void)setIndexnumber:(int)index;
- (NSNumber *)indexnumber;
- (void)setRssurl:(NSString *)url;
- (NSString *)rssurl;
- (void)setUnread:(NSNumber *)_unread;
- (NSNumber *)unread;
- (void)setUniqueID:(NSNumber *)string;
- (NSNumber *)uniqueID;

@end
