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
		file = [[NSFileHandle fileHandleForUpdatingAtPath:path] retain];
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
		
		if ([[moov blockName] isEqual:@"ftyp"]) {
			// read through and find the real moov
			toplevel = [[ANQuicktimeAtom alloc] initWithFileHandle:file fileIndex:0];
			[file seekToEndOfFile];
			[toplevel setAtomSize:[file offsetInFile]];
			[moov release];
			moov = [[toplevel subAtomOfType:@"moov"] retain];
			metadata = [[[[toplevel subAtomOfType:@"free"] subAtomOfType:@"meta"] subAtomOfType:@"ilst"] retain];
		} else {
			if (![[moov blockName] isEqual:@"moov"]) {
				NSLog(@"Not a quicktime movie");
				[moov release];
				[self closeFile];
				[super dealloc];
				return nil;
			}
			metadata = [[[[moov subAtomOfType:@"free"] subAtomOfType:@"meta"] subAtomOfType:@"ilist"] retain];
		}
	}
	return self;
}
- (ANQuicktimeAtom *)metaData {
	// here we will read the metaData block
	return metadata;
}
- (ANQuicktimeAtom *)movieAtom {
	if ([[moov blockName] isEqual:@"ftyp"]) {
		return [moov subAtomOfType:@"moov"];
	}
	return moov;
}
- (void)closeFile {
	[file closeFile];
	[file release];
	file = nil;
}
- (void)dealloc {
	[toplevel release];
	[moov release];
	[metadata release];
	[super dealloc];
}

@end
