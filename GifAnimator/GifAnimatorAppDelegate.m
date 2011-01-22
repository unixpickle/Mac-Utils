//
//  GifAnimatorAppDelegate.m
//  GifAnimator
//
//  Created by Alex Nichol on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GifAnimatorAppDelegate.h"

@implementation GifAnimatorAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	imageFiles = [[NSMutableArray alloc] init];
	[files setDataSource:self];
	[files setDelegate:self];
	[files registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];

}

- (IBAction)stepChange:(id)sender {
	// move up or down
	[fpsBox setStringValue:[NSString stringWithFormat:@"%d", [upDown intValue]]];
}
- (IBAction)moveUp:(id)sender {
	int selected = [files selectedRow];
	if (selected < 0) {
		NSBeep();
		return;
	}
	NSString * moving = [[imageFiles objectAtIndex:selected] retain];
	NSString * old = [[imageFiles objectAtIndex:(selected - 1)] retain];
	if (selected - 1 < 0) return;
	[imageFiles replaceObjectAtIndex:(selected - 1) withObject:moving];
	[imageFiles replaceObjectAtIndex:selected withObject:old];
	[moving release];
	[old release];
	[files reloadData];
	[files selectRowIndexes:[NSIndexSet indexSetWithIndex:selected-1]
	   byExtendingSelection:NO];
}
- (IBAction)moveDown:(id)sender {
	int selected = [files selectedRow];
	if (selected < 0) {
		NSBeep();
		return;
	}
	NSString * moving = [[imageFiles objectAtIndex:selected] retain];
	NSString * old = [[imageFiles objectAtIndex:(selected + 1)] retain];
	if (selected + 1 >= [imageFiles count]) return;
	[imageFiles replaceObjectAtIndex:(selected + 1) withObject:moving];
	[imageFiles replaceObjectAtIndex:selected withObject:old];
	[moving release];
	[old release];
	[files reloadData];
	[files selectRowIndexes:[NSIndexSet indexSetWithIndex:selected+1]
	   byExtendingSelection:NO];
}
- (IBAction)remove:(id)sender {
	int selected = [files selectedRow];
	if (selected < 0) {
		NSBeep();
		return;
	}
	[imageFiles removeObjectAtIndex:selected];
	[files reloadData];
}
- (IBAction)export:(id)sender {
	// create the GIF save dialog
	NSSavePanel * save = [NSSavePanel savePanel];
	[save setRequiredFileType:@"gif"];
	[save setMessage:@"Export a gif file"];
	int res = [save runModal];
	if (res == NSOKButton) {
		NSString * fname1 = [save filename];
		ANGifEncoder * enc = [[ANGifEncoder alloc] initWithFile:fname1
													   animated:YES];
		BOOL started = NO;
		for (NSString * file in imageFiles) {
			NSImage * image = [[NSImage alloc] initWithContentsOfFile:file];
			ANGifBitmap * bmp = [[ANGifBitmap alloc] initWithImage:image];
			if (!started) {
				[enc beginFile:[bmp size] delayTime:(1.0f / [upDown floatValue])];
				started = YES;
			}
			[enc addImage:bmp];
			[bmp release];
			[image release];
		}
		[enc endFile];
		[enc release];
	}
}

#pragma mark Table View

- (NSDragOperation)tableView:(NSTableView *)tv1 validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
    // Add code here to validate the drop
	if (![files isEnabled]) return NSDragOperationNone;
	return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row dropOperation:(NSTableViewDropOperation)operation {
	if ([info draggingSource]) {
		NSRunAlertPanel(@"Not supported", @"Moving images is not supported", @"OK", nil, nil);
		return NO;
	}
	if (![aTableView isEnabled]) return NO;
    NSPasteboard * pboard = [info draggingPasteboard];
	NSArray * filenames = [pboard propertyListForType:NSFilenamesPboardType];
	for (int i = 0; i < [filenames count]; i++) {
		NSString * fileName1 = [filenames objectAtIndex:i];
		[imageFiles insertObject:fileName1 atIndex:row];
		NSLog(@"%@", fileName1);
		row++;
	}
	
    // Move the specified row to its new location...
	[files reloadData];
	return YES;
}

- (int)numberOfRowsInTableView:(NSTableView *)tv {
	return [imageFiles count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	if ([files selectedRow] < 0) return;
	NSString * file = [imageFiles objectAtIndex:[files selectedRow]];
	NSImage * img = [[NSImage alloc] initWithContentsOfFile:file];
	[currentImage setImage:[img autorelease]];
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	return [[imageFiles objectAtIndex:row] lastPathComponent];
}

@end
