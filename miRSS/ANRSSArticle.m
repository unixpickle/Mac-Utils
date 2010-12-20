//
//  ANRSSArticle.m
//  miRSS
//
//  Created by Alex Nichol on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANRSSArticle.h"


@implementation ANRSSArticle

@synthesize title;
@synthesize index;
@synthesize content;
@synthesize date;
@synthesize parentObject;

- (id)objectSpecifier {
	NSScriptObjectSpecifier * parent = [parentObject objectSpecifier];
	NSIndexSpecifier * description = [[NSIndexSpecifier alloc] initWithContainerClassDescription:(NSScriptClassDescription *)[parentObject classDescription]
																				  containerSpecifier:parent
																								 key:@"articles"
																							   index:[[self index] intValue]];
	return [description autorelease];
}

- (void)dealloc {
	self.title = nil;
	self.index = nil;
	self.content = nil;
	self.date = nil;
	[super dealloc];
}

@end

