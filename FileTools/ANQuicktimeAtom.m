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
@synthesize atomSize, blockName;

+ (UInt32)flipEndian:(UInt32)ui {
	UInt32 ni;
	char * d = (char *)&ui;
	char * di = (char *)&ni;
	for (int i = 0; i < sizeof(UInt32); i++) {
		di[i] = d[sizeof(UInt32) - (i + 1)];
	}
	return ni;
}

- (id)initWithFileHandle:(NSFileHandle *)fh {
	if (self = [super init]) {
		// read the size
		NSData * lengthInt = [fh readDataOfLength:4];
		if ([lengthInt length] < 4) {
			[super dealloc];
			return nil;
		}
		const UInt32 * atomSizePtr = (const UInt32 *)[lengthInt bytes];
		// switch it up
		self.atomSize = atomSizePtr[0];
		self.atomSize = [ANQuicktimeAtom flipEndian:self.atomSize];
		self.blockName = [[[NSString alloc] initWithData:[fh readDataOfLength:4]
												encoding:NSUTF8StringEncoding] autorelease];
		if (!self.blockName) {
			[super dealloc];
			return nil;
		}
		fileIndex = [fh offsetInFile];
		[fh seekToFileOffset:self.fileIndex + (self.atomSize - 8)];
		subAtoms = nil;
		file = fh;
	}
	return self;
}

- (id)initWithFileHandle:(NSFileHandle *)fh fileIndex:(UInt64)ind {
	if (self = [super init]) {
		fileIndex = ind;
		file = fh;
		subAtoms = nil;
		self.blockName = [NSString stringWithFormat:@"    "];
		self.atomSize = 0;
	}
	return self;
}

- (NSData *)retrieveData {
	// read the data from the offset of our atom size
	[file seekToFileOffset:self.fileIndex];
	return [file readDataOfLength:self.atomSize - 8];
}

- (void)setData:(NSData *)d {
	// here we will write to the file
	[file seekToFileOffset:self.fileIndex];
	[file writeData:d];
}

- (NSArray *)subAtoms {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	if (subAtoms) {
		[pool drain];
		return subAtoms;
	}
	NSMutableArray * newSubAtoms = [NSMutableArray array];
	UInt bytesLeft = self.atomSize - 8;
	[file seekToFileOffset:self.fileIndex];
	// read until we get to where we want to be
	while (bytesLeft > 0) {
		ANQuicktimeAtom * atom = [[ANQuicktimeAtom alloc] initWithFileHandle:file];
		if (!atom) {
			NSLog(@"Hit invalid atom, breaking but not aborting.");
			break;
		}
		bytesLeft -= atom.atomSize;
		if (bytesLeft < 0) {
			[atom release];
			@throw [NSException exceptionWithName:@"AtomTooLarge" 
										   reason:@"Read an atom that was larger than the super-atom."
										 userInfo:nil];
			[pool drain];
			return nil;
		}
		[newSubAtoms addObject:atom];
		[atom release];
	}
	subAtoms = [[NSArray alloc] initWithArray:newSubAtoms];
	[pool drain];
	return subAtoms;
}

- (int)dataLength {
	return self.atomSize - 8;
}

- (ANQuicktimeAtom *)subAtomOfType:(NSString *)name {
	NSArray * _subAtoms = [self subAtoms];
	if (!_subAtoms) return nil;
	for (ANQuicktimeAtom * a in _subAtoms) {
		if ([[a blockName] isEqual:name]) return a;
	}
	NSLog(@"Subatom not found: %@", name);
	return nil;
}

- (id)description {
	return [NSString stringWithFormat:@"%@ (%d)", self.blockName, self.atomSize];
}

- (void)dealloc {
	self.blockName = nil;
	[subAtoms release];
	subAtoms = nil;
	[super dealloc];
}

@end
