//
//  SettingsView.m
//  SaveMyAss
//
//  Created by Alex Nichol on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsView.h"


@implementation SettingsView

@synthesize delegate;

- (void)loadSettingsFromDelegate {
	if (!delegate) return;
	if ([[delegate settingForKey:@"firstRun"] intValue] != 1) {
		[self defaults:self];
		return;
	}
	[check_overwriteDate setState:[(NSNumber *)[delegate settingForKey:@"overwrite_date"] intValue]];
	[check_trash setState:[(NSNumber *)[delegate settingForKey:@"trash"] intValue]];
	[check_sound setState:[(NSNumber *)[delegate settingForKey:@"sound"] intValue]];
	[check_randomize setState:[(NSNumber *)[delegate settingForKey:@"random"] intValue]];
	[popup_times setTitle:[NSString stringWithFormat:@"%d", [[delegate settingForKey:@"overwrite_times"] intValue]]];
	[segment_bufferSize setSelectedSegment:[(NSNumber *)[delegate settingForKey:@"buffer"] intValue]];
}

- (void)setSettingsToDelegate {
	if (!delegate) return;
	[delegate settingsWindow:self setSetting:@"overwrite_date" withValue:[NSNumber numberWithBool:[check_overwriteDate state]]];
	[delegate settingsWindow:self setSetting:@"trash" withValue:[NSNumber numberWithBool:[check_trash state]]];
	[delegate settingsWindow:self setSetting:@"sound" withValue:[NSNumber numberWithBool:[check_sound state]]];
	[delegate settingsWindow:self setSetting:@"random" withValue:[NSNumber numberWithBool:[check_randomize state]]];
	[delegate settingsWindow:self setSetting:@"overwrite_times" withValue:[NSNumber numberWithInt:[[popup_times titleOfSelectedItem] intValue]]];
	[delegate settingsWindow:self setSetting:@"buffer" withValue:[NSNumber numberWithInt:[segment_bufferSize selectedSegment]]];
}

- (IBAction)defaults:(id)sender {
	[delegate settingsWindow:self setSetting:@"firstRun" withValue:[NSNumber numberWithInt:1]];
	[delegate settingsWindow:self setSetting:@"overwrite_date" withValue:[NSNumber numberWithBool:NO]];
	[delegate settingsWindow:self setSetting:@"trash" withValue:[NSNumber numberWithBool:NO]];
	[delegate settingsWindow:self setSetting:@"sound" withValue:[NSNumber numberWithBool:YES]];
	[delegate settingsWindow:self setSetting:@"random" withValue:[NSNumber numberWithBool:NO]];
	[delegate settingsWindow:self setSetting:@"overwrite_times" withValue:[NSNumber numberWithInt:7]];
	[delegate settingsWindow:self setSetting:@"buffer" withValue:[NSNumber numberWithInt:2]];
	[self loadSettingsFromDelegate];
}

- (IBAction)valueChange:(id)sender {
	[self setSettingsToDelegate];
}

@end
