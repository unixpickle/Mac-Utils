//
//  SettingsView.h
//  SaveMyAss
//
//  Created by Alex Nichol on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SettingsViewDelegate

- (void)settingsWindow:(id)sender setSetting:(NSString *)key withValue:(id)value;
- (id)settingForKey:(NSString *)key;
- (void)settingsWindowDidClose:(id)sender;

@end

@interface SettingsView : NSView {
	id<SettingsViewDelegate> delegate;
	IBOutlet NSButton * check_overwriteDate;
	IBOutlet NSButton * check_trash;
	IBOutlet NSButton * check_sound;
	IBOutlet NSPopUpButton * popup_times;
	IBOutlet NSButton * check_randomize;
	IBOutlet NSSegmentedControl * segment_bufferSize;
}
- (void)loadSettingsFromDelegate;
- (IBAction)defaults:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)valueChange:(id)sender;
@property (nonatomic, assign) id<SettingsViewDelegate> delegate;
@end
