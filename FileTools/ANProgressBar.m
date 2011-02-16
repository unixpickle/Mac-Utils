//
//  ANProgressBar.m
//  FileTools
//
//  Created by Alex Nichol on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANProgressBar.h"

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

@implementation ANProgressBar

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)setProgress:(float)p {
	// set the progress, and draw
	progress = p / 100.0f;
	[self setNeedsDisplay:YES];
}
- (float)progress {
	return progress * 100.0f;
}

- (void)drawRect:(NSRect)dirtyRect {
    // draw a rounded border.
	CGFloat color[4] = {0.5, 0.5, 0.5, 1};
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGRect outerRect = CGRectMake(2, 2, self.frame.size.width - 4,
								  self.frame.size.height - 4); 
	CGRect innerRect = CGRectMake(4, 4, self.frame.size.width - 8,
								  self.frame.size.height - 8);
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	StartPath(context, outerRect, (self.frame.size.height - 4) / 2);
	CGContextSetStrokeColorSpace(context, space);
	CGContextSetStrokeColor(context, color);
	CGContextSetLineWidth(context, 2);
	CGContextStrokePath(context);
	
	// now we will draw the body
	CGContextSaveGState(context);
	ClipToRect(context, innerRect, (self.frame.size.height - 8) / 2);
	CGContextSetFillColorSpace(context, space);
	CGContextSetFillColor(context, color);
	// draw up to our percentage
	CGFloat bodyWidth = progress * (self.frame.size.width - 8);
	CGContextFillRect(context, CGRectMake(4, 0, bodyWidth, self.frame.size.height));
	CGContextRestoreGState(context);
	
	CGColorSpaceRelease(space);
}

@end
