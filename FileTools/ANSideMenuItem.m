//
//  ANSideMenuItem.m
//  FancySideMenu
//
//  Created by Alex Nichol on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANSideMenuItem.h"


@implementation ANSideMenuItem

@synthesize delegate;

#pragma mark Initialization

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // They are not using us correctly,
		// so let's be a dick about it.
		NSLog(@"Do not call initWithFrame: on this class.");
		exit(-1);
    }
    return self;
}

- (id)initWithTitle:(NSString *)_title icon:(NSImage *)image {
	if (self = [super initWithFrame:NSMakeRect(0, 0, 200, 20)]) {
		fullColor = YES;
		// create the title and set the flags
//		textLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(kSideMenuContentOffset + 25, 1, 150, 16)];
//		[textLabel setFont:[NSFont systemFontOfSize:11.5]];
//		[textLabel setBordered:NO];
//		[textLabel setBackgroundColor:[NSColor clearColor]];
//		[textLabel setEditable:NO];
//		[textLabel setSelectable:NO];
		imageIcon = [[NSImageView alloc] initWithFrame:NSMakeRect(kSideMenuContentOffset, 2, 16, 16)];
		[self addSubview:imageIcon];
		[self setTitle:_title];
		[self setIcon:image];
		[imageIcon release];
		[self setSelected:NO];
	}
	return self;
}

#pragma mark Data Properties

- (void)setTitle:(NSString *)string {
	[title release];
	title = [string retain];
	[self setNeedsDisplay:YES];
}
- (NSString *)title {
	return title;
}
- (void)setIcon:(NSImage *)icon {
	[imageIcon setImage:icon];
}

#pragma mark Selection Properties

- (int)tag {
	return tag;
}
- (void)setTag:(int)_tag {
	tag = _tag;
}

- (BOOL)isSelected {
	return isSelected;
}
- (void)setSelected:(BOOL)selected {
	isSelected = selected;
	if (selected) [delegate sideMenuSelected:self];
	if (selected) {
		for (NSView * v in [[self superview] subviews]) {
			if ([v isKindOfClass:[ANSideMenuItem class]]) {
				if (v != self) {
					// deselect it
					[(ANSideMenuItem *)v setSelected:NO];
				}
			}
		}
	}
	if (!selected) isActive = NO;
	[self setNeedsDisplay:YES];
}

- (BOOL)isActive {
	return isActive;
}
- (void)setActive:(BOOL)active {
	isActive = active;
	if (active) isSelected = YES;
	if (isSelected) {
		for (NSView * v in [[self superview] subviews]) {
			if ([v isKindOfClass:[ANSideMenuItem class]]) {
				if (v != self) {
					// deselect it
					[(ANSideMenuItem *)v setSelected:NO];
				}
			}
		}
	}
	[self setNeedsDisplay:YES];
}

- (BOOL)fullColor {
	return fullColor;
}
- (void)setFullColor:(BOOL)fColor {
	fullColor = fColor;
	[self setNeedsDisplay:YES];
}

#pragma mark Actions

- (void)mouseDown:(NSEvent *)theEvent {
	[self setSelected:YES];
	[self setActive:YES];
}

#pragma mark Graphics

- (NSColor *)textColor {
	if (isActive) return [NSColor whiteColor];
	if (isSelected) return [NSColor colorWithDeviceRed:0.95 green:0.95
												  blue:0.95 alpha:1];
	if (!fullColor) {
		return [NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:1];
	}
	return [NSColor blackColor];
}

- (NSDictionary *)stringAttributes {
	NSShadow * sh = [[NSShadow alloc] init];
	[sh setShadowOffset:NSMakeSize(0, -1)];
	[sh setShadowColor:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.3]];
	[sh setShadowBlurRadius:1];
	NSMutableParagraphStyle * pSt = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	NSDictionary * atts = nil;
	if (isSelected) {
		atts = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSFont boldSystemFontOfSize:11.5], NSFontAttributeName,
							   sh, NSShadowAttributeName,
							   [self textColor], NSForegroundColorAttributeName,
							   pSt, NSParagraphStyleAttributeName, nil];
	} else {
		atts = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSFont systemFontOfSize:11.5], NSFontAttributeName,
							   [self textColor], NSForegroundColorAttributeName,
							   pSt, NSParagraphStyleAttributeName, nil];
	}
	[sh release];
	[pSt release];
	return atts;
}

- (void)setFrame:(NSRect)frameRect {
	// create a new frame that
	// has the height we want,
	// and resize our item's
	// content to fit it
	[super setFrame:frameRect];
//	[textLabel setFrame:NSMakeRect(kSideMenuContentOffset + 25, 
//								   1, 
//								   self.frame.size.width - (kSideMenuContentOffset + 30),
//								   16)];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	const static size_t num_locations = 2;
	const static CGFloat locations[2] = {0.0, 1};
	const static CGFloat colorsActive[8] = {0.094, 0.416, 0.725, 1, 
		0.329, 0.58, 0.824, 1}; 
	const static CGFloat colorsUnactive[8] = {0.608, 0.608, 0.608, 1,
		0.757, 0.757, 0.757, 1};
	const static CGFloat colorsPartiallyActive[8] = {0.506, 0.588, 0.725, 1,
		0.694, 0.749, 0.847, 1};
	
	const CGFloat * currentColor = NULL;
	
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGGradientRef myGradient = nil;
	CGColorSpaceRef myColorspace = nil;
	
	if (isSelected) {
		// create and draw a gradient
		if (isActive && fullColor) {
			// blue gradient
			myColorspace = CGColorSpaceCreateDeviceRGB();
			currentColor = colorsActive;
			myGradient = CGGradientCreateWithColorComponents(myColorspace, colorsActive, locations, num_locations);
		} else if (!fullColor) {
			// gray gradient
			myColorspace = CGColorSpaceCreateDeviceRGB();
			currentColor = colorsUnactive;
			myGradient = CGGradientCreateWithColorComponents(myColorspace, colorsUnactive, locations, num_locations);
		} else {
			myColorspace = CGColorSpaceCreateDeviceRGB();
			currentColor = colorsPartiallyActive;
			myGradient = CGGradientCreateWithColorComponents(myColorspace, currentColor, locations, num_locations);			
		}
		CGFloat colour[4] = {currentColor[4] - 0.1, currentColor[5] - 0.1,
			currentColor[6] - 0.1, 1};
		CGPoint ps[2] = {CGPointMake(0, self.frame.size.height - 0.5), CGPointMake(self.frame.size.width, self.frame.size.height - 0.5)};
		CGPoint myStartPoint, myEndPoint;
		myStartPoint = CGPointMake(0, 0);
		myEndPoint = CGPointMake(0, self.frame.size.height - 1);
		CGContextSaveGState(context);
		CGContextClipToRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 1));
		CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);
		CGContextRestoreGState(context);
		
		// top line
		CGContextSaveGState(context);
		CGContextClipToRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
		CGContextSetStrokeColorSpace(context, myColorspace);
		CGContextSetStrokeColor(context, colour);
		CGContextSetLineWidth(context, 1);
		CGContextSetLineCap(context, kCGLineCapSquare);
		CGContextStrokeLineSegments(context, ps, 2);
		CGContextRestoreGState(context);
		
		
	}
	
	NSAttributedString * dstring = [[NSAttributedString alloc] initWithString:title attributes:[self stringAttributes]];
	[dstring drawAtPoint:NSMakePoint(kSideMenuContentOffset + 22, 3)];
	[dstring release];
	
	if (myColorspace) {
		CGColorSpaceRelease(myColorspace);
		CGGradientRelease(myGradient);
	}
}

@end
