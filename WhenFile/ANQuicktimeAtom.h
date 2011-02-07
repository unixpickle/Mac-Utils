//
//  ANQuicktimeAtom.h
//  WhenFile
//
//  Created by Alex Nichol on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ANQuicktimeAtom : NSObject {
	NSFileHandle * file;
	UInt64 fileIndex;
	NSString * blockName;
	UInt32 blockSize;
	NSArray * subAtoms;
}

@property (nonatomic, retain) NSString * blockName;
@property (readwrite) UInt32 blockSize;
@property (nonatomic, assign) NSFileHandle * file;
@property (readonly) UInt64 fileIndex;

- (id)initWithFileHandle:(NSFileHandle *)fh;
- (NSData *)retrieveData;
- (NSArray *)subAtoms;

@end
