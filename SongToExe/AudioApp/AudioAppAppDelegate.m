//
//  AudioAppAppDelegate.m
//  AudioApp
//
//  Created by Alex Nichol on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioAppAppDelegate.h"

@implementation AudioAppAppDelegate

@synthesize window;

- (void)checkCycle {
	if (![current isPlaying]) {
		if (!loop) exit(0);
		[current setCurrentTime:0];
		[current play];
	}
	[self performSelector:@selector(checkCycle) withObject:nil afterDelay:1];
}

- (void)playSong {
	NSString * path = [[NSBundle mainBundle] pathForResource:@"extrainfo" ofType:@"plist"];
	if (!path || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSRunAlertPanel(@"Invalid app", @"The extrainfo.plist file is not in Resources/.  Please re-download this application.", @"OK", nil, nil);
		exit(-1);
	}
	NSDictionary * dict = [[NSDictionary alloc] initWithContentsOfFile:path];
	if (!dict) {
		NSRunAlertPanel(@"Invalid app", @"The extrainfo.plist file is not in Resources/.  Please re-download this application.", @"OK", nil, nil);
		exit(-1);
	}
	NSString * audioResource = [dict objectForKey:@"audio"];
	loop = [[dict objectForKey:@"loop"] boolValue];
	if (!audioResource) {
		[dict release];
		exit(-1);
	}
	audioPath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:audioResource] retain];
	current = [[NSSound alloc] initWithContentsOfFile:audioPath byReference:NO];
	[current play];
	[self performSelector:@selector(checkCycle) withObject:nil afterDelay:1];
}

- (void)awakeFromNib {
	[self performSelector:@selector(playSong) withObject:nil afterDelay:1];
}

@end
