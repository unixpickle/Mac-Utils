//
//  miRSSAppDelegate.m
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "miRSSAppDelegate.h"
#import "RSSChannelView.h"

@implementation miRSSAppDelegate

@synthesize window;

- (void)centerWindow:(NSWindow *)_window {
	NSRect frame = [[NSScreen mainScreen] frame];
	NSRect wfram = [_window frame];
	wfram.origin.x = frame.size.width / 2 - (wfram.size.width / 2);
	wfram.origin.y = frame.size.height / 2 - (wfram.size.height / 2);
	[_window setFrameOrigin:wfram.origin];
}
- (IBAction)addDone:(id)sender {
	// add done
	[manager addRSSURL:[addURL stringValue]];
	[self updateMenu];
	[addWindow orderOut:self];
}

- (void)addFeed:(id)sender {
	//
	ProcessSerialNumber num;	
	GetCurrentProcess(&num);
	SetFrontProcess(&num);
	[self centerWindow:addWindow];
	[addWindow makeKeyAndOrderFront:self];
	[addURL setStringValue:@""];
	[addURL selectText:self];
}
- (void)showFeed:(NSMenuItem *)menu {
	//
	if (!channelView) {
		channelView = [[RSSChannelView alloc] initWithFrame:[[window contentView] bounds]];
		[[window contentView] addSubview:channelView];
	}
	BOOL found = NO;
	if ([feedMenus objectForKey:menu]) {
		[channelView setChannel:[feedMenus objectForKey:menu]];
		found = YES;
	} else {
		int count = [manager channelCount];
		[manager lock];
		for (int i = 0; i < count; i++) {
			NSDictionary * dict = [manager channelAtIndex:i];
			if ([(RSSChannel *)[dict objectForKey:ANRSSManagerChannelRSSChannelKey] uniqueID] == [menu tag]) {
				found = YES;
				[channelView setChannel:[dict objectForKey:ANRSSManagerChannelRSSChannelKey]];
			}
		}
		[manager unlock];
	
	}
	if (found) {
		[window makeKeyAndOrderFront:self];
	
		ProcessSerialNumber num;	
		GetCurrentProcess(&num);
		SetFrontProcess(&num);
	}
}

- (IBAction)remove:(id)sender {
	// remove the stuff later
	if ([tableView selectedRow] >= 0) {
		[manager removeAtIndex:[tableView selectedRow]];
		[tableView reloadData];
	}
}

- (void)showFeeds:(id)sender {
	// show the window
	[channelsList makeKeyAndOrderFront:self];
	ProcessSerialNumber num;	
	GetCurrentProcess(&num);
	SetFrontProcess(&num);
	[tableView setDataSource:self];
	[tableView reloadData];
}

- (void)articlesUpdated:(id)sender {
	[self updateMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	mainMenu = [self createMenu];
	
	statusItem = [[[NSStatusBar systemStatusBar]
                                   statusItemWithLength:NSSquareStatusItemLength] retain];
    [statusItem setMenu:mainMenu];
    [statusItem setHighlightMode:YES];
    [statusItem setToolTip:@"miRSS"];
    [statusItem setImage:[NSImage imageNamed:@"rss.png"]];
	
	manager = [[ANRSSManager alloc] init];
	[manager setDelegate:self];
	[manager startFetchThread];
	[manager addRSSURL:@"http://macheads101.aqnichol.com/pages/news/rss.php"];
}

- (void)updateMenu {
	NSLog(@"Update.");
	
	[tableView setDataSource:self];
	[tableView reloadData];
	
	int count = [manager channelCount];
	
	[rssFeedsMenu removeAllItems];
	[feedMenus removeAllObjects];
	
	[manager lock];
	
	// loop through
	for (int i = 0; i < count; i++) {
		NSDictionary * channeld = [manager channelAtIndex:i];
		// read the stuff
		RSSChannel * channel = [channeld objectForKey:ANRSSManagerChannelRSSChannelKey];
		//int new = 0;
		NSString * title = [channel channelTitle];
		BOOL enabled = YES;
		if (!title) {
			title = [channeld objectForKey:ANRSSManagerChannelURLKey];
			enabled = NO;
		}
		if (title) {
			NSMenuItem * item = [rssFeedsMenu addItemWithTitle:title
													action:@selector(showFeed:)
											 keyEquivalent:@""];
			[item setTag:[channel uniqueID]];
			if (enabled)
				[item setTarget:self];
			else {
				[item setTarget:nil];
				[item setAction:0];
			}
			[item setEnabled:enabled];
			if (channel)
				[feedMenus setObject:channel forKey:item];
		}
	}
	
	[mainMenu setSubmenu:rssFeedsMenu forItem:rssFeedsItem];
	[statusItem setMenu:nil];
	[statusItem setMenu:mainMenu];
	
	[manager unlock];
}

- (NSMenu *)createMenu {
	feedMenus = [[NSMutableDictionary alloc] init];
    NSZone * menuZone = [NSMenu menuZone];
    NSMenu * menu = [[NSMenu allocWithZone:menuZone] init];
    NSMenuItem * menuItem;
	
    // Add To Items
    menuItem = [menu addItemWithTitle:@"Add Feed"
                               action:@selector(addFeed:)
                        keyEquivalent:@""];
	[menuItem setTarget:self];
	
	menuItem = [menu addItemWithTitle:@"Edit Feeds"
                               action:@selector(showFeeds:)
                        keyEquivalent:@""];
	[menuItem setTarget:self];
	
	rssFeedsItem = [menu addItemWithTitle:@"Feeds"
                               action:@selector(showFeed:)
                        keyEquivalent:@""];
    [rssFeedsItem setTarget:self];
	[rssFeedsItem setEnabled:YES];
	
	// create the submenu
	rssFeedsMenu = [[NSMenu alloc] initWithTitle:@"Feeds"];
	//[rssFeedsItem setMenu:menu];
	
	menuItem = [menu addItemWithTitle:@"Quit"
                               action:@selector(terminate:)
                        keyEquivalent:@""];
    [menuItem setTarget:[NSApplication sharedApplication]];
	
    return menu;
}

#pragma mark Table View Methods

- (long)numberOfRowsInTableView:(NSTableView *)tv {
	return [manager channelCount];
}

- (NSString *)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(long)row {
	if (row >= 0) {
		[manager lock];
		
		NSDictionary * post = [manager channelAtIndex:row];
		NSString * string = [NSString stringWithString:[post objectForKey:ANRSSManagerChannelURLKey]];
		
		[manager unlock];
		return string;
	}
}


@end
