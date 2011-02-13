//
//  ANSideMenuTitle.m
//  FancySideMenu
//
//  Created by Alex Nichol on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANSideMenuTitle.h"


@implementation ANSideMenuTitle

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		NSLog(@"No calling initWithFrame: on this class.");
		exit(-1);
    }
    return self;
}

- (NSColor *)textColor {
	return [NSColor colorWithDeviceRed:0.376 green:0.376 blue:0.376
								 alpha:1];
}

- (NSDictionary *)stringAttributes {
	NSShadow * sh = [[NSShadow alloc] init];
	[sh setShadowOffset:NSMakeSize(0, -1)];
	[sh setShadowColor:[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:1]];
	[sh setShadowBlurRadius:1];
	NSMutableParagraphStyle * pSt = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	
	NSDictionary * atts = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSFont boldSystemFontOfSize:12], NSFontAttributeName,
						   sh, NSShadowAttributeName,
						   [self textColor], NSForegroundColorAttributeName,
						   pSt, NSParagraphStyleAttributeName, nil];
	[sh release];
	[pSt release];
	return atts;
}

- (id)initWithTitle:(NSString *)title {
	if (self = [super initWithFrame:NSMakeRect(0, 0, 200, 20)]) {
		[self setTitle:title];
	}
	return self;
}
- (void)setTitle:(NSString *)title {
	titleString = [[NSAttributedString alloc] initWithString:title attributes:[self stringAttributes]];
	[self setNeedsDisplay:YES];
}

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	[titleString drawAtPoint:NSMakePoint(10, 3)];
}

@end
