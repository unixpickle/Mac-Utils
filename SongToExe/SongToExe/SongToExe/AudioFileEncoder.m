//
//  AudioFileEncoder.m
//  SongToExe
//
//  Created by Alex Nichol on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioFileEncoder.h"


@implementation AudioFileEncoder

@synthesize isCancelled;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithAudioFile:(NSString *)path {
	if ((self = [super init])) {
		audioFileHandle = [[NSFileHandle fileHandleForReadingAtPath:path] retain];
	}
	return self;
}
- (long long int)fileSize {
	long long int orig = [audioFileHandle offsetInFile];
	[audioFileHandle seekToEndOfFile];
	long long int size = [audioFileHandle offsetInFile];
	[audioFileHandle seekToFileOffset:orig];
	return size;
}
- (BOOL)encodeFileToHeader:(NSString *)dataFile progressCallback:(BOOL (^)(float progress))progressCallback {
	if (![[NSFileManager defaultManager] fileExistsAtPath:dataFile]) {
		if (![[NSFileManager defaultManager] createFileAtPath:dataFile contents:[NSData data] attributes:nil]) {
			return NO;
		}
	}
	NSFileHandle * writeHandle = nil;
	@try {
		writeHandle = [NSFileHandle fileHandleForWritingAtPath:dataFile];
	} @catch (NSException * ex) {
		return NO;
	}
	if (!writeHandle) {
		return NO;
	}
	[writeHandle writeData:[@"const unsigned char * songData = \"" dataUsingEncoding:NSASCIIStringEncoding]];
	BOOL isFirst = YES;
	[audioFileHandle seekToEndOfFile];
	double bytesRead = 0;
	double totalBytes = (double)[audioFileHandle offsetInFile];
	[audioFileHandle seekToFileOffset:0];
	while (true) {
		if (isCancelled) break;
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		NSData * buffer = [audioFileHandle readDataOfLength:65536];
		bytesRead += (double)([buffer length]);
		if ([buffer length] == 0 || !buffer) {
			[pool drain];
			break;
		}
		if (isFirst) {
			isFirst = NO;
		} else {
			// break it up line by line.
			[writeHandle writeData:[@"\"\n\"" dataUsingEncoding:NSASCIIStringEncoding]];
		}
		const unsigned char * bytes = (const unsigned char *)[buffer bytes];
		NSMutableData * encoded = [[NSMutableData alloc] initWithCapacity:([buffer length] * 4)];
		for (int i = 0; i < [buffer length]; i++) {
			NSString * writeString = [NSString stringWithFormat:@"\\x%02x", bytes[i]];
			[encoded appendData:[writeString dataUsingEncoding:NSASCIIStringEncoding]];
		}
		[writeHandle writeData:encoded];
		[encoded release];
		if (!progressCallback(bytesRead / totalBytes)) {
			[pool drain];
			[writeHandle closeFile];
			[audioFileHandle closeFile];
			[audioFileHandle release];
			audioFileHandle = nil;
			return YES;
		}
		[pool drain];
	}
	[writeHandle writeData:[@"\";\n" dataUsingEncoding:NSASCIIStringEncoding]];
	[writeHandle closeFile];
	[audioFileHandle closeFile];
	[audioFileHandle release];
	audioFileHandle = nil;
	return YES;
}

- (void)dealloc {
	[audioFileHandle closeFile];
	[audioFileHandle release];
    [super dealloc];
}

@end
