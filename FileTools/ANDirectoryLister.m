//
//  ANDirectoryLister.m
//  ShrinkyBops
//
//  Created by Alex Nichol on 12/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANDirectoryLister.h"
#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>

@implementation ANDirectoryLister

+ (NSArray *)contentsOfDirectory:(NSString *)directoryName {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableArray * list = [[NSMutableArray alloc] init];
	BOOL isDirectory = NO;
	DIR * dip;
	struct dirent * dit;
	if ([[NSFileManager defaultManager] fileExistsAtPath:directoryName isDirectory:&isDirectory]) {
		if (!isDirectory) {
			[list release];
			return nil;
		}
	} else {
		[list release];
		return nil;
	}
	// here we will read the listing
	if ((dip = opendir([directoryName UTF8String])) == NULL) {
		[list release];
		return nil;
	}
	
	while ((dit = readdir(dip)) != NULL) {
		char * filename = dit->d_name;
		int filelength = dit->d_namlen;
		NSData * filedata = [NSData dataWithBytes:filename length:filelength];
		NSString * dirname = [[NSString alloc] initWithData:filedata
												   encoding:NSWindowsCP1252StringEncoding];
		if (dirname) {
			if (![dirname isEqual:@".."] && ![dirname isEqual:@"."]) {
				// add it to the array
				[list addObject:dirname];
				[dirname release];
			} else [dirname release];
		} else {
			NSLog(@"Failed to get directory name.");
		}
	}
	
	if (closedir(dip) == -1) {
		NSLog(@"Close dir failed.");
		[list release];
		return nil;
	}
	
	[pool drain];
	
	return [list autorelease];
}

@end
