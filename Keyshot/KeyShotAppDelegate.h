//
//  KeyShotAppDelegate.h
//  KeyShot
//
//  Created by Alex Nichol on 3/30/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANKeyEvent.h"
#import "ANApplicationHotKey.h"

@interface KeyShotAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    NSWindow * window;
	NSMutableArray * keystrokes;
	IBOutlet NSTableView * tv;
	IBOutlet NSTextField * text_appName;
	IBOutlet NSTextField * text_appPath;
	IBOutlet NSPopUpButton * popup_keys;
	IBOutlet NSButton * check_command;
	IBOutlet NSButton * check_control;
	IBOutlet NSButton * check_option;
	IBOutlet NSButton * check_shift;
	IBOutlet NSWindow * aboutWindow;
	NSWindowController * wc;
	NSStatusItem * _statusItem;
}

- (void)enableControls;
- (void)disableControls;
- (IBAction)changeSettings:(id)sender;
- (IBAction)addShortcut:(id)sender;
- (IBAction)removeShortcut:(id)sender;
- (void)showAbout:(id)sender;

- (void)saveUserSettings;

@property (assign) IBOutlet NSWindow *window;

@end
