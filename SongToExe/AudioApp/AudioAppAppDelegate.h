//
//  AudioAppAppDelegate.h
//  AudioApp
//
//  Created by Alex Nichol on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AudioAppAppDelegate : NSObject {
    NSWindow * window;
	BOOL loop;
	NSString * audioPath;
	NSSound * current;
}

@property (assign) IBOutlet NSWindow *window;

@end
