//
//  iChatImagesAppDelegate.h
//  iChatImages
//
//  Created by Alex Nichol on 10/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANChatImageCache.h"

@interface iChatImagesAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource, ANChatImageCacheDelegate> {
	NSWindow * window;
	IBOutlet NSTableView * tableView;
	IBOutlet NSImageView * preview;
	IBOutlet NSTextField * pathLabel;
	IBOutlet NSTextField * dateLabel;
	ANChatImageCache * imageCache;
	NSMutableArray * images;
}

@property (assign) IBOutlet NSWindow * window;

- (IBAction)reload:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)reveal:(id)sender;
- (void)handleDoubleClick:(id)sender;

@end
