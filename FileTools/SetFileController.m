//
//  SetFileController.m
//  FileTools
//
//  Created by Alex Nichol on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SetFileController.h"

BOOL isInvisibleCFURL (CFURLRef inURL) {
	LSItemInfoRecord itemInfo;
	LSCopyItemInfoForURL(inURL, kLSRequestAllFlags, &itemInfo);
	
	BOOL isInvisible = itemInfo.flags & kLSItemInfoIsInvisible;
	return isInvisible;
}

@implementation SetFileController

- (void)awakeFromNib {
	NSString * path = [NSString stringWithFormat:@"%@/Library/Preferences/com.apple.finder.plist", NSHomeDirectory()];
	NSMutableDictionary * d = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[graySwitch setIsOn:[[d objectForKey:@"AppleShowAllFiles"] boolValue]];
	[graySwitch setTarget:self];
	[graySwitch setAction:@selector(showHiddenFiles:)];
}

- (IBAction)pathChange:(id)sender {
	NSURL * url = [NSURL fileURLWithPath:[pathBox stringValue]];
	[isHidden setState:isInvisibleCFURL((CFURLRef)url)];
}

- (IBAction)pickPath:(id)sender {
	NSOpenPanel * openDlg = [NSOpenPanel openPanel];
	
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:YES];
	
	if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
		NSArray * files = [openDlg filenames];
		[pathBox setStringValue:[files objectAtIndex:0]];
		[self pathChange:nil];
	}
}

- (IBAction)hiddenChange:(id)sender {
	NSURL * url = [NSURL fileURLWithPath:[pathBox stringValue]];
	LSItemInfoRecord itemInfo;
	LSCopyItemInfoForURL((CFURLRef)url, kLSRequestAllFlags, &itemInfo);
	
	FSRef fsRef;
	if (!CFURLGetFSRef((CFURLRef)url, &fsRef)) {
		NSLog(@"Not a file.");
		NSBeep();
		return;
	}
	
	// Get the file's catalog info
    FSCatalogInfo * catalogInfo = (FSCatalogInfo *)malloc(sizeof(FSCatalogInfo));
    OSErr err = FSGetCatalogInfo(&fsRef, kFSCatInfoFinderInfo, catalogInfo, NULL, NULL, NULL);
	
    if (err != noErr) {
		NSLog(@"No catalog info.");
        free(catalogInfo);
        return;
    }
	
    // Extract the Finder info from the FSRef's catalog info
    FInfo * info = (FInfo *)(&catalogInfo->finderInfo[0]);
	
    // Toggle the invisibility flag
    if (info->fdFlags & kIsInvisible) {
		if (![isHidden state]) {
			info->fdFlags ^= kIsInvisible;
		}
	} else {
		if ([isHidden state]) {
			info->fdFlags |= kIsInvisible;
		}
	}
	
    // Update the file's visibility
    err = FSSetCatalogInfo(&fsRef, kFSCatInfoFinderInfo, catalogInfo);
	
    if (err != noErr) {
		NSLog(@"No setting invisibility.");
        free(catalogInfo);
        return;
    }
	
    free(catalogInfo);
}

- (void)showHiddenFiles:(id)sender {
	NSString * path = [NSString stringWithFormat:@"%@/Library/Preferences/com.apple.finder.plist", NSHomeDirectory()];
	NSMutableDictionary * d = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[d setObject:[NSNumber numberWithBool:[graySwitch isOn]] forKey:@"AppleShowAllFiles"];
	[d writeToFile:path atomically:YES];
	system("killall Finder");
}

@end
