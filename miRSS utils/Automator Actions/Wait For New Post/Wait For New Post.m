//
//  Wait For New Post.m
//  Wait For New Post
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright (c) 2010 __MyCompanyName__, All Rights Reserved.
//

#import "Wait For New Post.h"


@implementation Wait_For_New_Post

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo {
	// Add your code here, returning the data to be passed to the next action.
	
	// get selected
	int selection = [[[self parameters] objectForKey:@"option"] intValue] + 1;
	
	// selection is our key
	// 1 = title of changed
	// 2 = total changed
	// 3 = URL of changed
	
	// basically read the articles until i find one that
	// is changed in a certain way
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	id<ANRemoteAccessManagerProtocol> proxy = [ANRSSProxy connectionProxy];
	
	// basically use proxy here
	
	NSArray * items = [proxy channels];
	NSDictionary * unread = nil;
	BOOL done = NO;
	
	while (true) {
		[NSThread sleepForTimeInterval:1];
		NSAutoreleasePool * innerPool = [[NSAutoreleasePool alloc] init];
		
		NSArray * newItems = [proxy channels];
		for (NSDictionary * dict in newItems) {
			// find a match
			NSDictionary * match = nil;
			for (NSDictionary * another in items) {
				if ([[another objectForKey:@"url"] isEqual:[dict objectForKey:@"url"]]) {
					match = another;
					break;
				}
			}
			if (match) {
				if ([[match objectForKey:@"unread"] intValue] < [[dict objectForKey:@"unread"] intValue]) {
					// it was unread
					unread = match;
					[innerPool drain];
					done = YES;
					break;
				} else if ([[match objectForKey:@"unread"] intValue] > [[dict objectForKey:@"unread"] intValue]) {
					// basically an article was deleted
					items = [proxy channels];
					break;
				}
			}
		}
		
		if (done) break;
		
		[innerPool drain];
	}
	
	id returnV = [input retain];
	
	if (unread) {
		// return the right data
		// 1 = title of changed
		// 2 = total changed
		// 3 = URL of changed
		switch (selection) {
			case 1:
				returnV = [[NSArray arrayWithObject:[unread objectForKey:@"name"]] retain];
				break;
			case 2:
			{
				NSString * mString = [NSString stringWithFormat:@"%d", [[proxy totalUnread] intValue]];
				returnV = [[NSArray arrayWithObject:mString] retain];
				break;
			}
			case 3:
				returnV = [[NSArray arrayWithObject:[unread objectForKey:@"url"]] retain];
				break;
			default:
				NSLog(@"No type of output selected");
				break;
		}
	}
	
	[pool drain];
	
	return [returnV autorelease];
}

@end
