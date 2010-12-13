//
//  ANKeyEvent.h
//  KeyShot
//
//  Created by Alex Nichol on 3/30/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#ifndef _curkeyid
static int _curkeyid;
#endif

@interface ANKeyEvent : NSObject {
	EventHotKeyRef myHotKeyRef;
    EventHotKeyID myHotKeyID;
    EventTypeSpec eventType;
	BOOL isRegistered;
	BOOL key_command;
	BOOL key_option;
	BOOL key_control;
	BOOL key_shift;
	int key_code;
	id target;
	SEL selector;
}
+ (void)configureKeyboard;
+ (void)destroyKeyboard;
+ (int)keyCodeForString:(NSString *)str;
- (void)registerEvent;
- (void)unregisterEvent;
- (NSString *)keyTitle;
@property (readwrite) BOOL isRegistered;
@property (nonatomic, assign) id target;
@property (readwrite) SEL selector;
@property (readwrite) int key_code;
@property (readwrite) BOOL key_command;
@property (readwrite) BOOL key_option;
@property (readwrite) BOOL key_control;
@property (readwrite) BOOL key_shift;

@end
