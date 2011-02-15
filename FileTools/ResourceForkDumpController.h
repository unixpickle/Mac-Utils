//
//  ResourceForkDumpController.h
//  FileTools
//
//  Created by Alex Nichol on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResourceForkManager.h"

@interface ResourceForkDumpController : NSObject {
	IBOutlet NSTextField * filePath;
	IBOutlet NSWindow * window;
}

- (IBAction)pickPath:(id)sender;
- (IBAction)dump:(id)sender;

@end
