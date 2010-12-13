//
//  AppController.h
//  PasswordLearner
//
//  Created by Alex Nichol on 7/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GeneratePasswordController.h"


@interface AppController : NSObject {
	IBOutlet NSBox *learnItBox;
	IBOutlet NSTextField *textBoxGuess;
	IBOutlet NSTextField *textBoxReal;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTextField *isOk;
	IBOutlet NSButton *iForgot;
	NSSpeechSynthesizer *speechSynth;
	NSString *password;
	int amountCorrect;
}
- (IBAction)guessPassword:(id)sender;
- (IBAction)setPassword:(id)sender;
- (IBAction)settingPassword:(id)sender;
- (void)controlTextDidChange:(NSNotification *)aNotification;
- (IBAction)displayPassword:(id)sender;
- (IBAction)generatePassword:(id)sender;
- (IBAction)displayPreferences:(id)sender;
- (void)reloadSet;
- (void)hideOtherControlls;
@end
