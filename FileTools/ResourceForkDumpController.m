//
//  ResourceForkDumpController.m
//  FileTools
//
//  Created by Alex Nichol on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResourceForkDumpController.h"


@implementation ResourceForkDumpController

- (IBAction)pickPath:(id)sender {
	NSOpenPanel * openDlg = [NSOpenPanel openPanel];
	
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:YES];
	
	if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
		NSArray * files = [openDlg filenames];
		[filePath setStringValue:[files objectAtIndex:0]];
	}
}
- (IBAction)dump:(id)sender {
	// bring up a save dialog.
	NSSavePanel * spanel = [NSSavePanel savePanel];
	NSString * path = @"/Documents";
	[spanel setDirectory:[path stringByExpandingTildeInPath]];
	[spanel setPrompt:@"Save Document"];
	[spanel setRequiredFileType:@"raw"];
	
	[spanel beginSheetForDirectory:nil
							  file:nil
					modalForWindow:window
					 modalDelegate:self
					didEndSelector:@selector(didEndSaveSheet:returnCode:conextInfo:)
					   contextInfo:NULL];
}
- (void)didEndSaveSheet:(NSSavePanel *)savePanel returnCode:(int)returnCode conextInfo:(void *)contextInfo {
	if (returnCode == NSOKButton) {
		NSString * f = [savePanel filename];
		if (![[NSFileManager defaultManager] fileExistsAtPath:[filePath stringValue]]) {
			NSRunAlertPanel(@"Not Found", @"The file path that you specified either does not exist, or cannot be opened.", 
							@"OK", nil, nil);
			return;
		}
		ResourceForkManager * man = [[ResourceForkManager alloc] init];
		[man openResourceForFile:[filePath stringValue]];
		NSData * data = [man readDataFromFile];
		if (!data) {
			[[NSData dataWithBytes:NULL length:0] writeToFile:f atomically:YES];
		} else [data writeToFile:f atomically:YES];
		[man release];
	}
}

@end
