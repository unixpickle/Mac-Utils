//
//  WhenFileAppDelegate.m
//  WhenFile
//
//  Created by Alex Nichol on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WhenFileAppDelegate.h"

@implementation WhenFileAppDelegate

@synthesize window, currentPath;

- (IBAction)pickPath:(id)sender {
	NSOpenPanel * openDlg = [NSOpenPanel openPanel];
	
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:YES];
	
	if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
		NSArray * files = [openDlg filenames];
		self.currentPath = [files lastObject];
		[pathBox setStringValue:currentPath];
		NSDictionary * dict = [[NSFileManager defaultManager] attributesOfItemAtPath:self.currentPath
																			   error:nil];
		[modified setDateValue:[dict objectForKey:NSFileModificationDate]];
		[created setDateValue:[dict objectForKey:NSFileCreationDate]];
	}
}

- (IBAction)dateChange:(id)sender {
	// set the date on the selected file
	if (self.currentPath) {
		NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.currentPath
																			error:nil];
		NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:attributes];
		[dict setObject:[created dateValue] forKey:NSFileCreationDate];
		[dict setObject:[modified dateValue] forKey:NSFileModificationDate];
		NSError * e = nil;
		if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:self.currentPath error:&e]) {
			NSRunAlertPanel(@"Error changing date.", 
							[NSString stringWithFormat:@"Error changing date: %@", [e localizedDescription]],
							@"OK", nil, nil);
		}
	}
}

- (IBAction)saveChanges:(id)sender {
	if ([QTMovie canInitWithFile:self.currentPath] && [[self.currentPath lastPathComponent] hasSuffix:@"mov"] && kAttemptTimestampChange) {
		// this part does not quite work yet
		
//		QTMovie * m = [[QTMovie alloc] initWithFile:self.currentPath
//											  error:nil];
//		NSLog(@"Before: %@", [m attributeForKey:QTMovieModificationTimeAttribute]);
//		[m release];
		
		// change the quicktime timestamp here,
		// but not any of the metadata that MAY
		// be stored in the file...
		@try {
			ANQuicktimeMovie * mv = [[ANQuicktimeMovie alloc] initWithFile:self.currentPath];
			if (mv) {
				ANQuicktimeAtom * moov = [mv movieAtom];
				ANQuicktimeAtom * trak = [moov subAtomOfType:@"trak"];
				ANQuicktimeAtom * mdia = [trak subAtomOfType:@"mdia"];
				ANQuicktimeAtom * mdhd = [mdia subAtomOfType:@"mdhd"];
				NSData * mdhdData = [mdhd retrieveData];
				// now we will change the data
				NSMutableData * d = [NSMutableData dataWithData:mdhdData];
				// set the timestamp
				UInt32 ts_m = (UInt32)[[modified dateValue] timeIntervalSince1970];
				UInt32 ts_c = (UInt32)[[created dateValue] timeIntervalSince1970];
				[d replaceBytesInRange:NSMakeRange(4, 4) withBytes:&ts_c];
				[d replaceBytesInRange:NSMakeRange(8, 4) withBytes:&ts_m];
				[mdhd setData:d];
				
				[mv closeFile];
				[mv release];
			} else {
				NSLog(@"Error setting movie date: movie was nil.");
			}
		} @catch (NSException * e) {
			NSLog(@"Exception reading movie, failed: %@", e);
		}
	}
	[self dateChange:self];
}

- (void)dealloc {
	self.currentPath = nil;
	[super dealloc];
}

@end
