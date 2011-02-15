//
//  FileToolsAppDelegate.h
//  FileTools
//
//  Created by Alex Nichol on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANSideMenu.h"
#import "WhenFileAppController.h"
#import "ANSideMenuItem.h"

#define kUseAnimation NO

@class WhenFileAppController;

@interface FileToolsAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, ANSideMenuItemDelegate> {
    NSWindow * window;
	IBOutlet NSView * whenFileView;
	IBOutlet NSView * quicktimeView;
	IBOutlet NSView * deleteView;
	IBOutlet NSView * setFileView;
	IBOutlet NSView * resourceForkView;
	IBOutlet NSView * resourceForkChangeView;
	IBOutlet NSView * mainView;
	ANSideMenu * menu;
	BOOL switching;
}

@property (assign) IBOutlet NSWindow * window;

@end
