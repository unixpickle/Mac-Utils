//
//  ANApplicationHotKey.m
//  KeyShot
//
//  Created by Alex Nichol on 3/30/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ANApplicationHotKey.h"


@implementation ANApplicationHotKey
@synthesize appName, appPath;
- (void)keyPressed:(id)sender {
	//NSLog(@"%@ : %@", self.appName, self.appPath);
	if ([self.appPath hasPrefix:@"http://"] || [self.appPath hasPrefix:@"https://"]) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.appPath]];
		return;
	}
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[@"file://" stringByAppendingString:self.appPath]]];
}
- (ANKeyEvent *)keyEvent {
	return keyEvent;
}
- (void)setKeyEvent:(ANKeyEvent *)ke {
	[keyEvent release];
	keyEvent = [ke retain];
	[ke setTarget:self];
	[ke setSelector:@selector(keyPressed:)];
}
- (NSDictionary *)dictionaryValue {
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	[dict setValue:appName forKey:@"title"];
	[dict setValue:appPath forKey:@"path"];
	[dict setValue:[NSNumber numberWithInt:keyEvent.key_code] forKey:@"key:code"];
	[dict setValue:[NSNumber numberWithBool:keyEvent.key_command] forKey:@"key:command"];
	[dict setValue:[NSNumber numberWithBool:keyEvent.key_control] forKey:@"key:control"];
	[dict setValue:[NSNumber numberWithBool:keyEvent.key_option] forKey:@"key:option"];
	[dict setValue:[NSNumber numberWithBool:keyEvent.key_shift] forKey:@"key:shift"];
	return (NSDictionary *)dict;
}
- (void)dealloc {
	[keyEvent release];
	keyEvent = nil;
	self.appName = nil;
	self.appPath = nil;
	NSLog(@"- [ANApplicationHotKey dealloc]: freed.");
	[super dealloc];
}
@end
