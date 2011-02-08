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
	UInt32 atomSize;
	NSArray * subAtoms;
}

+ (UInt32)flipEndian:(UInt32)ui;

@property (nonatomic, retain) NSString * blockName;
@property (readwrite) UInt32 atomSize;
@property (nonatomic, assign) NSFileHandle * file;
@property (readonly) UInt64 fileIndex;

- (id)initWithFileHandle:(NSFileHandle *)fh;
- (id)initWithFileHandle:(NSFileHandle *)fh fileIndex:(UInt64)ind;
- (NSData *)retrieveData;
- (void)setData:(NSData *)d;
- (NSArray *)subAtoms;
- (int)dataLength;
- (ANQuicktimeAtom *)subAtomOfType:(NSString *)name;

@end
