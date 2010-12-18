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

@protocol RSSItemViewDelegate

@optional
- (void)rssItemWasSelected:(id)sender;
- (void)rssItemWasOpened:(id)sender;

@end


@interface RSSItemView : NSView {
	RSSItem * item;
	NSImage * topleft;
	NSImage * topmiddle;
	NSImage * topright;
	NSImage * bottomleft;
	NSImage * bottommiddle;
	NSImage * bottomright;
	NSTextField * titleLabel;
	BOOL selected;
	id<RSSItemViewDelegate> delegate;
}

@property (nonatomic, assign) id<RSSItemViewDelegate> delegate;
@property (nonatomic, retain) RSSItem * item;

- (BOOL)selected;

- (void)deselect;
- (void)sizeToFit;

@end
