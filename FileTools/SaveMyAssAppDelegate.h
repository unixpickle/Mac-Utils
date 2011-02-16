//
//  SaveMyAssAppDelegate.h
//  SaveMyAss
//
//  Created by Alex Nichol on 5/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SettingsView.h"
#import "ANDirectoryLister.h"
#import "ANProgressBar.h"

@interface SaveMyAssAppDelegate : NSObject <SettingsViewDelegate, NSSoundDelegate> {
    NSWindow * window;
	IBOutlet NSTextField * filePath;
	IBOutlet NSTextField * progressLabel;
	IBOutlet ANProgressBar * progress;
	long long totalBytes;
	long long currentBytes;
	IBOutlet SettingsView * settings;
	IBOutlet NSButton * eraseButton;
	NSThread * wipeThread;
	NSUserDefaults * defaults;
	int bufferSize, overwriteTimes;
	BOOL randomize;
	BOOL trash, dateOverwrite;
	NSMutableData * dat;
}

- (IBAction)erase:(id)sender;
- (IBAction)pickFile:(id)sender;

@property (assign) IBOutlet NSWindow * window;

@end
