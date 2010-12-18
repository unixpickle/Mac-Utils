//
//  RSSChannelView.m
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RSSChannelView.h"


@implementation RSSChannelView

@synthesize delegate;

- (BOOL)canBecomeKeyView {
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
	// here we go
	int mods = [theEvent modifierFlags];
	mods = mods >> 16;
	int i = (mods & 16);
	BOOL command = NO;
	if (i > 0) command = YES;
	
	
	if ([theEvent keyCode] > 11 && [theEvent keyCode] < 14) {
		// q or w
		if ([(id)delegate respondsToSelector:@selector(rssChannelDidClose:)]) {
			[delegate rssChannelDidClose:self];
		}
		return;
	}
	
	BOOL down = YES;
	switch ([theEvent keyCode]) {
		case 125:
			down = YES;
			//down
			break;
		case 126:
			down = NO;
			//up
			break;
		default:
			//not known
			NSBeep();
			return;
			break;
	}
	for (NSView * v in [[[contentView contentView] documentView] subviews]) {
		if ([v isKindOfClass:[RSSItemView class]]) {
			RSSItemView * iv;
			iv = (RSSItemView *)v;
			if ([iv selected]) {
				// move down a bit
				for (NSView * j in [[[contentView contentView] documentView] subviews]) {
					
					int maxHold = iv.frame.origin.y - iv.frame.size.height;
					int minHold = maxHold - 20;
					if (!down) {
						minHold = iv.frame.origin.y + iv.frame.size.height;
						maxHold = minHold + 20;
					}
					if (j.frame.origin.y > minHold && j.frame.origin.y < maxHold) {
						// select it
						if ([j isKindOfClass:[RSSItemView class]]) {
							[(RSSItemView *)j mouseUp:nil];
							NSRect vFrame = [j frame];
							vFrame.origin.y -= 10;
							vFrame.size.height += 20;
							[[contentView contentView] scrollRectToVisible:vFrame];
							return;
						}
					}
				}
			}
		}
	}
}

- (void)rssItemWasSelected:(id)sender {
	if ([(id)delegate respondsToSelector:@selector(rssChannel:itemHighlighted:)]) {
		[delegate rssChannel:self itemHighlighted:sender];
	}
}

- (void)setChannel:(RSSChannel *)channel {
	
	[lastChannel release];
	lastChannel = [channel retain];
	
	if (contentView) {
		[contentView removeFromSuperview];
		[contentView release];
	}
	
	contentView = [[NSScrollView alloc] initWithFrame:[self bounds]];
	int y = 10;
	int x = 10;
	int width = self.frame.size.width - 35;
	NSClipView * cv = [[NSClipView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
	NSView * contentContentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
	RSSChannel * ch = channel;
	for (int i = [[ch items] count] - 1; i >= 0; i--) {
		RSSItem * _item = [[ch items] objectAtIndex:i];
		// read the item 
		RSSItemView * item = [[RSSItemView alloc] initWithFrame:NSMakeRect(x, y, width, 100)];
		[item setDelegate:self];
		[item setItem:_item];
		[item sizeToFit];
		y += [item frame].size.height + 10;
		[contentContentView addSubview:item];
		[item release];
	}
	NSRect frm = [contentContentView frame];
	frm.size.height = y;
	[contentContentView setFrame:frm];
	[cv setDocumentView:contentContentView];
	[contentView setContentView:cv];
	[cv scrollRectToVisible:NSMakeRect(0, y - 1, 1, 1)];
	[cv release];
	[self addSubview:contentView];
	[contentContentView release];
	[contentView setScrollsDynamically:YES];
	[contentView setHasVerticalScroller:YES];
}

- (BOOL)isFlipped {
	return NO;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

- (void)dealloc {
	[contentView removeFromSuperview];
	[contentView release];
	[super dealloc];
}

@end
