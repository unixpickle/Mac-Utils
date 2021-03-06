//
//  WhenFileAppController.m
//  WhenFile
//
//  Created by Alex Nichol on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WhenFileAppController.h"


@implementation WhenFileAppController

@synthesize window, currentPath;

- (IBAction)pickPath:(id)sender {
	NSOpenPanel * openDlg = [NSOpenPanel openPanel];
	
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:YES];
	
	if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
		NSArray * files = [openDlg filenames];
		self.currentPath = [files lastObject];
		[pathBox setStringValue:currentPath];
		NSDictionary * dict = [[NSFileManager defaultManager] attributesOfItemAtPath:self.currentPath
																			   error:nil];
		[modified setDateValue:[dict objectForKey:NSFileModificationDate]];
		[created setDateValue:[dict objectForKey:NSFileCreationDate]];
	}
}

- (IBAction)dateChange:(id)sender {
	// set the date on the selected file
	if (self.currentPath) {
		NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.currentPath
																					 error:nil];
		NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:attributes];
		[dict setObject:[created dateValue] forKey:NSFileCreationDate];
		[dict setObject:[modified dateValue] forKey:NSFileModificationDate];
		NSError * e = nil;
		if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:self.currentPath error:&e]) {
			NSRunAlertPanel(@"Error changing date.", 
							[NSString stringWithFormat:@"Error changing date: %@", [e localizedDescription]],
							@"OK", nil, nil);
		}
	}
}

- (IBAction)saveChanges:(id)sender {
	[self dateChange:self];
}

- (void)dealloc {
	self.currentPath = nil;
	[super dealloc];
}

@end
