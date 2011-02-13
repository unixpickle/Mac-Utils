//
//  ANGraySwitch.m
//  FileTools
//
//  Created by Alex Nichol on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANGraySwitch.h"

static void StartPath (CGContextRef context, CGRect frame, CGFloat radius) {
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, frame.origin.x + radius, frame.origin.y);
	
	CGFloat minX = frame.origin.x;
	CGFloat minY = frame.origin.y;
	CGFloat maxX = frame.origin.x + frame.size.width;
	CGFloat maxY = frame.origin.y + frame.size.height;
	
	CGContextAddArcToPoint(context, minX, minY, minX, maxY, radius);
	CGContextAddArcToPoint(context, minX, maxY, maxX, maxY, radius);
	CGContextAddArcToPoint(context, maxX, maxY, maxX, minY, radius);
	CGContextAddArcToPoint(context, maxX, minY, minX, minY, radius);
	
	CGContextClosePath(context);
}

static void ClipToRect (CGContextRef context, CGRect frame, CGFloat radius) {
	StartPath(context, frame, radius);
	CGContextClip(context);
}

@implementation ANGraySwitch

@synthesize target, action;

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		sliderPoint.x = 1;
		sliderPoint.y = 1;
	}
	return self;
}

- (id)initWithFrame:(NSRect)frame {
	if (self = [super initWithFrame:frame]) {
		sliderPoint.x = 1;
		sliderPoint.y = 1;
	}
	return self;
}

- (void)mouseDown:(NSEvent *)evt {
	isPressed = YES;
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent {
	// get the mouse position
	CGPoint offset = CGPointMake(0, 0);
	NSView * v = self;
	while (v) {
		offset.x += v.frame.origin.x;
		offset.y += v.frame.origin.y;
		v = [v superview];
	}
	NSPoint mouseLoc = [theEvent locationInWindow];
	mouseLoc.x -= offset.x;
	mouseLoc.y -= offset.y;
	mouseLoc.x -= (kButtonWidth / 2);
	// check out the mouse location
	sliderPoint.x = mouseLoc.x;
	sliderPoint.y = 1;
	if (sliderPoint.x < 1) {
		sliderPoint.x = 1;
	} else if (sliderPoint.x > self.frame.size.width - (kButtonWidth + 1)) {
		sliderPoint.x = self.frame.size.width - (kButtonWidth + 1);
	}
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
	isPressed = NO;
	if (sliderPoint.x < self.frame.size.width / 2 - (kButtonWidth / 2)) {
		[self setIsOn:NO];
	} else {
		[self setIsOn:YES];
	}
	[self setNeedsDisplay:YES];
}

- (void)setIsOn:(BOOL)_isOn {
	BOOL callDelegate = NO;
	if (on != _isOn) {
		callDelegate = YES;
	}
	if (!_isOn) {
		sliderPoint.x = 1;
	} else {
		sliderPoint.x = self.frame.size.width - (kButtonWidth + 1);
	}
	on = _isOn;
	if (callDelegate) {
		[target performSelector:action withObject:self];
	}
	[self setNeedsDisplay:YES];
}
- (BOOL)isOn {
	return on;
}

- (void)drawRect:(NSRect)frame {
	const static CGFloat buttonColors[8] = {0.984, 0.984, 0.984, 1, 
		0.882, 0.882, 0.882, 1};
	const static CGFloat revColors[8] = {0.882, 0.882, 0.882, 1, 
		0.984, 0.984, 0.984, 1};
	const static CGFloat backgroundColors[8] = {0.522, 0.522, 0.522, 1, 
		0.639, 0.639, 0.639, 1};
	const static size_t num_locations = 2;
	const static CGFloat locations[2] = {0.0, 1};
	
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGGradientRef myGradient = nil;
	CGColorSpaceRef myColorspace = nil;
	
	CGContextSaveGState(context);
	ClipToRect(context, CGRectMake(1, 1, self.frame.size.width - 2, self.frame.size.height - 2), 2);

	
	myColorspace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents(myColorspace, backgroundColors, locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myEndPoint = CGPointMake(0, 1);
	myStartPoint = CGPointMake(0, self.frame.size.height - 1);
	CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);
	
	if (myColorspace) {
		CGColorSpaceRelease(myColorspace);
		CGGradientRelease(myGradient);
	}
	
	CGContextRestoreGState(context);
	
	CGContextSaveGState(context);
	
	NSShadow * sh = [[NSShadow alloc] init];
	[sh setShadowBlurRadius:4];
	[sh setShadowColor:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.7]];
	[sh setShadowOffset:NSMakeSize(0, -2)];
	
	[sh set];
	
	StartPath(context, CGRectMake(0.5, 0.5, self.frame.size.width - 1, self.frame.size.height - 1), 2);
	CGColorRef color = CGColorCreateGenericRGB(0, 0, 0, 0.7); 
	CGContextSetStrokeColorWithColor(context, color);
	CGContextSetLineWidth(context, 1);
	CGContextStrokePath(context);
	CGColorRelease(color);
	CGContextRestoreGState(context);
	[sh release];
	
	CGContextSaveGState(context);
	sh = [[NSShadow alloc] init];
	[sh setShadowBlurRadius:4];
	[sh setShadowColor:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.5]];
	[sh setShadowOffset:NSMakeSize(2, 0)];
	
	[sh set];
	CGContextFillRect(context, CGRectMake(sliderPoint.x, 1, kButtonWidth, kButtonHeight));
	CGContextRestoreGState(context);
	[sh release];
	
	CGContextSaveGState(context);
	sh = [[NSShadow alloc] init];
	[sh setShadowBlurRadius:4];
	[sh setShadowColor:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.5]];
	[sh setShadowOffset:NSMakeSize(-2, 0)];
	
	[sh set];
	CGContextFillRect(context, CGRectMake(sliderPoint.x, 1, kButtonWidth, kButtonHeight));
	CGContextRestoreGState(context);
	[sh release];
	
	CGContextSaveGState(context);
	
	ClipToRect(context, CGRectMake(sliderPoint.x, 1, kButtonWidth, kButtonHeight), 2);
	
	myColorspace = CGColorSpaceCreateDeviceRGB();
	if (!isPressed)
		myGradient = CGGradientCreateWithColorComponents(myColorspace, buttonColors, locations, num_locations);
	else myGradient = CGGradientCreateWithColorComponents(myColorspace, revColors, locations, num_locations);

		
	myEndPoint = CGPointMake(0, 1);
	myStartPoint = CGPointMake(0, self.frame.size.height - 1);
	CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);
	
	if (myColorspace) {
		CGColorSpaceRelease(myColorspace);
		CGGradientRelease(myGradient);
	}
	
	CGContextRestoreGState(context);
	
	/*CGContextSetLineWidth(context, 1);
	CGColorRef shadowColor = CGColorCreateGenericRGB(0, 0, 0, 0.3); 
	CGPoint shadowLine[2] = {CGPointMake(kButtonWidth + 1.5, 2), 
		CGPointMake(kButtonWidth + 1.5, kButtonHeight)};
	CGContextSetStrokeColorWithColor(context, shadowColor);
	CGContextStrokeLineSegments(context, shadowLine, 2);
	CGColorRelease(shadowColor);
	
	CGContextSetLineWidth(context, 1);
	shadowColor = CGColorCreateGenericRGB(0, 0, 0, 0.1); 
	shadowLine[0] = CGPointMake(kButtonWidth + 2.5, 3); 
	shadowLine[1] = CGPointMake(kButtonWidth + 2.5, kButtonHeight - 1);
	CGContextSetStrokeColorWithColor(context, shadowColor);
	CGContextStrokeLineSegments(context, shadowLine, 2);
	CGColorRelease(shadowColor);*/
	
	
	
}

@end
