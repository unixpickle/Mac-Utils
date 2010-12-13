//
//  AppController.m
//  PasswordLearner
//
//  Created by Alex Nichol on 7/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"


@implementation AppController
- (id)init {
	[super init];
	speechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:[NSSpeechSynthesizer defaultVoice]];
	[speechSynth setDelegate:self];
	return self;
}
- (void)awakeFromNib {
	NSString *firstRunKey = [[NSString alloc] initWithFormat:@"%@_key", NSUserName()];
	int info = [firstRunKey hash];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if ([ud integerForKey:firstRunKey] != info) {
		[ud setInteger:info forKey:firstRunKey];
		[ud setBool:YES forKey:@"incorrect_beep"];
		[ud setBool:YES forKey:@"forget"];
		[ud setBool:NO forKey:@"tell5"];
		[ud setBool:NO forKey:@"restart5"];
		[ud setBool:YES forKey:@"stars"];
		[ud synchronize];
	}
	[textBoxReal setDelegate:self];
	NSLog(@"Awake from Nib");
	NSRect r = NSMakeRect([mainWindow frame].origin.x - 
						  ([mainWindow frame].size.width - [mainWindow frame].size.width), [mainWindow frame].origin.y - 
						  (118 - [mainWindow frame].size.height), [mainWindow frame].size.width, 118);
	NSRect r1 = NSMakeRect([mainWindow frameRectForContentRect:r].origin.x - 
						   ([mainWindow frameRectForContentRect:r].size.width - [mainWindow frameRectForContentRect:r].size.width), [mainWindow frame].origin.y - 
						   (118 - ([mainWindow frameRectForContentRect:r].size.height - ([mainWindow frameRectForContentRect:r].size.height - r.size.height))), [mainWindow frameRectForContentRect:r].size.width, 118 + ([mainWindow frameRectForContentRect:r].size.height - r.size.height));
	[mainWindow setFrame:r1 display:YES animate:NO];
	[learnItBox setHidden:YES];
	[learnItBox setAlphaValue:0.0];
	NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
	NSRect windowFrame = [mainWindow frame];
	[mainWindow setFrame:NSMakeRect((visibleFrame.size.width - windowFrame.size.width) * 0.5,
							  ((visibleFrame.size.height / 2) - (windowFrame.size.height / 2)),
							  windowFrame.size.width, windowFrame.size.height) display:YES];
	[isOk setStringValue:@""];
}

- (IBAction)displayPreferences:(id)sender {
	
}

- (IBAction)guessPassword:(id)sender {
	if ([[textBoxGuess stringValue] isEqual:password]) {
		[isOk setStringValue:@"Yes"];
		amountCorrect++;
		if (amountCorrect % 5 == 0) {
			NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
			BOOL tell5 = [ud boolForKey:@"tell5"];
			if (tell5) {
				if ([speechSynth isSpeaking])
					[speechSynth stopSpeaking];
				NSString *speech = [[NSString alloc] initWithFormat:@"Got it right %d times in a row!", amountCorrect];
				[speechSynth startSpeakingString:[speech retain]];
			}
			BOOL restart5 = [ud boolForKey:@"restart5"];
			if (restart5) {
				[self settingPassword:self];
				[textBoxReal selectText:self];
				amountCorrect = 0;
			}
		}
	} else {
		amountCorrect = 0;
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		BOOL incorrect_beep = [ud boolForKey:@"incorrect_beep"];
		if (incorrect_beep) {
			NSBeep();
		} else {
			if ([speechSynth isSpeaking])
				[speechSynth stopSpeaking];
			[speechSynth startSpeakingString:@"Incorrect"];
		}
		[isOk setStringValue:@"No"];
	}
	[textBoxGuess setStringValue:@""];
}
- (BOOL)windowShouldClose:(id)sender {
	exit(1);
}
- (IBAction)setPassword:(id)sender {
	[self reloadSet];
	[isOk setStringValue:@""];
	password = [[textBoxReal stringValue] retain];
	[textBoxReal setStringValue:@""];
	[textBoxGuess setStringValue:@""];
	[textBoxGuess selectText:self];
	NSRect r = NSMakeRect([mainWindow frame].origin.x - 
						  ([mainWindow frame].size.width - [mainWindow frame].size.width), [mainWindow frame].origin.y - 
						  (249 - [mainWindow frame].size.height), [mainWindow frame].size.width, 249);
	NSRect r1 = NSMakeRect([mainWindow frameRectForContentRect:r].origin.x - 
						   ([mainWindow frameRectForContentRect:r].size.width - [mainWindow frameRectForContentRect:r].size.width), [mainWindow frame].origin.y - 
						   (249 - ([mainWindow frameRectForContentRect:r].size.height - ([mainWindow frameRectForContentRect:r].size.height - r.size.height))), [mainWindow frameRectForContentRect:r].size.width, 249 + ([mainWindow frameRectForContentRect:r].size.height - r.size.height));
    
	[mainWindow setFrame:r1 display:YES animate:YES];
	[learnItBox setHidden:NO];
	[learnItBox setAlphaValue:1.0];
}
- (void)reloadSet {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	BOOL canForget = [ud boolForKey:@"forget"];
	if (canForget)
		[iForgot setHidden:NO];
	else
		[iForgot setHidden:YES];
	amountCorrect = 0;
}
- (void)hideOtherControlls {
	NSRect r = NSMakeRect([mainWindow frame].origin.x - 
						  ([mainWindow frame].size.width - [mainWindow frame].size.width), [mainWindow frame].origin.y, [mainWindow frame].size.width, 118);
	NSRect r1 = NSMakeRect([mainWindow frameRectForContentRect:r].origin.x - 
						   ([mainWindow frameRectForContentRect:r].size.width - [mainWindow frameRectForContentRect:r].size.width), [mainWindow frame].origin.y, [mainWindow frameRectForContentRect:r].size.width, 118 + ([mainWindow frameRectForContentRect:r].size.height - r.size.height));
	[mainWindow setFrame:r1 display:YES animate:YES];
	[learnItBox setHidden:YES];
	[learnItBox setAlphaValue:0.0];
}
- (IBAction)settingPassword:(id)sender {
	[self hideOtherControlls];
}
- (IBAction)displayPassword:(id)sender {
	NSRunAlertPanel(@"Password", [NSString stringWithFormat:@"Your password is: %@", password], @"OK", nil, nil);
}
- (void)controlTextDidChange:(NSNotification *)aNotification {
	[self settingPassword:self];
	NSLog(@"Setting the Text");
}
- (IBAction)generatePassword:(id)sender {
	GeneratePasswordController *gpc = [[GeneratePasswordController alloc] initWithWindowNibName:@"GeneratePassword"];
	[[gpc window] makeKeyAndOrderFront:self];
}
@end
