//
//  BackgroundView.m
//  FileTools
//
//  Created by Alex Nichol on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BackgroundView.h"


@implementation BackgroundView

- (void)drawRect:(NSRect)dirtyRect {
	// draw background colour
	[[NSColor colorWithDeviceRed:0.929 green:0.929 blue:0.929 alpha:1] set];
	NSRectFill(dirtyRect);
}

@end
