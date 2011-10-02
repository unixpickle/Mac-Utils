//
//  ANChatImageCache.m
//  iChatImages
//
//  Created by Alex Nichol on 10/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANChatImageCache.h"

@interface ANChatImageCache (Private)

- (void)beginSearching:(NSThread *)delegateThread;
- (void)searchImageDirectory:(NSString *)path thread:(NSThread *)callback;

- (void)addImage:(ANCachedImage *)cachedImage;
- (void)delegateInformNewImage;
- (void)delegateInformDone;
- (void)delegateInformError;

@end

@implementation ANChatImageCache

@synthesize delegate;

- (void)startReloading {
	if (chatImageCache) {
		[chatImageCache release], chatImageCache = nil;
	}
	chatImageCache = [[NSMutableArray alloc] init];
	if (reloadThread) {
		[reloadThread cancel];
		[reloadThread release];
		reloadThread = nil;
	}
	reloadThread = [[NSThread alloc] initWithTarget:self selector:@selector(beginSearching:) object:[NSThread currentThread]];
	[reloadThread start];
}

- (void)cancelReloading {
	[reloadThread cancel];
	[reloadThread release];
	reloadThread = nil;
}

- (NSArray *)imageFiles {
	return (NSArray *)[NSArray arrayWithArray:chatImageCache];
}

- (void)dealloc {
	[chatImageCache release];
	[reloadThread release];
	[super dealloc];
}

#pragma mark - Private -

#pragma mark Background Thread

- (void)beginSearching:(NSThread *)delegateThread {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSString * tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"iChat"];
	NSString * imgPath = [tmpPath stringByAppendingPathComponent:@"Images"];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
		[self performSelector:@selector(delegateInformError) onThread:delegateThread withObject:nil waitUntilDone:NO];
		[pool drain];
		return;
	}
	
	[self searchImageDirectory:imgPath thread:delegateThread];
	
	if (![[NSThread currentThread] isCancelled]) {
		[self performSelector:@selector(delegateInformDone) onThread:delegateThread withObject:nil waitUntilDone:NO];
	}
	[pool drain];
}

- (void)searchImageDirectory:(NSString *)path thread:(NSThread *)callback {
	NSArray * listing = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
	if (!listing) {
		return;
	}
	for (int i = 0; i < [listing count]; i++) {
		NSString * filename = [listing objectAtIndex:i];
		NSString * absolute = [path stringByAppendingPathComponent:filename];
		BOOL isDir = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath:absolute isDirectory:&isDir]) {
			if (isDir) {
				[self searchImageDirectory:absolute thread:callback];
			} else {
				ANCachedImage * cached = [[ANCachedImage alloc] initWithImageFile:absolute];
				if ([[NSThread currentThread] isCancelled]) {
					[cached release];
					return;
				}
				if (cached) {
					[self performSelector:@selector(addImage:) onThread:callback withObject:cached waitUntilDone:NO];
					[cached release];
				}
			}
		}
		[NSThread sleepForTimeInterval:0.001];
	}
}

#pragma mark Main Thread

- (void)addImage:(ANCachedImage *)cachedImage {
	int insertIndex = 0;
	for (ANCachedImage * image in chatImageCache) {
		if ([image isEqual:cachedImage]) return;
	}
	for (int i = (int)[chatImageCache count] - 1; i >= 0; i--) {
		ANCachedImage * image = [chatImageCache objectAtIndex:i];
		if ([cachedImage compare:image] == NSOrderedAscending) {
			insertIndex = i + 1;
			break;
		}
	}
	[chatImageCache insertObject:cachedImage atIndex:insertIndex];
	[self delegateInformNewImage];
}

- (void)delegateInformNewImage {
	if ([delegate respondsToSelector:@selector(chatImageCacheFoundNewFiles:)]) {
		[delegate chatImageCacheFoundNewFiles:self];
	}
}

- (void)delegateInformDone {
	[reloadThread cancel];
	[reloadThread release];
	reloadThread = nil;
	if ([delegate respondsToSelector:@selector(chatImageCacheFinished:)]) {
		[delegate chatImageCacheFinished:self];
	}
}

- (void)delegateInformError {
	[reloadThread cancel];
	[reloadThread release];
	reloadThread = nil;
	if ([delegate respondsToSelector:@selector(chatImageCacheFailed:)]) {
		[delegate chatImageCacheFailed:self];
	}
}

@end
