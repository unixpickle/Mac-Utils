//
//  SetFileController.h
//  FileTools
//
//  Created by Alex Nichol on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANGraySwitch.h"

@interface SetFileController : NSObject {
	IBOutlet ANGraySwitch * graySwitch;
	IBOutlet NSTextField * pathBox;
	IBOutlet NSButton * isHidden;
}

- (IBAction)hiddenChange:(id)sender;
- (IBAction)pathChange:(id)sender;
- (IBAction)pickPath:(id)sender;
- (void)showHiddenFiles:(id)sender;

@end
