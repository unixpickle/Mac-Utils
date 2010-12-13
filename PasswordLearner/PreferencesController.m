//
//  PreferencesController.m
//  PasswordLearner
//
//  Created by Alex Nichol on 7/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"


@implementation PreferencesController
- (IBAction)closeClick:(id)sender {
	[preferencesWindow orderOut:self];
}
- (IBAction)openClick:(id)sender {
	NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
	NSRect windowFrame = [preferencesWindow frame];
	[preferencesWindow setFrame:NSMakeRect((visibleFrame.size.width - windowFrame.size.width) * 0.5,
									   ((visibleFrame.size.height / 2) - (windowFrame.size.height / 2)),
									   windowFrame.size.width, windowFrame.size.height) display:YES];
	[preferencesWindow makeKeyAndOrderFront:self];
	[self loadAllSettings];
}
- (IBAction)checkValueChanged:(NSButton *)sender {
	if ([sender isEqual:checkBoxIndicator]) {
		if ([sender state] == YES)
			[checkBoxStars setState:NO];
		else
			[checkBoxStars setState:YES];
	}
	if ([sender isEqual:checkBoxStars]) {
		if ([sender state] == YES)
			[checkBoxIndicator setState:NO];
		else
			[checkBoxIndicator setState:YES];
	}
	if ([sender isEqual:checkBoxIncorrectBeep]) {
		if ([sender state] == YES)
			[checkBoxIncorrectTell setState:NO];
		else
			[checkBoxIncorrectTell setState:YES];
	}
	if ([sender isEqual:checkBoxIncorrectTell]) {
		if ([sender state] == YES)
			[checkBoxIncorrectBeep setState:NO];
		else
			[checkBoxIncorrectBeep setState:YES];
	}
	[self saveAllSettings];
	[cont reloadSet];
}
- (void)loadAllSettings {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	BOOL incorrect_beep = [ud boolForKey:@"incorrect_beep"];
	if (incorrect_beep) {
		[checkBoxIncorrectBeep setState:YES];
		[checkBoxIncorrectTell setState:NO];
	} else {
		[checkBoxIncorrectTell setState:YES];
		[checkBoxIncorrectBeep setState:NO];
	}
	BOOL forget = [ud boolForKey:@"forget"];
	[checkBoxForgetful setState:forget];
	BOOL stars = [ud boolForKey:@"stars"];
	[checkBoxStars setState:stars];
	if (stars)
		[checkBoxIndicator setState:NO];
	BOOL tell5 = [ud boolForKey:@"tell5"];
	[checkBox5CorrectTellMe setState:tell5];
	BOOL restart5 = [ud boolForKey:@"restart5"];
	[checkBox5CorrectRestart setState:restart5];
}
- (void)saveAllSettings {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setBool:[checkBoxIncorrectBeep state] forKey:@"incorrect_beep"];
	[ud setBool:[checkBoxForgetful state] forKey:@"forget"];
	[ud setBool:[checkBox5CorrectTellMe state] forKey:@"tell5"];
	[ud setBool:[checkBox5CorrectRestart state] forKey:@"restart5"];
	[ud setBool:[checkBoxStars state] forKey:@"stars"];
	[ud synchronize];
}
@end
