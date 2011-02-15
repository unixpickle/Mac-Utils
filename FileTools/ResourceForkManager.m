//
//  ResourceForkManager.m
//  ResourceForkTesting
//
//  Created by Alex Nichol on 10/30/10.
//  Copyright 2010 Jitsik. All rights reserved.
//

#import "ResourceForkManager.h"


@implementation ResourceForkManager
- (BOOL)openResourceForFile:(NSString *)filePath {
	FSRef fileRef;
	if (CFURLGetFSRef((CFURLRef)[NSURL fileURLWithPath:filePath], &fileRef)) {
		HFSUniStr255 resourceForkName;
		FSGetResourceForkName(&resourceForkName);
		if (FSCreateResourceFork(&fileRef, resourceForkName.length, resourceForkName.unicode, 0) == noErr) {
			ResFileRefNum refNum;
			if (FSOpenFork(&fileRef, resourceForkName.length, resourceForkName.unicode, fsRdWrPerm, &refNum) == noErr) {
				// write resources here...
				resFile = refNum;
				return YES;
			}
		} else {
			ResFileRefNum refNum;
			OSErr err;
			if ((err = FSOpenFork(&fileRef, resourceForkName.length, resourceForkName.unicode, fsRdWrPerm, &refNum)) == noErr) {
				resFile = refNum;
				return YES;
			} else {
				// here we need to open it?
				resFile = 0;
				NSLog(@"CANNOT OPEN FILE... dare I say you need HFS+?");
			}
		}
	}
	return NO;
}
- (BOOL)writeDataToFile:(NSData *)d {
	if (!resFile) return NO;
	FSSetForkSize(resFile, fsFromStart, [d length]);
	OSErr err = FSWriteFork(resFile, fsFromStart, 
							0, (ByteCount)[d length], [d bytes], NULL);
	if (err != noErr) {
		return NO;
	}
	return YES;
}
- (NSData *)readDataFromFile {
	if (!resFile) return nil;
	SInt64 fileSize;
	OSErr err = FSGetForkSize(resFile, &fileSize);
	if (err != noErr) return nil;
	char * buffer = calloc(fileSize, 1);
	FSReadFork(resFile, fsFromStart, 0, (ByteCount)fileSize, buffer, NULL);
	NSData * d = [[NSData alloc] initWithBytes:buffer length:fileSize];
	free(buffer);
	return [d autorelease];
}
- (NSString *)readStringFromFile {
	NSData * d = [self readDataFromFile];
	if (!d) return nil;
	char * c = (char *)malloc([d length] + 1);
	bzero(c, [d length] + 1);
	int len = -1;
	for (int i = 0; i < [d length]; i++) {
		char mb = ((const char *)[d bytes])[i];
		if (isalnum(mb) || isascii(mb)) {
			c[++len] = (char)mb;
		}
	}
	c[++len] = 0;
	NSString * str = [[NSString alloc] initWithBytes:c length:len encoding:NSUTF8StringEncoding];
	free(c);
	return [str autorelease];
}
- (void)closeFile {
	CloseResFile(resFile);
	FSCloseFork(resFile);
	resFile = 0;
}
- (void)dealloc {
	if (resFile) {
		[self closeFile];
	}
	[super dealloc];
}
@end
