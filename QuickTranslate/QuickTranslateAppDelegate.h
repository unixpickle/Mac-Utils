//
//  QuickTranslateAppDelegate.h
//  QuickTranslate
//
//  Created by Alex Nichol on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GTTranslator.h"

@interface QuickTranslateAppDelegate : NSObject <NSApplicationDelegate, GTTranslatorDelegate, NSTextFieldDelegate> {
    NSWindow * window;
	IBOutlet NSTextField * firstField;
	IBOutlet NSTextField * secondField;
	IBOutlet NSTextField * labelOne;
	IBOutlet NSTextField * labelTwo;
	// 0 = french-english
	// 1 = english-french
	int order;
	GTTranslator * translator;
}

- (IBAction)switchOrder:(id)sender;
- (IBAction)translate:(id)sender;

@property (assign) IBOutlet NSWindow * window;

@end
