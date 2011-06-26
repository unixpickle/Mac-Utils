//
//  ExportWindow.h
//  SongToExe
//
//  Created by Alex Nichol on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AudioFileEncoder.h"


@interface ExportWindow : NSWindow {
	/* UI */
	NSProgressIndicator * loadingBar;
	NSTextField * loadingStage;
	NSButton * cancelButton;
	
	/* State Changes */
	NSLock * returnCodeLock;
	int returnCode; // 257 = not finished, anything else = done.  0 = success once done.
	NSLock * cancelledLock;
	BOOL cancelled;
	
	NSString * tempDirectory;
}

@property (nonatomic, retain) NSString * tempDirectory;

- (void)cancelPressed:(id)sender;

- (void)startExporting:(NSString *)audioFile;
- (void)setStage:(NSString *)stage;
- (void)setProgress:(float)stageProgress;

@end
