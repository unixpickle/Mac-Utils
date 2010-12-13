//
//  GeneratePasswordController.h
//  PasswordLearner
//
//  Created by Alex Nichol on 7/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GeneratePasswordController : NSWindowController {
	IBOutlet NSTextField *passwordGenerated;
	IBOutlet NSTextField *passwordStrengthText;
	IBOutlet NSLevelIndicator *passwordStrength;
	IBOutlet NSLevelIndicator *generateLength;
	IBOutlet NSButton *generateButton;
	IBOutlet NSTextView *generateTips;
	IBOutlet NSTextField *passwordDigits;
	NSArray *weekPasswords;
}
- (IBAction)changeLevel:(id)sender;
- (IBAction)generatePassword:(id)sender;
- (void)passwordChanged;
@property (nonatomic, retain) IBOutlet NSLevelIndicator *passwordStrength;
@property (nonatomic, retain) IBOutlet NSTextField *passwordGenerated;
@property (nonatomic, retain) IBOutlet NSLevelIndicator *generateLength;
@property (nonatomic, retain) IBOutlet NSButton *generateButton;
@property (nonatomic, retain) IBOutlet NSTextView *generateTips;
@property (nonatomic, retain) IBOutlet NSTextField *passwordDigits;
@end
