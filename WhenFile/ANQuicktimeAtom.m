//
//  ANQuicktimeAtom.m
//  WhenFile
//
//  Created by Alex Nichol on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANQuicktimeAtom.h"


@implementation ANQuicktimeAtom

@synthesize file, fileIndex;
@synthesize blockSize, blockName;

- (id)initWithFileHandle:(NSFileHandle *)fh {
	if (self = [super init]) {
		// read the size
		NSData * lengthInt = [fh readDataOfLength:4];
		if ([lengthInt length] < 4) {
			[super dealloc];
			return nil;
		}
		self.blockSize = *((const UInt32 *)[lengthInt bytes]);
		self.blockName = [[[NSString alloc] initWithData:[fh readDataOfLength:4]
												encoding:NSASCIIStringEncoding] autorelease];
		if (!self.blockName) {
			[super dealloc];
			return nil;
		}
		self.fileIndex = [fh offsetInFile];
		[fh seekToFileOffset:self.fileIndex + (self.blockSize - 4)];
		subAtoms = nil;
	}
	return self;
}

- (NSData *)retrieveData {
	[fh seekToFileOffset:self.fileIndex];
	return [fh readDataOfLength:self.blockSize - 4];
}

- (NSArray *)subAtoms {
	if (subAtoms) {
		return subAtoms;
	}
	NSMutableArray * newSubAtoms = [NSMutableArray array];
	UInt bytesLeft = self.blockSize - 4;
	[fh seekToFileOffset:self.fileIndex];
	// read until we get to where we want to be
	while (bytesLeft > 0) {
		ANQuicktimeAtom * atom = [[ANQuicktimeAtom alloc] initWithFileHandle:fh];
		if (!atom) {
			NSLog(@"Hit invalid atom, breaking bot not aborting.");
			return break;
		}
		bytesLeft -= atom.blockSize + 4;
		if (bytesLeft < 0) {
			[atom release];
			@throw [NSException exceptionWithName:@"AtomTooLarge" 
										   reason:@"Read an atom that was larger than the super-atom."
										 userInfo:nil];
			return;
		}
		[newSubAtoms addObject:atom];
		[atom release];
	}
	subAtoms = [[NSArray alloc] initWithArray:newSubAtoms];
	return subAtoms;
}

- (void)dealloc {
	self.blockName = nil;
	subAtoms = nil;
	[super dealloc];
}

@end
