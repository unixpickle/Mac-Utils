//
//  ANRSSManager.m
//  miRSS
//
//  Created by Alex Nichol on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANRSSManager.h"


@implementation ANRSSManager

@synthesize delegate;

- (id)init {
	if (self = [super init]) {
		NSArray * listing = [[NSUserDefaults standardUserDefaults] objectForKey:@"channels"];
		channels = [[NSMutableArray alloc] init];
		lock = [[NSLock alloc] init];
		channelCount = 0;
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		if (listing) {
			// load it
			for (NSDictionary * chan in listing) {
				NSString * url = [chan objectForKey:ANRSSManagerChannelURLKey];
				NSArray * guids = [chan objectForKey:ANRSSManagerChannelReadGUIDSKey];
				NSMutableArray * guidsArray = [NSMutableArray arrayWithArray:guids];
				NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
				[dictionary setObject:url forKey:ANRSSManagerChannelURLKey];
				[dictionary setObject:guidsArray forKey:ANRSSManagerChannelReadGUIDSKey];
				[channels addObject:dictionary];
				channelCount ++;
			}
		}
		[pool drain];
	}
	return self;
}

- (int)channelCount {
	int i = 0;
	[self lock];
	i = channelCount;
	[self unlock];
	return i;
}

- (void)addRSSURL:(NSString *)url {
	// add it
	NSMutableDictionary * post = [[NSMutableDictionary alloc] init];
	NSMutableArray * guids = [[NSMutableArray alloc] init];
	NSString * urlString = [[NSString alloc] initWithString:url];
	[post setObject:urlString forKey:ANRSSManagerChannelURLKey];
	[post setObject:guids forKey:ANRSSManagerChannelReadGUIDSKey];
	[post setObject:[NSNumber numberWithInt:0] forKey:ANRSSManagerChannelWasFound];
	[guids release];
	[urlString release];
	[self lock];
	
	for (int i = 0; i < [channels count]; i++) {
		NSDictionary * dict = [channels objectAtIndex:i];
		if ([[dict objectForKey:ANRSSManagerChannelURLKey] isEqual:urlString]) {
			[self unlock];
			return;
		}
	}
	
	[channels addObject:post];
	[post release];
	
	// write it to user defaults
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray * writeArray = [NSMutableArray array];
	for (int i = 0; i < [channels count]; i++) {
		NSDictionary * dict = [channels objectAtIndex:i];
		NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:ANRSSManagerChannelURLKey], ANRSSManagerChannelURLKey,
									 [dict objectForKey:ANRSSManagerChannelReadGUIDSKey], ANRSSManagerChannelReadGUIDSKey, nil];
		[writeArray addObject:dictionary];
	}
	[defaults setObject:writeArray forKey:@"channels"];
	[defaults synchronize];
	channelCount += 1;
	
	modified = YES;
	
	[lock unlock];
}

- (void)removeAtIndex:(int)i {
	[lock lock];
	[channels removeObjectAtIndex:i];
	channelCount -= 1;
	modified = YES;
	
	// update
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray * writeArray = [NSMutableArray array];
	for (int i = 0; i < [channels count]; i++) {
		NSDictionary * dict = [channels objectAtIndex:i];
		NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:ANRSSManagerChannelURLKey], ANRSSManagerChannelURLKey,
									 [dict objectForKey:ANRSSManagerChannelReadGUIDSKey], ANRSSManagerChannelReadGUIDSKey, nil];
		[writeArray addObject:dictionary];
	}
	[defaults setObject:writeArray forKey:@"channels"];
	[defaults synchronize];
	
	[lock unlock];
}

- (void)lock {
	[lock lock];
}
- (void)unlock {
	[lock unlock];
}
- (NSDictionary *)channelAtIndex:(int)i {
	// must call lock before this
	
	return [channels objectAtIndex:i];
	
	// and unlock after
}

- (void)startFetchThread {
	fetchThread = [[NSThread alloc] initWithTarget:self
										  selector:@selector(fetchThreadMethod)
											object:nil];
	[fetchThread start];
}
- (BOOL)modified {
	BOOL flag = NO;
	[self lock];
	flag = modified;
	[self unlock];
	return flag;
}
- (void)fetchThreadMethod {
	NSAutoreleasePool * floodPool = [[NSAutoreleasePool alloc] init];
	while (![[NSThread currentThread] isCancelled]) {
		NSAutoreleasePool * functionPool = [[NSAutoreleasePool alloc] init];
		// fetch and check for connectivity
		[self lock];
		modified = NO;
		int count = channelCount;
		[self unlock];
		BOOL changed = NO;
		for (int i = 0; i < count; i++) {
			NSLog(@"Check.");
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
			[self lock];
			if (modified) {
				[self unlock];
				break;
			}
			NSString * url = [[[NSString stringWithString:[[channels objectAtIndex:i] 
														 objectForKey:ANRSSManagerChannelURLKey]] retain] autorelease];
			NSLog(@"Got object.");
			[self unlock];
			
			// read the URL
			NSURL * uri = [NSURL URLWithString:url];
			NSURLRequest * request = [NSURLRequest requestWithURL:uri
													  cachePolicy:NSURLRequestReloadIgnoringCacheData
												  timeoutInterval:10];
			NSData * fetched = [NSURLConnection sendSynchronousRequest:request
													 returningResponse:nil
																 error:nil];
			
			if (fetched) {
				// we got the data
				NSString * content = [[NSString alloc] initWithData:fetched 
														   encoding:NSUTF8StringEncoding];
				[content autorelease];
				// read the content and such
				RSSFeed * feed = [[RSSFeed alloc] initWithString:content];
				if ([[feed rssChannels] count] > 0) {
					RSSChannel * channel = [[feed rssChannels] objectAtIndex:0];
					// set up dictionary
					if ([self modified]) {
						changed = NO;
						break;
					}
					[self lock];
					if (modified) {
						[lock unlock];
						break;
					}
					NSLog(@"*Got again");
					NSMutableDictionary * item = [channels objectAtIndex:i];
					NSLog(@" Got again");
					RSSChannel * oldChannel = [[[item objectForKey:ANRSSManagerChannelRSSChannelKey] retain] autorelease];
					if (oldChannel) [channel setUniqueID:[oldChannel uniqueID]];
					[item setObject:channel forKey:ANRSSManagerChannelRSSChannelKey];
					//NSArray * guids = [item objectForKey:ANRSSManagerChannelReadGUIDSKey];
					for (int i = 0; i < [[channel items] count]; i++) {
						RSSItem * item = [[channel items] objectAtIndex:i];
						BOOL found = NO;
						if (oldChannel) {
							for (int j = 0; j < [[oldChannel items] count]; j++) {
								RSSItem * item1 = [[oldChannel items] objectAtIndex:j];
								if ([[item1 postGuid] isEqual:[item postGuid]]) {
									found = YES;
									break;
								}
							}
						}
						/*
						for (NSString * guid in guids) {
							if ([[item postGuid] isEqual:guid]) {
								found = YES;
								break;
							}
						}
						*/
						if (!found) {
							NSLog(@"Changed.");
							changed = YES;
							break;
						}
					}
					[self unlock];
				} else {
					NSLog(@"URL %@ has %d channels.", url, [[feed rssChannels] count]);
				}
				[feed release];
			} else {
				if ([self modified]) {
					
				} else {
					[lock lock];
					if (modified) {
						[lock unlock];
						break;
					}
					NSMutableDictionary * object = [channels objectAtIndex:i];
					if ([[object objectForKey:ANRSSManagerChannelWasFound] intValue]) {
						changed = YES;
					}
					[object setObject:[NSNumber numberWithInt:0] 
							   forKey:ANRSSManagerChannelWasFound];
					
					[lock unlock];
				}
			}
			
			if (modified) break;
			
			[pool drain];
		}
		
		if (changed) {
			[(id)delegate performSelectorOnMainThread:@selector(articlesUpdated:) 
										   withObject:self
										waitUntilDone:YES];
		}
		
		[NSThread sleepForTimeInterval:3];
		[functionPool drain];
	}
	[floodPool drain];
}

- (void)dealloc {
	[fetchThread cancel];
	[fetchThread release];
	[channels release];
	[lock release];
	[super dealloc];
}

@end
