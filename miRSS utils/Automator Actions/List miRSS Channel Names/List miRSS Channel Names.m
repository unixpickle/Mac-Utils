//
//  List miRSS Channel Names.m
//  List miRSS Channel Names
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright (c) 2010 __MyCompanyName__, All Rights Reserved.
//

#import "List miRSS Channel Names.h"


@implementation List_miRSS_Channel_Names

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
	// do nothing
	[super writeToDictionary:dictionary];
	// includeURLs = [[[self parameters] objectForKey:@"urls"] boolValue];
	// [dictionary setObject:[NSNumber numberWithBool:includeURLs] forKey:@"includeURLs"];
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
	includeURLs = [[[self parameters] objectForKey:@"urls"] boolValue];
	if (input && [input count] > 0) {
		// read the input
		NSMutableArray * titles = [[NSMutableArray alloc] init];
		for (NSData * _channel in (NSArray *)input) {
			NSDictionary * channel = [NSKeyedUnarchiver unarchiveObjectWithData:_channel];
			NSString * title = [channel objectForKey:@"name"];
			[titles addObject:title];
		}
		return [titles autorelease];
	}
	if ([[[self parameters] objectForKey:@"allNames"] boolValue]) {
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		id<ANRemoteAccessManagerProtocol> proxy = [ANRSSProxy connectionProxy];
		NSArray * list = [proxy channelNames:includeURLs];
		[list retain];
		[pool drain];
		return [list autorelease];
	} else {
		return input;
	}
}

@end
