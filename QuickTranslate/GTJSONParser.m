//
//  GTJSONParser.m
//  FrenchCheater
//
//  Created by Alex Nichol on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GTJSONParser.h"

@interface GTJSONParser ()

- (NSString *)readString:(NSString *)startString end:(int *)end;
- (id)readParameter:(NSString *)startString end:(int *)end;

@end

@implementation GTJSONParser

- (NSArray *)parseJSONArray:(NSString *)jsonArray lastCharacter:(int *)last {
	// check to make sure that we have an array
	if ([jsonArray characterAtIndex:0] != '[') {
		NSException * ex = [[NSException alloc] initWithName:@"NotAnArrayException"
													  reason:@"The JSON array does not begin with a '['"
													userInfo:nil];
		@throw [ex autorelease];
		return nil;
	}
	NSMutableArray * arrayData = [NSMutableArray array];
	int i;
	for (i = 1; i < [jsonArray length]; i++) {
		int c = [jsonArray characterAtIndex:i];
		if (c == ']') {
			break;
		} else {
			NSString * currentString = [jsonArray substringFromIndex:i];
			int cutoff = 0;
			id obj = [self readParameter:currentString end:&cutoff];
			if (obj) {
				[arrayData addObject:obj];
			} else {
				
				// uncomment to display errors.
				// for now it just deals with them!
				
				// NSString * reason = [NSString stringWithFormat:@"Failed to parse near character %d of the buffer.", i];
				// NSException * error = [NSException exceptionWithName:@"ParseError"
				//											  reason:reason
				//											userInfo:nil];
				// NSLog(@"%@", error);
				// @throw error;
				// return nil;
			}
			i += cutoff;
		}
	}
	if (last) *last = i;
	return arrayData;
}

- (NSString *)readString:(NSString *)startString end:(int *)end {
	NSMutableString * string = [[NSMutableString alloc] init];
	int index = 0;
	for (index = 1; index < [startString length]; index++) {
		// append characters to the string until we reach our close quote
		int c = [startString characterAtIndex:index];
		if (c == '\\') {
			// oh dear, an escape character
			index += 1;
			int c1 = [startString characterAtIndex:index];
			if (c1 == 'n') {
				[string appendFormat:@"\n"];
			} else if (c1 == 'r') {
				[string appendFormat:@"\r"];
			} else if (c1 == '\\') {
				[string appendFormat:@"\\"];
			} else if (c1 == '"') {
				[string appendFormat:@"\""];
			} else if (c1 == 'u') {
				// read four more
				NSString * utfNumber = [startString substringWithRange:NSMakeRange(index + 1, 4)];
				index += 4;
				[string appendFormat:@"%C", [utfNumber intValue]];
			} else [string appendFormat:@"%C", c1];
		} else if (c == '"') {
			break;
		} else {
			// add the character
			[string appendFormat:@"%C", c];
		}
	}
	*end = index;
	return [string autorelease];
}

- (id)readParameter:(NSString *)startString end:(int *)end {
	// read a parameter or print an error
	int i;
	id returnObject = nil;
	for (i = 0; i < [startString length]; i++) {
		int c = [startString characterAtIndex:i];
		if (c == '"') {
			// we have a string
			int addLength = 0;
			NSString * content = [self readString:[startString substringFromIndex:i]
											  end:&addLength];
			returnObject = content;
			i += addLength;
		} else if (c == ',' || c == ']') {
			i += 0;
			if (c == ']') i -= 1;
			break;
		} else if (c == 't' || c == 'f') {
			// true or false
			if (c == 't') {
				// read the next four characters
				NSString * trueString = [startString substringFromIndex:i];
				if ([trueString hasPrefix:@"true"]) {
					// it is true
					returnObject = [NSNumber numberWithBool:YES];
				} else {
					returnObject = nil;
				}
				i += 3;
			} else {
				NSString * falseString = [startString substringFromIndex:i];
				if ([falseString hasPrefix:@"false"]) {
					// it is true
					returnObject = [NSNumber numberWithBool:NO];
				} else {
					returnObject = nil;
				}
				i += 4;
			}
		} else if (isdigit(c) || c == '-') {
			// read until non-digit
			NSMutableString * intText = [NSMutableString string];
			for (int i1 = i; i1 < [startString length]; i1++) {
				char ichar = [startString characterAtIndex:i1];
				if (!isdigit(ichar) && ichar != '-' && ichar != '.') {
					i = i1 - 1;
					break;
				} else {
					[intText appendFormat:@"%c", ichar];
				}
			}
			returnObject = [NSNumber numberWithDouble:[intText doubleValue]];
		} else if (c == '[') {
			int cutoff = 0;
			NSArray * arr = [self parseJSONArray:[startString substringFromIndex:i]
								   lastCharacter:&cutoff];
			i += cutoff;
			returnObject = arr;
		}
	}
	*end = i;
	return returnObject;
}

@end
