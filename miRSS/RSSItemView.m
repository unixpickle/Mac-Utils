//
//  RSSItemView.m
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RSSItemView.h"
#import "ANImageBitmapRep.h"

@implementation RSSItemView

@synthesize item;
@synthesize delegate;

- (NSTextField *)labelTextFieldForFrame:(NSRect)frm {
	NSTextField * tf = [[NSTextField alloc] initWithFrame:frm];
	[tf setBackgroundColor:[NSColor clearColor]];
	[tf setBordered:NO];
	[tf setTextColor:[NSColor blackColor]];
	[tf setFont:[NSFont systemFontOfSize:18]];
	[tf setEditable:NO];
	[tf setSelectable:NO];
	return [tf autorelease];
}

- (id)initWithFrame:(NSRect)frame {
	static NSImage * _topleft = nil;
	static NSImage * _topmiddle = nil;
	static NSImage * _topright = nil;
	static NSImage * _bottomleft = nil;
	static NSImage * _bottommiddle = nil;
	static NSImage * _bottomright = nil;
	
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		if (!_topleft) {
			ANImageBitmapRep * toprep = [ANImageBitmapRep imageBitmapRepNamed:@"topbar.png"];
			_topleft = [[[toprep cropWithFrame:NSMakeRect(0, 0, 10, 27)] image] retain];
			_topmiddle = [[[toprep cropWithFrame:NSMakeRect(10, 0, 5, 27)] image] retain];
			_topright = [[[toprep cropWithFrame:NSMakeRect(15, 0, 10, 27)] image] retain];
		}
		if (!_bottomleft) {
			ANImageBitmapRep * bottomrep = [ANImageBitmapRep imageBitmapRepNamed:@"bottombar.png"];
			_bottomleft = [[[bottomrep cropWithFrame:NSMakeRect(0, 0, 11, 25)] image] retain];
			_bottommiddle = [[[bottomrep cropWithFrame:NSMakeRect(11, 0, 5, 25)] image] retain];
			_bottomleft = [[[bottomrep cropWithFrame:NSMakeRect(16, 0, 11, 25)] image] retain];
		}
		topleft = _topleft;
		topmiddle = _topmiddle;
		topright = _topright;
		bottomleft = _bottomleft;
		bottommiddle = _bottommiddle;
		bottomright = _bottomright;
    }
    return self;
}

- (void)resetCursorRects {
    [super resetCursorRects];
    [self addCursorRect:[self bounds]
				 cursor:[NSCursor pointingHandCursor]];
	
}

- (void)sizeToFit {
	// make size
	
	NSRect frm = [self frame];
	frm.size.height = 100;
	[self setFrame:frm];
	
	// make our labels
	NSTextField * titleField = [self labelTextFieldForFrame:NSMakeRect(10, 4, self.frame.size.width - 100, 20)];
	[titleField setFont:[NSFont boldSystemFontOfSize:13]];
	if ([self.item postTitle])
		[titleField setStringValue:[self.item postTitle]];
	[self addSubview:titleField];
	NSTextField * dateField = [self labelTextFieldForFrame:NSMakeRect(self.frame.size.width - 100, 4, 90, 30)];
	[dateField setFont:[NSFont systemFontOfSize:9]];
	[dateField setAlignment:NSRightTextAlignment];
	
	// format the date
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"E, dd LLL yyyy hh:mm:ss a"];
	NSString * df = [formatter stringFromDate:[self.item postDate]];
	[formatter release];
	if (df) {
		[dateField setStringValue:df];
	}
	[self addSubview:dateField];
	NSTextField * contentField = [self labelTextFieldForFrame:NSMakeRect(10, 35, self.frame.size.width - 20, self.frame.size.height - 42)];
	[contentField setFont:[NSFont systemFontOfSize:11]];
	if ([self.item postContent]) {
		NSString * oldString = [NSMutableString stringWithString:[self.item postContent]];
		oldString = [oldString stringByReplacingOccurrencesOfRegex:@"<.*?>" withString:@""];
		oldString = [oldString stringByReplacingOccurrencesOfRegex:@"<br />" withString:@"\n"];
		oldString = [oldString stringByReplacingOccurrencesOfRegex:@"&#8217;" withString:@"'"];
		oldString = [oldString stringByReplacingOccurrencesOfRegex:@"&#8243;" withString:@"\""];
		oldString = [oldString stringByReplacingOccurrencesOfRegex:@"^\n" withString:@""];
		oldString = [oldString stringByReplacingOccurrencesOfRegex:@"^\n" withString:@""];
		[contentField setStringValue:oldString];
	}
	[self addSubview:contentField];
	
	titleLabel = [titleField retain];
}

- (BOOL)isFlipped {
	return YES;
}

- (void)deselect {
	selected = NO;
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
	if (!selected) {
		[self becomeFirstResponder];
		if ([(id)delegate respondsToSelector:@selector(rssItemWasSelected:)]) {
			[delegate rssItemWasSelected:self];
		}
		selected = YES;
		for (NSView * view in [[self superview] subviews]) {
			if ([view isKindOfClass:[RSSItemView class]] && view != self) {
				[(RSSItemView *)view deselect];
			}
		}
		[[self item] setIsRead:YES];
		[self setNeedsDisplay:YES];
		return;
	}
	if ([(id)delegate respondsToSelector:@selector(rssItemWasOpened:)]) {
		[delegate rssItemWasOpened:self];
	}
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[self.item postURL]]];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	// draw round border
	
	[topleft drawInRect:NSMakeRect(0, 0, 10, 27) fromRect:NSZeroRect
			  operation:NSCompositeSourceOver fraction:1];
	[topmiddle drawInRect:NSMakeRect(10, 0, self.frame.size.width - 20, 27) 
				 fromRect:NSZeroRect operation:NSCompositeSourceOver 
				 fraction:1];
	[topright drawInRect:NSMakeRect(self.frame.size.width - 10, 0, 10, 27) 
				fromRect:NSZeroRect 
			   operation:NSCompositeSourceOver fraction:1];
	
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	
	NSRect frame = [self bounds];
	CGRect rect = *(CGRect *)&frame;
	
	float radius = 10;
	
	float move = 1;
	if (selected) move += 0.5;
	
	CGFloat minX = CGRectGetMinX(rect) + move;
	CGFloat minY = CGRectGetMinY(rect) + move;
	CGFloat maxX = CGRectGetMaxX(rect) - move;
	CGFloat maxY = CGRectGetMaxY(rect) - move;
	
	CGContextSaveGState(context);
	
	CGContextSetAllowsAntialiasing(context, YES);
	
	CGContextBeginPath(context);
	if ([item isRead]) {
		CGContextSetGrayFillColor(context, 0.9, 1);
	} else {
		CGContextSetGrayFillColor(context, 0.7, 1);
	}
	CGContextMoveToPoint(context, minX + radius, minY);
	
	CGContextAddArcToPoint(context, minX, minY, minX, maxY, radius);
	CGContextAddArcToPoint(context, minX, maxY, maxX, maxY, radius);
	CGContextAddArcToPoint(context, maxX, maxY, maxX, minY, radius);
	CGContextAddArcToPoint(context, maxX, minY, minX, minY, radius);
	
	CGContextClosePath(context);
	CGContextSetLineWidth(context, 1);
	if (!selected)
		CGContextSetGrayStrokeColor(context, 0.1, 1);
	else {
		CGContextSetRGBStrokeColor(context, 0.2, 0.2, 1, 1);
		CGContextSetLineWidth(context, 3);
	}
	
	CGContextStrokePath(context);
		
	CGContextRestoreGState(context);
	
	if ([item isRead])
		[titleLabel setTextColor:[NSColor grayColor]];
	else [titleLabel setTextColor:[NSColor blackColor]];
	
	// yay
	
	
}

- (BOOL)selected {
	return selected;
}

- (BOOL)canBecomeKeyView {
	return YES;
}

- (void)dealloc {
	[titleLabel release];
	self.item = nil;
	[super dealloc];
}

@end
