//
//  ANProgressBar.h
//  FileTools
//
//  Created by Alex Nichol on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ANProgressBar : NSView {
	float progress;
}

// progress between 0-100
- (void)setProgress:(float)p;
- (float)progress;

@end
