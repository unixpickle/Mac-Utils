//
//  ANTimeoutConnection.h
//  miRSS
//
//  Created by Alex Nichol on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ANTimeoutConnection : NSObject {
	NSURLConnection * downloadConnection;
	NSMutableData * downloadData;
	BOOL downloadDidBegin;
	BOOL isDone;
	NSLock * lock;
}

@property (nonatomic, retain) NSMutableData * downloadData;

- (BOOL)flag_downloadDidBegin;
- (void)setFlag_downloadDidBegin:(BOOL)flag;
- (BOOL)flag_isDone;
- (void)setFlag_isDone:(BOOL)flag;

- (void)fetchDataThread:(NSURLRequest *)request;
+ (NSData *)fetchDataWithRequest:(NSURLRequest *)request;

@end
