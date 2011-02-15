//
//  FileToolsAppDelegate.m
//  FileTools
//
//  Created by Alex Nichol on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileToolsAppDelegate.h"

@implementation FileToolsAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	ANSideMenuTitle * setTitle = [[ANSideMenuTitle alloc] initWithTitle:@"DATES"];
	ANSideMenuItem * setDate = [[ANSideMenuItem alloc] initWithTitle:@"File Dates"
																icon:[NSImage imageNamed:@"whenicon.png"]];
	ANSideMenuItem * setVideo = [[ANSideMenuItem alloc] initWithTitle:@"Quicktime Dates"
																 icon:[NSImage imageNamed:@"movieicon.png"]];
	ANSideMenuTitle * title2 = [[ANSideMenuTitle alloc] initWithTitle:@"FILES"];
	ANSideMenuItem * deleteFiles = [[ANSideMenuItem alloc] initWithTitle:@"Secure Delete"
																	icon:[NSImage imageNamed:@"trashfull.png"]];
	ANSideMenuItem * setFiles = [[ANSideMenuItem alloc] initWithTitle:@"File Flags"
																	icon:[NSImage imageNamed:@"finder.png"]];
	ANSideMenuTitle * title3 = [[ANSideMenuTitle alloc] initWithTitle:@"RESOURCE FORKS"];

	ANSideMenuItem * dumpFork = [[ANSideMenuItem alloc] initWithTitle:@"Resource Fork Dump"
																 icon:[NSImage imageNamed:@"resourcefork.png"]];
	ANSideMenuItem * setFork = [[ANSideMenuItem alloc] initWithTitle:@"Resource Fork Set"
																 icon:[NSImage imageNamed:@"resourcefork.png"]];
	switching = NO;
	[setDate setDelegate:self];
	[setVideo setDelegate:self];
	[deleteFiles setDelegate:self];
	[setFiles setDelegate:self];
	[dumpFork setDelegate:self];
	[setFork setDelegate:self];
	[setDate setSelected:YES];
	
	NSArray * items = [NSArray arrayWithObjects:setTitle, 
					   setDate, setVideo, title2, deleteFiles, 
					   setFiles, title3, dumpFork, setFork, nil];
	menu = [[ANSideMenu alloc] initWithFrame:NSMakeRect(0, 0, 200, [[window contentView] frame].size.height)];
	[menu setItems:items];
	[[window contentView] addSubview:menu];
	
	[setTitle release];
	[setVideo release];
	[setDate release];
	[dumpFork release];
	[title3 release];
	[deleteFiles release];
	[title2 release];
	[setFiles release];
	[menu release];
	[window setDelegate:self];
	[window makeFirstResponder:menu];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
	// content size
	CGFloat topSize = [window frame].size.height - [[window contentView] frame].size.height;
	[menu setFrame:NSMakeRect(0, 0, 200, frameSize.height - topSize)];
	return frameSize;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	//[window makeFirstResponder:menu];
	[menu windowFocus];
}

- (void)applicationDidResignActive:(NSNotification *)notification {
	[menu windowUnfocus];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

- (void)fadeDown:(NSView *)v {
	switching = YES;
	if (!v || !kUseAnimation) {
		[v removeFromSuperview];
		switching = NO;
		return;
	}
	float scale = 1 / [v alphaValue];
	[v setAlphaValue:[v alphaValue] - 0.05];
	
	if ([v alphaValue] > 0.1)
		[v setBoundsSize:NSMakeSize(400.0 * scale,
									500.0 * scale)];
	[v setNeedsDisplay:YES];
	if ([v alphaValue] > 0.1) {
		[self performSelector:@selector(fadeDown:)
				   withObject:v afterDelay:(1/60.0)];
	} else {
		[v setAlphaValue:1];
		[v setBoundsSize:NSMakeSize(400, 500)];
		[v removeFromSuperview];
		switching = NO;
	}
}

- (void)sideMenuSelected:(ANSideMenuItem *)sender {
	[window makeFirstResponder:menu];
	NSLog(@"%@", [sender title]);
	if (switching) {
		@throw [NSException exceptionWithName:@"Changing"
									   reason:@"Don't do this."
									 userInfo:nil];
		return;
	}
	
	NSView * lastView = nil;
	for (NSView * v in [mainView subviews]) {
		lastView = v;
	}
	if ([[sender title] isEqual:@"File Dates"]) {
		[mainView addSubview:whenFileView];
		if (lastView == whenFileView) lastView = nil;
		[whenFileView setBoundsSize:NSMakeSize(400, 500)];
		[whenFileView setAlphaValue:1];
	} else if ([[sender title] isEqual:@"Quicktime Dates"]) {
		[mainView addSubview:quicktimeView];
		if (lastView == quicktimeView) lastView = nil;
		[quicktimeView setBoundsSize:NSMakeSize(400, 500)];
		[quicktimeView setAlphaValue:1];
	} else if ([[sender title] isEqual:@"Secure Delete"]) {
		[mainView addSubview:deleteView];
		if (lastView == deleteView) lastView = nil;
		[deleteView setBoundsSize:NSMakeSize(400, 500)];
		[deleteView setAlphaValue:1];
	} else if ([[sender title] isEqual:@"File Flags"]) {
		[mainView addSubview:setFileView];
		if (lastView == setFileView) lastView = nil;
		[setFileView setBoundsSize:NSMakeSize(400, 500)];
		[setFileView setAlphaValue:1];
	} else if ([[sender title] isEqual:@"Resource Fork Dump"]) {
		[mainView addSubview:resourceForkView];
		if (lastView == resourceForkView) lastView = nil;
		[resourceForkView setBoundsSize:NSMakeSize(400, 500)];
		[resourceForkView setAlphaValue:1];
	} else if ([[sender title] isEqual:@"Resource Fork Set"]) {
		[mainView addSubview:resourceForkChangeView];
		if (lastView == resourceForkChangeView) lastView = nil;
		[resourceForkChangeView setBoundsSize:NSMakeSize(400, 500)];
		[resourceForkChangeView setAlphaValue:1];
	}
	if (lastView) {
		[lastView removeFromSuperview];
		[mainView addSubview:lastView];
		[lastView setAlphaValue:1];
		[self fadeDown:lastView];
	}
}

@end
