//
//  ANRSSManager.m
//  miRSS
//
//  Created by Alex Nichol on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANRSSManager.h"
#import "Debugging.h"

@implementation ANRSSManager

@synthesize delegate;

- (id)init {
	if (self = [super init]) {
		
		id * selfptr = [ANCommandCounter mainManagerPointer];
		selfptr[0] = self;
		
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
				[dictionary setObject:[NSNumber numberWithInt:0] forKey:ANRSSManagerChannelWasModified];
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

- (int)unreadInChannelIndex:(int)index lock:(BOOL)doLock {
	int unread = 0;
	if (doLock) [self lock];
	
	// here we read the channel VS the GUIDS
	NSDictionary * dictionary = [channels objectAtIndex:index];
	// read the GUIDS
	NSMutableArray * guids = [dictionary objectForKey:ANRSSManagerChannelReadGUIDSKey];
	RSSChannel * channel = [dictionary objectForKey:ANRSSManagerChannelRSSChannelKey];
	// loop through
	for (int i = 0; i < [[channel items] count]; i++) {
		BOOL found = NO;
		for (int j = 0; j < [guids count]; j++) {
			NSString * string = [guids objectAtIndex:j];
			RSSItem * item = [[channel items] objectAtIndex:i];
			if ([[item postGuid] isEqual:string]) {
				found = YES;
				break;
			}
		}
		if (!found) unread ++;
	}
	if (doLock) [self unlock];
	return unread;
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
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
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
			[post release];
			[pool drain];
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
	
	[pool drain];
	
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

- (void)save {
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
}

- (void)changeToRead:(int)channelIndex articleIndex:(int)article lock:(BOOL)doLock {
	if (doLock) [self lock];
	
	// unread the article here
	NSDictionary * dictionary = [channels objectAtIndex:channelIndex];
	RSSChannel * channel = [dictionary objectForKey:ANRSSManagerChannelRSSChannelKey];
	RSSItem * item = [[channel items] objectAtIndex:article];
	NSMutableArray * guids = [dictionary objectForKey:ANRSSManagerChannelReadGUIDSKey];
	for (NSString * string in guids) {
		if ([string isEqual:[item postGuid]]) {
			// it was there already
			if (doLock) [self unlock];
			return;
		}
	}
	
	[guids addObject:[item postGuid]];
	
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
	
	if (doLock) [self unlock];
}

- (void)lock {
	[lock lock];
}
- (void)unlock {
	[lock unlock];
}

- (BOOL)needsRefresh {
	BOOL b = NO;
	[lock lock];
	b = forceRefresh;
	[lock unlock];
	return b;
}
- (void)forceRefresh {
	[lock lock];
	forceRefresh = YES;
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
			// NSLog(@"Check.");
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
			[self lock];
			if (modified) {
				changed = YES;
				[self unlock];
				break;
			}
			NSString * url = [[[NSString stringWithString:[[channels objectAtIndex:i] 
														 objectForKey:ANRSSManagerChannelURLKey]] retain] autorelease];
			[self unlock];
			
			// read the URL
			NSURL * uri = [NSURL URLWithString:url];
			NSURLRequest * request = [NSURLRequest requestWithURL:uri
													  cachePolicy:NSURLRequestReloadIgnoringCacheData
												  timeoutInterval:5];
			NSData * fetched = [ANTimeoutConnection fetchDataWithRequest:request];
			/*NSData * fetched = [NSURLConnection sendSynchronousRequest:request
													 returningResponse:nil
																 error:nil];*/
			
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
						changed = YES;
						modified = NO;
						break;
					}
					[self lock];
					if (modified) {
						changed = YES;
						modified = NO;
						[lock unlock];
						break;
					}
					NSMutableDictionary * itemDict = [channels objectAtIndex:i];
					RSSChannel * oldChannel = [[[itemDict objectForKey:ANRSSManagerChannelRSSChannelKey] retain] autorelease];
					if (oldChannel) [channel setUniqueID:[oldChannel uniqueID]];
					[itemDict setObject:channel forKey:ANRSSManagerChannelRSSChannelKey];
					NSMutableArray * guids = [itemDict objectForKey:ANRSSManagerChannelReadGUIDSKey];
					if ([oldChannel articlesVary:channel]) {
						[itemDict setObject:[NSNumber numberWithInt:1] 
									 forKey:ANRSSManagerChannelWasModified];
						changed = YES;
					}
					
					for (int i = 0; i < [[channel items] count]; i++) {
						RSSItem * item = [[channel items] objectAtIndex:i];
						BOOL found = NO;
						if (oldChannel && [item postGuid]) {
							for (int j = 0; j < [[oldChannel items] count]; j++) {
								RSSItem * item1 = [[oldChannel items] objectAtIndex:j];
								if ([[item1 postGuid] isEqual:[item postGuid]]) {
									found = YES;
									break;
								} else {
									
								}
							}
						}
						
						if (!found && [item postGuid]) {
							// NSLog(@"Found = NO: %@", [item postGuid]);
							// NSLog(@"Changed.");
							changed = YES;
							[itemDict setObject:[NSNumber numberWithInt:1] 
										 forKey:ANRSSManagerChannelWasModified];
							break;
						}
					}
					 
					
					if ([guids count] > 100) {
						// lots of guids, let's delete ones that are
						// gone, probably because they were read previously
						for (int i = 0; i < [guids count]; i++) {
							// check for missing guids
							BOOL found = NO;
							NSString * guid = [guids objectAtIndex:i];
							for (int j = 0; j < [[channel items] count]; j++) {
								RSSItem * item = [[channel items] objectAtIndex:j];
								if ([[item postGuid] isEqual:guid]) {
									// they are equal
									found = YES;
									break;
								}
							}
							if ([[channel items] count] < 1) {
								found = YES;
							}
							if (!found) {
								[guids removeObjectAtIndex:i];
								
								// write to the defaults
								[self save];
								
								i --;
							}
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
						changed = YES;
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
			
			if (modified) {
				changed = YES;
				modified = NO;
				break;
			}
			
			[pool drain];
		}
		
		if (changed) {
			[(id)delegate performSelectorOnMainThread:@selector(articlesUpdated:) 
										   withObject:self
										waitUntilDone:YES];
			// unmodify everything
			[self lock];
			
			for (int i = 0; i < [channels count]; i++) {
				NSMutableDictionary * dict = [channels objectAtIndex:i];
				[dict setObject:[NSNumber numberWithInt:0] 
						 forKey:ANRSSManagerChannelWasModified];
			}
			
			[self unlock];
		}
		
		[NSThread sleepForTimeInterval:1];
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
