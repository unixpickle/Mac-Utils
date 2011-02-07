//
//  ANQuicktimeMovie.m
//  WhenFile
//
//  Created by Alex Nichol on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANQuicktimeMovie.h"


@implementation ANQuicktimeMovie

- (id)initWithFile:(NSString *)path {
	if (self = [super init]) {
		// open the file
		file = [[NSFileHandle fileHandleForReadingAtPath:path] retain];
		if (!file) {
			[super dealloc];
			return nil;
		}
		moov = [[ANQuicktimeAtom alloc] initWithFileHandle:file];
		if (!moov) {
			NSLog(@"Failed to initialize main block.");
			[file closeFile];
			[file release];
			[super dealloc];
			return nil;
		}
		if (![[moov blockName] isEqual:@"moov"]) {
			NSLog(@"Not a quicktime movie");
			[moov release];
			[self closeFile];
			[super dealloc];
			return nil;
		}
	}
	return self;
}
- (ANQuicktimeAtom *)movieAtom {
	return moov;
}
- (void)closeFile {
	[file closeFile];
	[file release];
	file = nil;
}
- (void)dealloc {
	[moov release];
	[super dealloc];
}

@end
