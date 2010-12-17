//
//  ANRSSFeed.h
//  miRSS
//
//  Created by Alex Nichol on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ANRSSFeed : NSObject {
	NSString * title;
	NSString * url;
	int index;
}
- (void)setRsstitle:(NSString *)newTitle;
- (void)setIndexnumber:(int)index;
- (void)setRssurl:(NSString *)url;
- (NSString *)rsstitle;
- (NSString *)rssurl;
- (NSNumber *)indexnumber;
@end
