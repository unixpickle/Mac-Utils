//
//  SongToExeAppDelegate.h
//  SongToExe
//
//  Created by Alex Nichol on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragView.h"
#import "ExportWindow.h"

struct appEncodingInfo {
	BOOL doLoop;
	BOOL showInDock;
	NSString * audioFile;
};

@interface SongToExeAppDelegate : NSObject <DragViewDelegate> {
	NSWindow * window;
	IBOutlet DragView * dragView;
	IBOutlet NSMenuItem * createUnixExe;
	IBOutlet NSMenuItem * doLoop;
	IBOutlet NSMenuItem * showInDock;
	struct appEncodingInfo appInfo;
}

@property (assign) IBOutlet NSWindow * window;

- (IBAction)itemClicked:(id)sender;
- (void)startEncodingFile:(NSString *)file;
- (void)startEncodingUnixExe:(NSString *)file;

- (void)encodeApp:(NSString *)file;
- (void)customizeAudioApp:(NSString *)defaultPath;

@end
