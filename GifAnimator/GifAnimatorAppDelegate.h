//
//  GifAnimatorAppDelegate.h
//  GifAnimator
//
//  Created by Alex Nichol on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANGifBitmap.h"
#import "ANGifEncoder.h"

@interface GifAnimatorAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow * window;
	IBOutlet NSTableView * files;
	IBOutlet NSStepper * upDown;
	IBOutlet NSTextField * fpsBox;
	IBOutlet NSImageView * currentImage;
	NSMutableArray * imageFiles;
}

- (IBAction)stepChange:(id)sender;
- (IBAction)moveUp:(id)sender;
- (IBAction)moveDown:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)export:(id)sender;

@property (assign) IBOutlet NSWindow * window;

@end
