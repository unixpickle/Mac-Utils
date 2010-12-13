//
//  PreferencesController.h
//  PasswordLearner
//
//  Created by Alex Nichol on 7/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppController.h"


@interface PreferencesController : NSObject {
	IBOutlet NSButton *checkBoxIncorrectBeep;
	IBOutlet NSButton *checkBoxIncorrectTell;
	
	IBOutlet NSButton *checkBox5CorrectTellMe;
	IBOutlet NSButton *checkBox5CorrectRestart;
	
	IBOutlet NSButton *checkBoxIndicator;
	IBOutlet NSButton *checkBoxStars;
	
	IBOutlet NSButton *checkBoxForgetful;
	
	IBOutlet NSWindow *preferencesWindow;
	
	// Add for progress indicator / stars!
	
	IBOutlet AppController *cont;
}
- (IBAction)openClick:(id)sender;
- (IBAction)checkValueChanged:(NSButton *)sender;
- (IBAction)closeClick:(id)sender;
- (void)saveAllSettings;
- (void)loadAllSettings;
@end
