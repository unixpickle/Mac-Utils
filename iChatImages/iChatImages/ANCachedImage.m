//
//  ANCachedImage.m
//  iChatImages
//
//  Created by Alex Nichol on 10/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANCachedImage.h"

@implementation ANCachedImage

@synthesize fileName;
@synthesize thumbnail;
@synthesize dateModified;

- (id)initWithImageFile:(NSString *)aFileName {
	if ((self = [super init])) {
		fileName = [aFileName retain];
		NSImage * image = [[NSImage alloc] initWithContentsOfFile:fileName];
		if (!image) {
			[self dealloc];
			return nil;
		}
		thumbnail = image;
		
		NSDictionary * attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil];
		if (attrs) {
			dateModified = [[attrs objectForKey:NSFileCreationDate] retain];
		}
		if (!dateModified) {
			dateModified = [[NSDate date] retain];
		}
	}
	return self;
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[ANCachedImage class]]) {
		if ([[self fileName] isEqualToString:[(ANCachedImage *)object fileName]]) {
			return YES;
		}
	}
	return NO;
}

- (NSComparisonResult)compare:(ANCachedImage *)anImage {
	return [[self dateModified] compare:[anImage dateModified]];
}

- (void)dealloc {
	[fileName release];
	[thumbnail release];
	[dateModified release];
	[super dealloc];
}

@end
