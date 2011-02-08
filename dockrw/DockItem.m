//
//  DockItem.m
//  dockrw
//
//  Created by Alex Nichol on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DockItem.h"


@implementation DockItem

@synthesize appPath, label;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		self.appPath = [[[dictionary objectForKey:@"tile-data"] objectForKey:@"file-data"] objectForKey:@"_CFURLString"];
		self.label = [[dictionary objectForKey:@"tile-data"] objectForKey:@"file-label"];
		dict = [dictionary retain];
	}
	return self;
}

- (id)initWithPath:(NSString *)app {
	if (self = [super init]) {
		self.appPath = app;
		NSString * appName = [app lastPathComponent];
		if ([appName hasSuffix:@".app"]) {
			// its an app
			self.label = [appName substringToIndex:[appName length] - 4];
		} else {
			return nil;
		}
	}
	return self;
}

- (NSDictionary *)itemDictionary {
	if (dict) return dict;
	NSNumber * dateInt = [NSNumber numberWithInt:time(NULL)];
	NSNumber * fileTypeInt = [NSNumber numberWithInt:41];
	
	NSDictionary * filedata = [NSDictionary dictionaryWithObjectsAndKeys:
							   self.appPath, @"_CFURLString",
							   [NSNumber numberWithInt:0], @"_CFURLStringType", nil];
	
	NSDictionary * tiledata = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithBool:0], @"dock-extra",
							   filedata, @"file-data",
							   self.label, @"file-label",
							   dateInt, @"file-mod-date",
							   dateInt, @"parent-mod-date",
							   fileTypeInt, @"file-type", nil];
	
	NSDictionary * dockData = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithInt:arc4random()], @"GUID",
							   tiledata, @"tile-data",
							   @"file-tile", @"tile-type", nil];
	
	return dockData;
}

- (void)dealloc {
	[dict release];
	self.appPath = nil;
	self.label = nil;
	[super dealloc];
}

@end
