//
//  ANKeyEvent.m
//  KeyShot
//
//  Created by Alex Nichol on 3/30/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ANKeyEvent.h"

@interface ANKeyEvent (private)

+ (NSMutableArray *)keyEventPool;

@end

@implementation ANKeyEvent (private)

+ (NSMutableArray *)keyEventPool {
	static NSMutableArray * pool = nil;
	if (!pool) pool = [[NSMutableArray alloc] init];
	return pool;
}

@end


static OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData) {
	EventHotKeyID hkRef;
    GetEventParameter(anEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(hkRef),NULL,&hkRef);
	[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"key:%d", hkRef.id] object:nil];
	return noErr;
}

@implementation ANKeyEvent

@synthesize key_option;
@synthesize key_control;
@synthesize key_command;
@synthesize key_shift;
@synthesize key_code;
@synthesize selector, target;
@synthesize isRegistered;

+ (int)keyCodeForString:(NSString *)str {
	NSDictionary * keys = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];
	NSArray * keyList = [keys allKeysForObject:str];
	[keys autorelease];
	if ([keyList count] > 0) return [[keyList lastObject] intValue];
	return -1; // invalid key string
}

+ (void)configureKeyboard {
	[ANKeyEvent keyEventPool];
	EventTypeSpec eventType;
	eventType.eventClass = kEventClassKeyboard;
	eventType.eventKind = kEventHotKeyPressed;
	InstallApplicationEventHandler(&myHotKeyHandler, 1, &eventType, NULL, NULL);
	_curkeyid = 1;
}

+ (void)destroyKeyboard {
	while ([[ANKeyEvent keyEventPool] count] > 0) {
		ANKeyEvent * ke = [[ANKeyEvent keyEventPool] objectAtIndex:0];
		[ke unregisterEvent];
		[[ANKeyEvent keyEventPool] removeObjectAtIndex:0];
	}
	[[ANKeyEvent keyEventPool] release];
}

- (NSString *)keyTitle {
	NSDictionary * keys = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];
	[keys autorelease];
	return (NSString *)[keys objectForKey:[NSString stringWithFormat:@"%d", key_code]];
}

- (id)init {
	if (self = [super init]) {
		myHotKeyID.signature = 'anke';  // sign ANKeyEvent
										// change this for other applications
		myHotKeyID.id = _curkeyid;
		self.key_code = 49;
		self.key_command = YES;
		self.key_control = YES;
		self.key_option = YES;
		self.key_shift = YES;
		_curkeyid++;
		self.isRegistered = NO;
		[[ANKeyEvent keyEventPool] addObject:self];
	}
	return self;
}
- (void)registerEvent {
	if (self.isRegistered) return;
	self.isRegistered = YES;
	int modifiers = 0;
	if (self.key_command) modifiers += cmdKey;
	if (self.key_option) modifiers += optionKey;
	if (self.key_control) modifiers += controlKey;
	if (self.key_shift) modifiers += shiftKey;
	RegisterEventHotKey(key_code, modifiers, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	[[NSNotificationCenter defaultCenter] addObserver:target selector:selector name:[NSString stringWithFormat:@"key:%d", myHotKeyID.id] object:nil];
}
- (void)unregisterEvent {
	self.isRegistered = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:target name:[NSString stringWithFormat:@"key:%d", myHotKeyID.id] object:nil];
	UnregisterEventHotKey(myHotKeyRef);
}
- (void)dealloc {
	if (self.isRegistered) [self unregisterEvent];
	[[ANKeyEvent keyEventPool] removeObject:self];
	[super dealloc];
}
@end
