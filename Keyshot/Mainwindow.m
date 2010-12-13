//
//  Mainwindow.m
//  KeyShot
//
//  Created by Alex Nichol on 3/30/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Mainwindow.h"


@implementation Mainwindow

- (BOOL)canBecomeKeyWindow { return YES; }

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

@end
