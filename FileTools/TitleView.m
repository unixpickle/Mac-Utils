//
//  TitleView.m
//  FileTools
//
//  Created by Alex Nichol on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TitleView.h"


@implementation TitleView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	[[NSColor colorWithDeviceRed:0.729 green:0.729 blue:0.729 alpha:1] set];
	NSRectFill(dirtyRect);
	
}

@end
