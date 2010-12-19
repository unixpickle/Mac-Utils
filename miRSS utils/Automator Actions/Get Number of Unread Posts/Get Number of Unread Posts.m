//
//  Get Number of Unread Posts.m
//  Get Number of Unread Posts
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright (c) 2010 __MyCompanyName__, All Rights Reserved.
//

#import "Get Number of Unread Posts.h"


@implementation Get_Number_of_Unread_Posts

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo {
	int narticles = 0;
	if ([(NSArray *)input count] > 0) {
		// read that
		for (NSData * d in (NSArray *)input) {
			NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:d];
			narticles += [[dict objectForKey:@"unread"] intValue];
		}
	} else {
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		id<ANRemoteAccessManagerProtocol> proxy = [ANRSSProxy connectionProxy];
		narticles = [[proxy totalUnread] intValue];
		[pool drain];
	}
	return [NSArray arrayWithObject:[NSNumber numberWithInt:narticles]];
}

@end
