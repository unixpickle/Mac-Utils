//
//  ResourceForkModController.h
//  FileTools
//
//  Created by Alex Nichol on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResourceForkManager.h"

@interface ResourceForkModController : NSObject {
	IBOutlet NSTextField * filePath;
	IBOutlet NSTextField * newFork;
	IBOutlet NSButton * convertButton;
	IBOutlet NSProgressIndicator * loader;
}

- (IBAction)pickPath:(id)sender;
- (IBAction)pickFork:(id)sender;
- (IBAction)setFork:(id)sender;
- (void)ulThread:(NSArray *)paths;
- (void)loadDone;

@end
