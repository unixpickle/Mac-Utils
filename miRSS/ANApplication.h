//
//  ANApplication.h
//  miRSS
//
//  Created by Alex Nichol on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANCommandCounter.h"

@interface NSApplication (anapplication)

- (NSScriptObjectSpecifier *)objectSpecifier;
- (NSArray *)rssfeeds;
- (void)insertInRssfeeds:(id)feed;
- (void)insertInRssfeeds:(id)feed atIndex:(unsigned)index;
- (void)removeFromRssfeedsAtIndex:(unsigned)index;

- (NSNumber *)feedcount;

@end
