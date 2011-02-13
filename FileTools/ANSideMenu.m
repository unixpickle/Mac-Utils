//
//  ANSideMenu.m
//  FancySideMenu
//
//  Created by Alex Nichol on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANSideMenu.h"


@implementation ANSideMenu

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithItems:(NSArray *)items {
	if (self = [self initWithFrame:NSMakeRect(0, 0, 200, 100)]) {
		[self setItems:items];
	}
	return self;
}

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	float y = [self frame].size.height - 5;
	for (id v in _items) {
		if ([v isKindOfClass:[ANSideMenuItem class]] || [v isKindOfClass:[ANSideMenuTitle class]]) {
			NSView * smi = (NSView *)v;
			y -= [smi frame].size.height;
			[smi setFrame:NSMakeRect(0, y, self.frame.size.width - 1, 
									 smi.frame.size.height)];
		}
	}
}

- (BOOL)canBecomeKeyView {
	return YES;
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (BOOL)becomeFirstResponder {
	focused = YES;
	// focus in on the selected view
	if (_items) {
		for (id v in _items) {
			if ([v isKindOfClass:[ANSideMenuItem class]]) {
				ANSideMenuItem * item = (ANSideMenuItem *)v;
				if ([item isSelected]) [item setActive:YES];
				[item setFullColor:YES];
			}
		}
	}
	[super becomeFirstResponder];
	[self setNeedsDisplay:YES];
	return YES;

}

- (BOOL)resignFirstResponder {
	focused = YES;
	if (_items) {
		for (id v in _items) {
			if ([v isKindOfClass:[ANSideMenuItem class]]) {
				ANSideMenuItem * item = (ANSideMenuItem *)v;
				[item setActive:NO];
				//[item setFullColor:NO];
			}
		}
	}
	[super resignFirstResponder];
	[self setNeedsDisplay:YES];
	return YES;
}

- (void)windowUnfocus {
	focused = NO;
	if (_items) {
		for (id v in _items) {
			if ([v isKindOfClass:[ANSideMenuItem class]]) {
				ANSideMenuItem * item = (ANSideMenuItem *)v;
				[item setFullColor:NO];
			}
		}
	}
	[self setNeedsDisplay:YES];
}

- (void)windowFocus {
	// focus in on the selected view
	focused = YES;
	if (_items) {
		for (id v in _items) {
			if ([v isKindOfClass:[ANSideMenuItem class]]) {
				ANSideMenuItem * item = (ANSideMenuItem *)v;
				//if ([item isSelected]) [item setActive:YES];
				[item setFullColor:YES];
			}
		}
	}
	[self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent *)theEvent {
	switch ([theEvent keyCode]) {
		case 125:
		{
			// down arrow
			BOOL caught = NO;
			for (id item in _items) {
				if ([item isKindOfClass:[ANSideMenuItem class]]) {
					ANSideMenuItem * smi = (ANSideMenuItem *)item;
					if (caught) {
						[smi setSelected:YES];
						[smi setActive:YES];
						break;
					}
					if ([smi isSelected]) {
						caught = YES;
					}
				}
			}
			break;
		}
		case 126:
		{
			// up arrow
			ANSideMenuItem * last = nil;
			for (id item in _items) {
				if ([item isKindOfClass:[ANSideMenuItem class]]) {
					ANSideMenuItem * smi = (ANSideMenuItem *)item;
					if ([smi isSelected]) {
						if (last) {
							[last setSelected:YES];
							[last setActive:YES];
						}
					}
					last = smi;
				}
			}
			break;
		}
		default:
			break;
	}
}

- (void)setItems:(NSArray *)items {
	if (_items) {
		for (NSView * v in _items) {
			[v removeFromSuperview];
		}
	}
	[_items release];
	_items = [items retain];
	// add each and every item to ourselves
	float y = [self frame].size.height - 5;
	for (id v in items) {
		if ([v isKindOfClass:[ANSideMenuItem class]] || [v isKindOfClass:[ANSideMenuTitle class]]) {
			NSView * smi = (NSView *)v;
			if ([v isKindOfClass:[ANSideMenuTitle class]]) {
				if (y < [self frame].size.height - 6) {
					y -= 10;
				}
			}
			y -= [smi frame].size.height;
			[smi setFrame:NSMakeRect(0, y, self.frame.size.width - 1, 
									 smi.frame.size.height)];
			[self addSubview:smi];
		}
	}
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	static const CGFloat backgroundColorOff[4] = {0.929, 0.929, 0.929, 1};
	static const CGFloat backgroundColorOn[4] = {0.871, 0.894, 0.918, 1};
	static const CGFloat lineColor[4] = {0.745, 0.745, 0.745, 1};
	const CGPoint points[4] = {CGPointMake(self.frame.size.width, 0), 
		CGPointMake(self.frame.size.width, self.frame.size.height)};
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGColorSpaceRef cspace =  CGColorSpaceCreateDeviceRGB();
	CGContextSetFillColorSpace(context, cspace);
	if (focused)
		CGContextSetFillColor(context, backgroundColorOn);
	else
		CGContextSetFillColor(context, backgroundColorOff);
	CGContextFillRect(context, *((CGRect *)&dirtyRect));
	CGContextSetStrokeColorSpace(context, cspace);
	CGContextSetStrokeColor(context, lineColor);
	CGContextStrokeLineSegments(context, points, (size_t)4);
	
	CGColorSpaceRelease(cspace);
}

@end
