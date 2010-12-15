//
//  ANTimeoutConnection.m
//  miRSS
//
//  Created by Alex Nichol on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANTimeoutConnection.h"


@implementation ANTimeoutConnection

@synthesize downloadData;

- (id)init {
	if (self = [super init]) {
		lock = [[NSLock alloc] init];
	}
	return self;
}

- (BOOL)flag_downloadDidBegin {
	BOOL b = NO;
	[lock lock];
	b = downloadDidBegin;
	[lock unlock];
	return b;
}
- (void)setFlag_downloadDidBegin:(BOOL)flag {
	[lock lock];
	downloadDidBegin = flag;
	[lock unlock];
}

- (BOOL)flag_isDone {
	BOOL b = NO;
	[lock lock];
	b = isDone;
	[lock unlock];
	return b;
}
- (void)setFlag_isDone:(BOOL)flag {
	[lock lock];
	isDone = flag;
	[lock unlock];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if (!self.downloadData) self.downloadData = [NSMutableData data];
	[self setFlag_downloadDidBegin:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self setFlag_downloadDidBegin:YES];
	if (!self.downloadData) self.downloadData = [NSMutableData data];
	
	[self.downloadData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	self.downloadData = nil;
	[self setFlag_downloadDidBegin:YES];
	[self setFlag_isDone:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self setFlag_isDone:YES];
	[self setFlag_downloadDidBegin:YES];
}

- (void)fetchDataThread:(NSURLRequest *)request {
	// assume that this is running on a seperate thread
	downloadConnection = [[NSURLConnection alloc] initWithRequest:request
														 delegate:self];
	[downloadConnection start];
}
+ (NSData *)fetchDataWithRequest:(NSURLRequest *)request {
	// here we will spawn a new thread and await for completion
	ANTimeoutConnection * connection = [[ANTimeoutConnection alloc] init];
	[connection setFlag_isDone:NO];
	[connection setFlag_downloadDidBegin:NO];
	[connection fetchDataThread:request];
	float timeout = 0;
	while (![connection flag_downloadDidBegin]) {
		if (timeout >= [request timeoutInterval]) {
			[connection release];
			connection = nil;
			break;
		}
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
		timeout += 1;
	}
	if (!connection) {
		return nil;
	}
	while (![connection flag_isDone]) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
	}
	NSData * d = [[connection downloadData] retain];
	[connection release];
	return [d autorelease];
}

- (void)dealloc {
	[downloadConnection cancel];
	[downloadConnection release];
	self.downloadData = nil;
	[lock release];
	[super dealloc];
}

@end
