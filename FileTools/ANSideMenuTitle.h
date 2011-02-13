//
//  ANSideMenuTitle.h
//  FancySideMenu
//
//  Created by Alex Nichol on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ANSideMenuTitle : NSView {
	NSAttributedString * titleString;
}

- (id)initWithTitle:(NSString *)title;
- (void)setTitle:(NSString *)title;

@end
