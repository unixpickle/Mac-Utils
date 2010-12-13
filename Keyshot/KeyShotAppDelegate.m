//
//  KeyShotAppDelegate.m
//  KeyShot
//
//  Created by Alex Nichol on 3/30/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "KeyShotAppDelegate.h"

@implementation KeyShotAppDelegate

@synthesize window;

- (void)enableControls {
	[text_appName setEnabled:YES];
	[text_appPath setEnabled:YES];
	[popup_keys setEnabled:YES];
	[check_option setEnabled:YES];
	[check_command setEnabled:YES];
	[check_control setEnabled:YES];
	[check_shift setEnabled:YES];
}
- (void)disableControls {
	[text_appName setEnabled:NO];
	[text_appPath setEnabled:NO];
	[popup_keys setEnabled:NO];
	[check_option setEnabled:NO];
	[check_command setEnabled:NO];
	[check_control setEnabled:NO];
	[check_shift setEnabled:NO];
}


#pragma mark Settings

- (void)loadFromDefaults {
	[keystrokes release]; // just in case
	keystrokes = [[NSMutableArray alloc] init];
	NSArray * arr = [[NSUserDefaults standardUserDefaults] arrayForKey:@"shortcuts"];
	if (!arr) {
		return;
	}
	for (NSDictionary * dict in arr) {
		ANApplicationHotKey * ahk = [[ANApplicationHotKey alloc] init];
		[ahk setAppName:[dict valueForKey:@"title"]];
		[ahk setAppPath:[dict valueForKey:@"path"]];
		ANKeyEvent * ke = [[ANKeyEvent alloc] init];
		[ke setKey_code:[(NSNumber *)[dict valueForKey:@"key:code"] intValue]];
		[ke setKey_command:[(NSNumber *)[dict valueForKey:@"key:command"] boolValue]];
		[ke setKey_option:[(NSNumber *)[dict valueForKey:@"key:option"] boolValue]];
		[ke setKey_control:[(NSNumber *)[dict valueForKey:@"key:control"] boolValue]];
		[ke setKey_shift:[(NSNumber *)[dict valueForKey:@"key:shift"] boolValue]];
		[ahk setKeyEvent:ke];
		[ke registerEvent];
		[ke release];
		[keystrokes addObject:ahk];
		[ahk release];
	}
}

- (void)saveUserSettings {
	NSMutableArray * arr = [[NSMutableArray alloc] init];
	for (ANApplicationHotKey * hk in keystrokes) {
		[arr addObject:[hk dictionaryValue]];
	}
	[[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"shortcuts"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[arr release];
}


#pragma mark Windows and Menu Bar

- (void)showAbout:(id)sender {
	
	// center the window
	NSRect screenFrame = [[NSScreen mainScreen] frame];
	// we have the frame.
	NSRect windowFrame = [aboutWindow frame];
	windowFrame.origin.x = screenFrame.size.width / 2 - windowFrame.size.width / 2;
	windowFrame.origin.y = screenFrame.size.height / 2 - windowFrame.size.height / 2;
	[aboutWindow setFrameOrigin:windowFrame.origin];
	
	[aboutWindow setLevel:(NSNormalWindowLevel+1)];
	[aboutWindow makeKeyAndOrderFront:nil];
	[aboutWindow setLevel:NSNormalWindowLevel+1];
	
	ProcessSerialNumber num;
	GetCurrentProcess(&num);
	SetFrontProcess(&num);
}
- (void)dispWind:(id)sender {
	// do something here
	[window setViewsNeedDisplay:YES];
}

- (void)shortcuts:(id)sender {
	
	NSRect screenFrame = [[NSScreen mainScreen] frame];
	// we have the frame.
	NSRect windowFrame = [window frame];
	windowFrame.origin.x = screenFrame.size.width / 2 - windowFrame.size.width / 2;
	windowFrame.origin.y = screenFrame.size.height / 2 - windowFrame.size.height / 2;
	[window setFrameOrigin:windowFrame.origin];
	
	[window setLevel:(NSNormalWindowLevel+1)];
	[window makeKeyAndOrderFront:nil];
	[window setLevel:NSNormalWindowLevel+1];
	
	ProcessSerialNumber num;
	GetCurrentProcess(&num);
	SetFrontProcess(&num);
	
	/*
	[wc showWindow:self];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[window performSelector:@selector(activateIgnoringOtherApps:) withObject:self afterDelay:1.0]; 
	[window performSelector:@selector(orderFrontRegardless) withObject:nil afterDelay:1.0];
	[self performSelector:@selector(dispWind:) withObject:nil afterDelay:1.0];
	[window setCanBecomeVisibleWithoutLogin:YES];
	[window makeKeyAndOrderFront:self];*/
}

- (void)quitApp:(id)sender {
	[[NSApplication sharedApplication] terminate:self];
}

- (NSMenu *)createMenu {
	NSZone * menuZone = [NSMenu menuZone];
	NSMenu * menu = [[NSMenu allocWithZone:menuZone] init]; // this will leak
	NSMenuItem * menuItem;
	
	
	// Add To Items
	menuItem = [menu addItemWithTitle:@"Edit Shortcuts"
							   action:@selector(shortcuts:)
						keyEquivalent:@""];
	menuItem = [menu addItemWithTitle:@"About Keyshot"
							   action:@selector(showAbout:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
	menuItem = [menu addItemWithTitle:@"Quit"
							   action:@selector(quitApp:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
	
	return menu;
}

#pragma mark Unused (commented out)
/*
- (void)keyPressed:(id)nilPlease {
	//NSLog(@"Pressed");
}

- (void)anotherKeyPressed:(id)nilPlease {
	//NSLog(@"Other key event");
}

void addToLoginItems(NSString * path, BOOL hide) {
	NSString	 *loginwindow = @"loginwindow";
	NSUserDefaults	*u;
	NSMutableDictionary	*d;
	NSDictionary	*e;
	NSMutableArray	*a;
	// get data from user defaults
	//   (~/Library/Preferences/loginwindow.plist)
	u = [[NSUserDefaults alloc] init];
	if(!(d = [[u persistentDomainForName:loginwindow] mutableCopyWithZone:NULL]))
		d = [[NSMutableDictionary alloc] initWithCapacity:1];
	if(!(a = [[d objectForKey:@"AutoLaunchedApplicationDictionary"] mutableCopyWithZone:NULL]))
		a = [[NSMutableArray alloc] initWithCapacity:1];
	// build entry
	e = [[NSDictionary alloc] initWithObjectsAndKeys:
		 [NSNumber numberWithBool:hide], @"Hide",
		 path, @"Path",
		 nil];
	// add entry
	if (e) {
		[a insertObject:e atIndex:0];
		[d setObject:a forKey:@"AutoLaunchedApplicationDictionary"];
	}
	// update user defaults
	[u removePersistentDomainForName:loginwindow];
	[u setPersistentDomain:d forName:loginwindow];
	[u synchronize];
	// clean up
	[e release];
	[a release];
	[d release];
	[u release];
}
*/
#pragma mark Login Items

- (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)theLoginItemsRefs ForPath:(CFURLRef)thePath {
	BOOL exists = NO;  
	UInt32 seedValue;
	
	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	NSArray * loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);  
	for (id item in loginItemsArray) {    
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
			if ([[(NSURL *)thePath path] hasSuffix:@"KeyShot.app"]) {
				[(id)thePath release];
				exists = YES;
			}
		}
	}
	CFRelease((CFArrayRef)loginItemsArray);
	return exists;
}

- (void)configureAuto {
	// Reference to shared file list
	LSSharedFileListRef theLoginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	
	if ([self loginItemExistsWithLoginItemReference:theLoginItemsRefs ForPath:(CFURLRef)[NSURL fileURLWithPath:@"/Applications/KeyShot.app"]]) {
		NSLog(@"Exists");
		return;
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/KeyShot.app"]) {
		NSRunAlertPanel(@"Not Properly Installed", @"This application needs to be located at /Applications/KeyShot.app to function properly.  Make sure you followed the directions in the DMG you downloaded.", @"OK", nil, nil);
		return;
	}
	
	
	// CFURLRef to the insertable item.
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:@"/Applications/KeyShot.app"];
	
	// Actual insertion of an item.
	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(theLoginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
	
	// Clean up in case of success
	if (item) 
		CFRelease(item);
	
	CFRelease(theLoginItemsRefs);
}

#pragma mark Lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	[self configureAuto];
	
	[ANKeyEvent configureKeyboard];
	[self loadFromDefaults];
	NSMenu * menu = [self createMenu];
	NSStatusItem * _statusItem = [[[NSStatusBar systemStatusBar]
								   statusItemWithLength:NSSquareStatusItemLength] retain];
	[_statusItem setMenu:menu];
	[_statusItem setHighlightMode:YES];
	[_statusItem setToolTip:@"Key Shot"];
	[_statusItem setImage:[NSImage imageNamed:@"favicon"]];
	
	wc = [[NSWindowController alloc] initWithWindow:window];
}

- (IBAction)changeSettings:(id)sender {
	int row = [tv selectedRow];
	if (row < 0) {
		NSBeep();
		return;
	}
	
	ANApplicationHotKey * hk = [keystrokes objectAtIndex:row];
	[hk setAppName:[text_appName stringValue]];
	[hk setAppPath:[NSString stringWithFormat:@"%@", [text_appPath stringValue]]];
	ANKeyEvent * ke = [hk keyEvent];
	if (ke.isRegistered) [ke unregisterEvent];
	[ke setKey_code:[ANKeyEvent keyCodeForString:[popup_keys titleOfSelectedItem]]];
	[ke setKey_control:[check_control state]];
	[ke setKey_command:[check_command state]];
	[ke setKey_option:[check_option state]];
	[ke setKey_shift:[check_shift state]];
	[hk setKeyEvent:ke];
	[ke registerEvent];
	
	[tv reloadData];
	
	[self saveUserSettings];
}

- (IBAction)addShortcut:(id)sender {
	ANKeyEvent * ke = [[ANKeyEvent alloc] init];
	ANApplicationHotKey * ahk = [[ANApplicationHotKey alloc] init];
	[ahk setKeyEvent:ke];
	[ahk setAppName:@"Untitled"];
	[ahk setAppPath:@""];
	[keystrokes addObject:ahk];
	[tv reloadData];
	
	NSIndexSet * set = [[NSIndexSet alloc] initWithIndex:([keystrokes count] - 1)];
	[tv selectRowIndexes:set byExtendingSelection:NO];
	[set release];
	
	[self saveUserSettings];
	[self tableViewSelectionDidChange:nil];
	[ke release];
}

- (IBAction)removeShortcut:(id)sender {
	int sel = [tv selectedRow];
	if (sel > -1) {
		ANKeyEvent * ke = [[keystrokes objectAtIndex:sel] keyEvent];
		[ke unregisterEvent];
		[keystrokes removeObjectAtIndex:sel];
		[tv reloadData];
		NSIndexSet * set = [[NSIndexSet alloc] initWithIndex:sel];
		if (sel < [keystrokes count])
			[tv selectRowIndexes:set byExtendingSelection:NO];
		[set release];
	}
	[self saveUserSettings];
	[self tableViewSelectionDidChange:nil];
}

- (void)dealloc {
	[keystrokes release];
	keystrokes = nil;
	[tv setDelegate:nil];
	[tv setDataSource:nil];
	[super dealloc];
}

#pragma mark Table View Methods

- (long)numberOfRowsInTableView:(NSTableView *)tv {
	return [keystrokes count];
}

- (NSString *)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(long)row {
	NSString * v = [(ANApplicationHotKey *)[keystrokes objectAtIndex:row] appName];
	//NSLog(@"%d: %@", row, v);
	return v;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	int row = [tv selectedRow];
	if (row < 0) [self disableControls];
	else {
		
		[self enableControls];
		
		ANApplicationHotKey * hk = [keystrokes objectAtIndex:row];
		[text_appName setStringValue:[hk appName]];		
		[text_appPath setStringValue:[hk appPath]];
		[popup_keys selectItemWithTitle:[[hk keyEvent] keyTitle]];
		[check_command setState:[[hk keyEvent] key_command]];
		[check_control setState:[[hk keyEvent] key_control]];
		[check_option setState:[[hk keyEvent] key_option]];
		[check_shift setState:[[hk keyEvent] key_shift]];
	}
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return YES;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object 
   forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if (row >= 0) {
		ANApplicationHotKey * hk = [keystrokes objectAtIndex:row];
		[hk setAppName:object];
		
		//[tv reloadData];
		[self tableViewSelectionDidChange:nil];
		
		
		[self saveUserSettings];
	}
}

@end
