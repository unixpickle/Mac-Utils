//
//  RSSItemView.h
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RSSItem.h"
#import "RegexKitLite.h"

@interface RSSItemView : NSView {
	RSSItem * item;
	NSImage * topleft;
	NSImage * topmiddle;
	NSImage * topright;
	NSImage * bottomleft;
	NSImage * bottommiddle;
	NSImage * bottomright;
	BOOL selected;
}

@property (nonatomic, retain) RSSItem * item;

- (void)deselect;
- (void)sizeToFit;

@end
