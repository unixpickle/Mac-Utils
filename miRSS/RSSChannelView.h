//
//  RSSChannelView.h
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RSSItemView.h"
#import "RSSChannel.h"

@interface RSSChannelView : NSView {
	NSScrollView * contentView;
}
- (void)setChannel:(RSSChannel *)channel;
@end
