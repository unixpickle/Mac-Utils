//
//  QuicktimeDeleteController.m
//  FileTools
//
//  Created by Alex Nichol on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuicktimeDeleteController.h"


@implementation QuicktimeDeleteController

- (IBAction)pickFile:(id)sender {
	NSOpenPanel * openDlg = [NSOpenPanel openPanel];
	
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:YES];
	
	if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
		NSArray * files = [openDlg filenames];
		[filePath setStringValue:[files objectAtIndex:0]];
	}
}

- (IBAction)removeTimestamp:(id)sender {
	int timestampsDeleted = 0;
	if ([QTMovie canInitWithFile:[filePath stringValue]] && [[[filePath stringValue] lastPathComponent] hasSuffix:@"mov"]) {
		// this part does not quite work yet
		
		//		QTMovie * m = [[QTMovie alloc] initWithFile:self.currentPath
		//											  error:nil];
		//		NSLog(@"Before: %@", [m attributeForKey:QTMovieModificationTimeAttribute]);
		//		[m release];
		
		// change the quicktime timestamp here,
		// but not any of the metadata that MAY
		// be stored in the file...
		@try {
			ANQuicktimeMovie * mv = [[ANQuicktimeMovie alloc] initWithFile:[filePath stringValue]];
			if (mv) {
				if ([mv metaData]) {
					ANQuicktimeList * list = [[ANQuicktimeList alloc] initWithData:[[mv metaData] retrieveData]];
					if ([[list dataComponents] count] <= 0) {
						NSLog(@"No metaData.");
					} else {
						for (int i = 0; i < [[list dataComponents] count]; i++) {
							NSData * d = [[list dataComponents] objectAtIndex:i];
							NSData * newd = [[NSMutableData alloc] initWithLength:[d length]];
							[[list dataComponents] replaceObjectAtIndex:i withObject:newd];
							[newd release];
						}
					}
					
					NSData * ld = [list encodeData];
					// write this to that
					[[mv metaData] setData:ld];
					
					[list release];
					timestampsDeleted ++;
				}
				
				ANQuicktimeAtom * moov = [mv movieAtom];
				ANQuicktimeAtom * ilst = [[moov subAtomOfType:@"meta"] subAtomOfType:@"ilst"];
				if (ilst) {
					ANQuicktimeList * list = [[ANQuicktimeList alloc] initWithData:[ilst retrieveData]];
					if ([[list dataComponents] count] <= 0) {
						NSLog(@"No metaData.");
					} else {
						for (int i = 0; i < [[list dataComponents] count]; i++) {
							NSData * d = [[list dataComponents] objectAtIndex:i];
							NSData * newd = [[NSMutableData alloc] initWithLength:[d length]];
							[[list dataComponents] replaceObjectAtIndex:i withObject:newd];
							[newd release];
						}
					}
					
					NSData * ld = [list encodeData];
					// write this to that
					[ilst setData:ld];
					
					[list release];
					timestampsDeleted ++;					
				}
				
				ANQuicktimeAtom * trak = [moov subAtomOfType:@"trak"];
				ANQuicktimeAtom * mdia = [trak subAtomOfType:@"mdia"];
				ANQuicktimeAtom * mdhd = [mdia subAtomOfType:@"mdhd"];
				NSData * mdhdData = [mdhd retrieveData];
				if (mdhd) {
					// now we will change the data
					NSMutableData * d = [NSMutableData dataWithData:mdhdData];
					// set the timestamp
					UInt32 ts_m = 0;
					[d replaceBytesInRange:NSMakeRange(4, 4) withBytes:&ts_m];
					[d replaceBytesInRange:NSMakeRange(8, 4) withBytes:&ts_m];
					[mdhd setData:d];
					timestampsDeleted += 2;
				}
				
				[mv closeFile];
				[mv release];
			} else {
				NSRunAlertPanel(@"Not a Movie File", 
								@"This is a movie file, but I cannot manage to read the contents properly.", 
								@"OK", nil, nil);
			}
		} @catch (NSException * e) {
			NSRunAlertPanel(@"Not a Movie File", 
							@"This is a movie file, but I cannot manage to read the contents properly.", 
							@"OK", nil, nil);
		}
	} else {
		NSRunAlertPanel(@"Not a Movie File", 
						@"The file specified was not a movie file.", 
						@"OK", nil, nil);
	}
	[deletionStatus setStringValue:[NSString stringWithFormat:@"Changed %d timestamps", timestampsDeleted]];
}

@end
