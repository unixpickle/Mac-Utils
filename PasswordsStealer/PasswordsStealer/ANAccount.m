//
//  ANPassword.m
//  PasswordsStealer
//
//  Created by Alex Nichol on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANAccount.h"


@implementation ANAccount

@synthesize username;
@synthesize password;
@synthesize service;

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword service:(NSString *)theService {
	if ((self = [super init])) {
		username = [aUsername retain];
		password = [aPassword retain];
		service = [theService retain];
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)infoDict {
	if ((self = [super init])) {
		username = [[infoDict objectForKey:@"Username"] retain];
		password = [[infoDict objectForKey:@"Password"] retain];
		service = [[infoDict objectForKey:@"Service"] retain];
	}
	return self;
}

- (id)description {
	return [NSString stringWithFormat:@"Username = \"%@\", Password = \"%@\", Service=\"%@\"", username, password, service];
}

- (void)dealloc {
	[username release];
	[password release];
	[service release];
	[super dealloc];
}

@end
