//
//  ResourceForkModController.m
//  FileTools
//
//  Created by Alex Nichol on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResourceForkModController.h"


@implementation ResourceForkModController

- (IBAction)pickPath:(id)sender {
	NSOpenPanel * openDlg = [NSOpenPanel openPanel];
	
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:YES];
	
	if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
		NSArray * files = [openDlg filenames];
		[filePath setStringValue:[files objectAtIndex:0]];
	}	
}
- (IBAction)pickFork:(id)sender {
	NSOpenPanel * openDlg = [NSOpenPanel openPanel];
	
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:YES];
	
	if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
		NSArray * files = [openDlg filenames];
		[newFork setStringValue:[files objectAtIndex:0]];
	}
}
- (IBAction)setFork:(id)sender {
	[convertButton setEnabled:NO];
	[loader startAnimation:self];
	NSString * obj1 = [[NSString alloc] initWithString:[filePath stringValue]];
	NSString * obj2 = [[NSString alloc] initWithString:[newFork stringValue]];
	NSArray * paths = [[NSArray alloc] initWithObjects:obj1, obj2, nil];
	[obj1 release];
	[obj2 release];
	[self performSelectorInBackground:@selector(ulThread:) 
						   withObject:paths];
}
- (void)ulThread:(NSArray *)paths {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[paths autorelease];
	
	// write the contents here
	ResourceForkManager * man = [[ResourceForkManager alloc] init];
	NSData * fileContents = [NSData dataWithContentsOfFile:[paths objectAtIndex:1]];
	[man openResourceForFile:[paths objectAtIndex:0]];
	[man writeDataToFile:fileContents];
	[man release];
	
	[self performSelectorOnMainThread:@selector(loadDone) withObject:nil
						waitUntilDone:NO];
	
	[pool drain];
}
- (void)loadDone {
	[loader stopAnimation:self];
	[convertButton setEnabled:YES];
}

@end
