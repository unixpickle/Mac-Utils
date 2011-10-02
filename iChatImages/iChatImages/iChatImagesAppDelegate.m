//
//  iChatImagesAppDelegate.m
//  iChatImages
//
//  Created by Alex Nichol on 10/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iChatImagesAppDelegate.h"

@implementation iChatImagesAppDelegate

@synthesize window;

- (void)awakeFromNib {
	imageCache = [[ANChatImageCache alloc] init];
	images = [[NSMutableArray alloc] init];
	[imageCache setDelegate:self];
	[tableView setDoubleAction:@selector(handleDoubleClick:)];
	[self reload:self];
	[self tableViewSelectionDidChange:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	
}

- (void)reload:(id)sender {
	[imageCache cancelReloading];
	[imageCache startReloading];
}

- (IBAction)remove:(id)sender {
	NSInteger row = [tableView selectedRow];
	if (row >= 0) {
		ANCachedImage * image = [(ANCachedImage *)[images objectAtIndex:row] retain];
		[images removeObject:image];
		[[NSFileManager defaultManager] removeItemAtPath:[image fileName] error:nil];
		[image release];
		[tableView reloadData];
		[self tableViewSelectionDidChange:nil];
		/*[tableView beginUpdates];
		[tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
		[tableView endUpdates];
		if (row < [images count]) {
			[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		}*/
	}
}

- (IBAction)reveal:(id)sender {
	[self handleDoubleClick:self];
}

- (void)handleDoubleClick:(id)sender {
	NSInteger row = [tableView selectedRow];
	if (row >= 0) {
		NSString * file = [(ANCachedImage *)[images objectAtIndex:row] fileName];
		// NSURL * url = [NSURL fileURLWithPath:file];
		[[NSWorkspace sharedWorkspace] selectFile:file inFileViewerRootedAtPath:nil];
	}
}

- (void)chatImageCacheFailed:(ANChatImageCache *)cache {
	NSRunAlertPanel(@"Error", @"An error was encountered while searching for images.", @"OK", nil, nil);
}

- (void)chatImageCacheFinished:(ANChatImageCache *)cache {
	[images removeAllObjects];
	[images addObjectsFromArray:[cache imageFiles]];
	[tableView reloadData];
}

- (void)chatImageCacheFoundNewFiles:(ANChatImageCache *)cache {
	[images removeAllObjects];
	[images addObjectsFromArray:[cache imageFiles]];
	[tableView reloadData];
}

#pragma mark Table View

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [images count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return [[(ANCachedImage *)[images objectAtIndex:row] fileName] lastPathComponent];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	NSInteger selected = [tableView selectedRow];
	if (selected >= 0) {
		NSString * fileBase = [[(ANCachedImage *)[images objectAtIndex:selected] fileName] lastPathComponent];
		
		NSDateFormatter * format = [[NSDateFormatter alloc] init];
		[format setDateStyle:NSDateFormatterMediumStyle];
		[format setTimeStyle:NSDateFormatterNoStyle];
		NSString * dateName = [format stringFromDate:[(ANCachedImage *)[images objectAtIndex:selected] dateModified]];
		[format release];
		
		[preview setImage:[(ANCachedImage *)[images objectAtIndex:selected] thumbnail]];
		[pathLabel setStringValue:fileBase];
		[dateLabel setStringValue:[@"Creation date: " stringByAppendingString:dateName]];
		
	} else {
		[preview setImage:nil];
		[pathLabel setStringValue:@"N/a"];
		[dateLabel setStringValue:@"Creation date: N/a"];
	}
}

@end
