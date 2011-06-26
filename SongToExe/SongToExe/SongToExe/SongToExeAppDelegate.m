//
//  SongToExeAppDelegate.m
//  SongToExe
//
//  Created by Alex Nichol on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SongToExeAppDelegate.h"

@implementation SongToExeAppDelegate

@synthesize window;

- (void)awakeFromNib {
	// Insert code here to initialize your application
	[dragView setDelegate:self];
}

- (IBAction)itemClicked:(id)sender {
	if (![sender isKindOfClass:[NSMenuItem class]]) return;
	NSMenuItem * item = (NSMenuItem *)sender;
	[item setState:[item state]^1];
	if (item == createUnixExe && [item state] == 1) {
		if ([doLoop state]) [doLoop setState:0];
		if ([showInDock state]) [showInDock setState:0];
	} else if (item  == doLoop && [item state] == 1) {
		if ([createUnixExe state]) [createUnixExe setState:0];
	} else if (item  == showInDock && [item state] == 1) {
		if ([createUnixExe state]) [createUnixExe setState:0];
	}
}

- (void)dragViewDroppedFile:(DragView *)dv {
	[self performSelector:@selector(startEncodingFile:) withObject:[dv fileName] afterDelay:0.1];
}

- (void)startEncodingFile:(NSString *)file {
	if ([createUnixExe state]) [self startEncodingUnixExe:file];
	else [self encodeApp:file];
}

- (void)startEncodingUnixExe:(NSString *)file {
	ExportWindow * ew = [[ExportWindow alloc] initWithContentRect:NSMakeRect(0, 0, 400, 100) styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO];
	[NSApp beginSheet:ew modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	[ew startExporting:file];
	[ew release];
}

- (void)encodeApp:(NSString *)file {
	appInfo.doLoop = ([doLoop state] == 1 ? YES : NO);
	appInfo.showInDock = ([showInDock state] == 1 ? YES : NO);
	[appInfo.audioFile release];
	appInfo.audioFile = [file retain];
	// open save dialogue.
	NSSavePanel * spanel = [NSSavePanel savePanel];
	NSString * path = @"~/Desktop";
	[spanel setDirectory:[path stringByExpandingTildeInPath]];
	[spanel setPrompt:@"Save Executable"];
	[spanel setRequiredFileType:@"app"];
	
	[spanel beginSheetForDirectory:[spanel directory]
							  file:nil
					modalForWindow:window
					 modalDelegate:self
					didEndSelector:@selector(didEndSaveSheet:returnCode:conextInfo:)
					   contextInfo:NULL];
}

- (void)didEndSaveSheet:(NSSavePanel *)savePanel returnCode:(int)_returnCode conextInfo:(void *)contextInfo {
	if (_returnCode == NSOKButton) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:[savePanel filename]]) {
			if (![[NSFileManager defaultManager] removeItemAtPath:[savePanel filename] error:nil]) {
				NSRunAlertPanel(@"Export error", [NSString stringWithFormat:@"Failed to overwrite: %@"], [savePanel filename], @"OK", nil, nil);
				return;
			}
		}
		NSString * savePath = [savePanel filename];
		NSString * audioApp = [[NSBundle mainBundle] pathForResource:@"AudioApp" ofType:@"app"];
		if (![[NSFileManager defaultManager] fileExistsAtPath:audioApp] || !audioApp) {
			NSRunAlertPanel(@"Export error", @"AudioApp.app is missing from the bundle's resource folder.  Cannot export.", @"OK", nil, nil);
			return;
		}
		if (![[NSFileManager defaultManager] copyItemAtPath:audioApp toPath:savePath error:nil]) {
			NSRunAlertPanel(@"Export error", @"Failed to save the existing audio application.", @"OK", nil, nil);
			return;
		}
		[self customizeAudioApp:savePath];
	} else {
		
	}
}

- (void)customizeAudioApp:(NSString *)defaultPath {
	NSString * contents = [defaultPath stringByAppendingPathComponent:@"Contents"];
	NSString * resources = [contents stringByAppendingPathComponent:@"Resources"];
	NSString * info = [contents stringByAppendingPathComponent:@"Info.plist"];
	NSString * extrainfo = [resources stringByAppendingPathComponent:@"extrainfo.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:extrainfo]) {
		NSRunAlertPanel(@"No extrainfo.plist", @"The extrainfo.plist file was not found in AudioApp.app", @"OK", nil, nil);
		return;
	}
	if (![[NSFileManager defaultManager] fileExistsAtPath:info]) {
		NSRunAlertPanel(@"No Info.plist", @"The Info.plist file was not found in AudioApp.app", @"OK", nil, nil);
		return;
	}
	NSMutableDictionary * keys = [NSMutableDictionary dictionaryWithContentsOfFile:extrainfo];
	[keys setObject:[NSNumber numberWithBool:appInfo.doLoop] forKey:@"loop"];
	[keys setObject:[appInfo.audioFile lastPathComponent] forKey:@"audio"];
	if (appInfo.showInDock) {
		NSMutableDictionary * infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:info];
		if ([infoDict objectForKey:@"LSUIElement"]) {
			[infoDict removeObjectForKey:@"LSUIElement"];
		}
		[infoDict writeToFile:info atomically:YES];
	}
	[keys writeToFile:extrainfo atomically:YES];
	NSString * destinationResource = [resources stringByAppendingPathComponent:[appInfo.audioFile lastPathComponent]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:destinationResource]) {
		if (![[NSFileManager defaultManager] removeItemAtPath:destinationResource error:nil]) {
			NSRunAlertPanel(@"Delete Failed.", @"Failed to delete resource.", @"OK", nil, nil);
			return;
		}
	}
	if (![[NSFileManager defaultManager] copyItemAtPath:appInfo.audioFile toPath:destinationResource error:nil]) {
		NSRunAlertPanel(@"Export error", @"Failed to copy the audio resource to the applicatoin bundle.", @"OK", nil, nil);
	}
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	// who cares
}

- (void)dealloc {
	[appInfo.audioFile release];
	[super dealloc];
}

@end
