//
//  ANQuicktimeList.m
//  FileTools
//
//  Created by Alex Nichol on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANQuicktimeList.h"


@implementation ANQuicktimeList

@synthesize dataComponents;

- (id)initWithData:(NSData *)ilist {
	if (self = [super init]) {
		// read size, index, data name, and data itself
		self.dataComponents = [NSMutableArray array];
		int index = 0;
		while (index < [ilist length]) {
			if (index + 4 > [ilist length]) break;
			UInt32 size = *((const UInt32 *)(&((char *)[ilist bytes])[index]));
			size = [ANQuicktimeAtom flipEndian:size];
			
			if (index + size > [ilist length]) {
				NSLog(@"Cannot read total block.");
				break;
			}
			index += 4;
			// index
			UInt32 _index = *((const UInt32 *)(&((char *)[ilist bytes])[index]));
			_index = [ANQuicktimeAtom flipEndian:_index];
			index += 4;
			UInt32 datasize = *((const UInt32 *)(&((char *)[ilist bytes])[index]));
			datasize = [ANQuicktimeAtom flipEndian:datasize];
			if (datasize != size - 8) {
				NSLog(@"Warning, unmatching sizes.");
				break;
			}
			
			if (index + datasize > [ilist length] || datasize < 4) {
				NSLog(@"Datasize too big or small.");
				break;
			}
			index += 4;
			char blockType[5];
			blockType[4] = 0;
			memcpy(blockType, &((char *)[ilist bytes])[index], 4);
			index += 4;
			NSData * data = [NSData dataWithBytes:&((char *)[ilist bytes])[index]
										   length:(datasize - 8)];
			[self.dataComponents addObject:data];
			index += datasize - 8;
		}
	}
	return self;
}

- (NSData *)encodeData {
	NSMutableData * d = [NSMutableData data];
	UInt32 index = 1;
	for (NSData * _d in self.dataComponents) {
		UInt32 size = [_d length] + 16;
		size = [ANQuicktimeAtom flipEndian:size];
		UInt32 flipIndex = [ANQuicktimeAtom flipEndian:index];
		[d appendBytes:(const void *)(&size) length:4];
		[d appendBytes:(const void *)(&flipIndex) length:4];
		size = [_d length] + 8;
		size = [ANQuicktimeAtom flipEndian:size];
		[d appendBytes:(const void *)(&size) length:4];
		[d appendBytes:"data" length:4];
		[d appendData:_d];
		// write the size
		index ++;
	}
	return d;
}

- (void)dealloc {
	self.dataComponents = nil;
	[super dealloc];
}

@end
