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

@protocol RSSChannelViewDelegate

@optional
- (void)rssChannel:(id)sender itemHighlighted:(RSSItemView *)item;

@end


@interface RSSChannelView : NSView <RSSItemViewDelegate> {
	NSScrollView * contentView;
	id <RSSChannelViewDelegate> delegate;
	id lastChannel;
}
@property (nonatomic, assign) id <RSSChannelViewDelegate> delegate;
- (void)setChannel:(RSSChannel *)channel;
@end
