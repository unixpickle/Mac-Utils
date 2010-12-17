//
//  ANCommandCounter.m
//  miRSS
//
//  Created by Alex Nichol on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANCommandCounter.h"
#import "ANRSSManager.h"

@implementation ANCommandCounter

+ (id *)mainManagerPointer {
	static id manager = nil;
	return &manager;
}

- (id)executeCommand {
	ANRSSManager * man = *[ANCommandCounter mainManagerPointer];
	if (man) {
		id n = [NSNumber numberWithInt:[man channelCount]];
		return n;
	} else {
		return [NSNumber numberWithInt:-1];
	}
}

- (id)initWithCommandDescription:(NSScriptCommandDescription *)description {
	if (self = [super initWithCommandDescription:description]) {
		
	}
	return self;
}

@end
