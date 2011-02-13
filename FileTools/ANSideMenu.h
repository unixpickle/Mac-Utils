//
//  ANSideMenu.h
//  FancySideMenu
//
//  Created by Alex Nichol on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANSideMenuItem.h"
#import "ANSideMenuTitle.h"

@interface ANSideMenu : NSView {
	NSArray * _items;
	BOOL focused;
}

- (id)initWithItems:(NSArray *)items;
- (void)setItems:(NSArray *)items;
- (void)windowUnfocus;
- (void)windowFocus;

@end
