//
//  MainView.m
//  miRSS
//
//  Created by Alex Nichol on 12/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainView.h"


@implementation MainView

- (BOOL)canBecomeKeyView {
	return YES;
}

- (void)keyDown:(NSEvent *)evt {
	NSLog(@"FOO 2");
}

@end
