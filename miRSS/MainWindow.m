//
//  MainWindow.m
//  miRSS
//
//  Created by Alex Nichol on 12/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainWindow.h"


@implementation MainWindow

- (BOOL)canBecomeKeyView {
	return YES;
}

- (void)keyDown:(NSEvent *)evt {
	[[self contentView] keyDown:evt];
}

@end
