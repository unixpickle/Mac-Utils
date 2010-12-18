//
//  List miRSS Channels.m
//  List miRSS Channels
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright (c) 2010 __MyCompanyName__, All Rights Reserved.
//

#import "List miRSS Channels.h"


@implementation List_miRSS_Channels

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
	// do nothing
	[super writeToDictionary:dictionary];
}

- (id)init {
	if (self = [super init]) {
		
	}
	return self;
}

- (id)initWithDefinition:(NSDictionary *)dict fromArchive:(BOOL)archived {
	// do nothing
	if (self = [super initWithDefinition:dict fromArchive:archived]) {
	}
	return self;
}

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo {
	// Add your code here, returning the data to be passed to the next action.
	
	BOOL newArticles = [[[self parameters] objectForKey:@"newArticles"] boolValue];
	BOOL notLoaded = [[[self parameters] objectForKey:@"notLoaded"] boolValue];
	BOOL unfreshArticles = [[[self parameters] objectForKey:@"unfreshArticles"] boolValue];
	
	NSMutableArray * returnValue = [[[NSMutableArray alloc] init] autorelease];
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	id<ANRemoteAccessManagerProtocol> proxy = [ANRSSProxy connectionProxy];
	NSArray * list = [proxy channels];
	[list retain];
	[pool drain];
	
	// read list and filter it
	for (NSDictionary * dict in list) {
		// use the dictionary
		int unread = [[dict objectForKey:@"unread"] intValue];
		BOOL added = NO;
		NSData * d = [NSKeyedArchiver archivedDataWithRootObject:dict];
		if (unread > 0) {
			if (newArticles) {
				if (!added) {
					added = YES;
					[returnValue addObject:d];
				}
			}
		}
		if (unread == 0) {
			if (unfreshArticles) {
				if (!added) {
					added = YES;
					[returnValue addObject:d];
				}
			}
		}
		if ([[dict objectForKey:@"name"] length] == 0) {
			if (notLoaded) {
				if (!added) {
					added = YES;
					[returnValue addObject:d];
				}
			}
		}
	}
	
	[list release];
	
	return returnValue;
}

@end
