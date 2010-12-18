//
//  Combine Text List.m
//  Combine Text List
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright (c) 2010 __MyCompanyName__, All Rights Reserved.
//

#import "Combine Text List.h"


@implementation Combine_Text_List

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo {
	if (![input isKindOfClass:[NSArray class]]) {
		return input;
	}
	// Add your code here, returning the data to be passed to the next action.
	
	BOOL spaceBefore = [[[self parameters] objectForKey:@"spaceBefore"] boolValue];
	BOOL spaceAfter = [[[self parameters] objectForKey:@"spaceAfter"] boolValue];
	BOOL lastAnd = [[[self parameters] objectForKey:@"lastAnd"] boolValue];
	NSString * deliminator = [[self parameters] objectForKey:@"delimiter"];
	
	if (spaceBefore) {
		deliminator = [@" " stringByAppendingFormat:@"%@", deliminator];
	}
	if (spaceAfter) {
		deliminator = [deliminator stringByAppendingFormat:@" "];
	}
	
	NSMutableString * combination = [NSMutableString string];
	for (int i = 0; i < [input count]; i++) {
		NSString * item = [input objectAtIndex:i];
		if (![item isKindOfClass:[NSString class]]) {
			// get the string value of it
			item = [item description];
		}
		
		[combination appendFormat:@"%@", item];
		
		if (i + 1 < [input count]) {
			// append the deliminator
			[combination appendFormat:@"%@", deliminator];
			if (i + 2 >= [input count]) {
				if (lastAnd) {
					[combination appendFormat:@"and "];
				}
			}
		}
	}
	
	return combination;
}

@end
