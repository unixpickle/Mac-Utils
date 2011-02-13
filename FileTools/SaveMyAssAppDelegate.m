//
//  SaveMyAssAppDelegate.m
//  SaveMyAss
//
//  Created by Alex Nichol on 5/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SaveMyAssAppDelegate.h"

@implementation SaveMyAssAppDelegate

@synthesize window;


- (void)awakeFromNib {
	defaults = [NSUserDefaults standardUserDefaults];
	[settings setDelegate:self];
	[settings loadSettingsFromDelegate];
}

- (void)error {
	NSRunAlertPanel(@"File not found", @"The file specified cannot be located.", @"OK", nil, nil);
}

- (void)stopLoading {
	[eraseButton setTitle:@"Wipe"];
	[progress setDoubleValue:0];
	[progressLabel setStringValue:@"0%"];
	[filePath setStringValue:@""];
	
	if ([[self settingForKey:@"sound"] boolValue]) {
		NSSound * doneSound = [NSSound soundNamed:@"glass.wav"];
		[doneSound performSelector:@selector(play) withObject:nil afterDelay:0];
		[doneSound retain];
		[doneSound setDelegate:self];
	}
}

- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)aBool {
	[sound release];
}

- (long long)calculateDirectorySize:(NSString *)dirPath {
	long long size = 0;
	NSArray * listing = [ANDirectoryLister contentsOfDirectory:dirPath];
	for (NSString * str in listing) {
		NSString * itemPath = [dirPath stringByAppendingPathComponent:str];
		BOOL dir = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath:itemPath isDirectory:&dir]) {
			if (dir) {
				size += [self calculateDirectorySize:itemPath];
			} else {
				NSDictionary * dict = [[NSFileManager defaultManager] attributesOfItemAtPath:itemPath error:nil];
				size += [[dict objectForKey:@"NSFileSize"] longLongValue];
			}
		} else {
			NSLog(@"file vanished: %@", itemPath);
		}
	}
	return size;
}

- (void)setLoadProgress {
	double d = (((double)currentBytes / (double)totalBytes) * 100);
	//NSLog(@"Progress %lf", d);
	[progress setDoubleValue:d];
	[progressLabel setStringValue:[NSString stringWithFormat:@"%d%%", (int)d]];
}

- (void)removeFile:(NSString *)path size:(long long)size {
	NSLog(@"File Path: %@", path);
	
	
	
	int addSize = size / overwriteTimes;
	int backupSize = currentBytes;
	
	int buffers = size / bufferSize;
	if (size <= bufferSize) {
		buffers = 1;
	} else if (size % bufferSize != 0) buffers += 1;
	
	for (int i = 0; i < overwriteTimes; i++) {
		NSFileHandle * handle = [NSFileHandle fileHandleForUpdatingAtPath:path];
		[handle seekToFileOffset:0];
		for (int j = 0; j < buffers; j++) {
			[handle writeData:dat];
		}
		currentBytes += addSize;
		[self performSelectorOnMainThread:@selector(setLoadProgress) withObject:nil waitUntilDone:YES];
	}
	currentBytes = backupSize + size;
	
	if (dateOverwrite) {
		NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil]];
		[dict setValue:[NSDate dateWithTimeIntervalSince1970:10] forKey:@"NSFileCreationDate"];
		[dict setValue:[NSDate dateWithTimeIntervalSince1970:10] forKey:@"NSFileModificationDate"];
		[[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:path error:nil];
		[dict release];
	}
}

- (int)removeDir:(NSString *)path size:(long long)progress1 total:(long long)totalSize {
	
	if (dateOverwrite) {
		NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil]];
		[dict setValue:[NSDate dateWithTimeIntervalSince1970:10] forKey:@"NSFileCreationDate"];
		[dict setValue:[NSDate dateWithTimeIntervalSince1970:10] forKey:@"NSFileModificationDate"];
		[[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:path error:nil];
		[dict release];
	}
	
	long long size = progress1;
	NSArray * listing = [ANDirectoryLister contentsOfDirectory:path];
	for (NSString * str in listing) {
		if ([[NSThread currentThread] isCancelled]) break;
		NSString * itemPath = [path stringByAppendingPathComponent:str];
		BOOL dir = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath:itemPath isDirectory:&dir]) {
			if (dir) {
				size = [self removeDir:itemPath size:size total:totalSize];
			} else {
				NSDictionary * dict = [[NSFileManager defaultManager] attributesOfItemAtPath:itemPath error:nil];
				size += [[dict objectForKey:@"NSFileSize"] longLongValue];
				[self removeFile:itemPath size:[[dict objectForKey:@"NSFileSize"] longLongValue]];
			}
		} else {
			NSLog(@"file vanished: %@", itemPath);
		}
	}
	return size;
}

- (IBAction)pickFile:(id)sender {
	NSOpenPanel * openDlg = [NSOpenPanel openPanel];
	
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:YES];
	
	if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
		NSArray * files = [openDlg filenames];
		[filePath setStringValue:[files objectAtIndex:0]];
	}
}

- (void)wipePath:(NSString *)path {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	BOOL isDir = NO;
	long long size = 0;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
		if (isDir) {
			size = [self calculateDirectorySize:path];
			totalBytes = size;
			currentBytes = 0;
			[self removeDir:path size:0 total:size];
		} else {
			NSDictionary * dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path
																				   error:nil];			//NSDictionary * dict = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:YES];
			size = [[dict objectForKey:@"NSFileSize"] longLongValue];
			totalBytes = size;
			currentBytes = 0;
			[self removeFile:path size:size];
		}
	} else {
		NSLog(@"No such file.");
		[self performSelectorOnMainThread:@selector(error) withObject:nil waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:YES];
		
		wipeThread = nil;
		
		[pool drain];
		return;
	}
	
	if (trash) {
		NSArray * files = [NSArray arrayWithObject:[path lastPathComponent]];
		NSString * sourceDir = [path substringToIndex:([path length] - [[path lastPathComponent] length])]; 
		NSString * trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
		// int tag;
		if (![[NSThread currentThread] isCancelled]) {
			[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation 
														 source:sourceDir 
													destination:trashDir 
														  files:files 
															tag:0];
		}	
	} else {
		if (![[NSThread currentThread] isCancelled]) {
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		}
	}
	
	[self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:YES];
	
	wipeThread = nil;
	
	[pool drain];
}

- (IBAction)erase:(id)sender {
	[dat release];
	NSString * title = [eraseButton title];
	if ([title isEqual:@"Wipe"]) {
		bufferSize = [[self settingForKey:@"buffer"] intValue];
		switch (bufferSize) {
			case 0:
				bufferSize = 4096;
				break;
			case 1:
				bufferSize = 8196;
				break;
			case 2:
				bufferSize = 65536;
				break;
			default:
				break;
		}
		dateOverwrite = [[self settingForKey:@"overwrite_date"] boolValue];
		overwriteTimes = [[self settingForKey:@"overwrite_times"] intValue];
		randomize = [[self settingForKey:@"random"] boolValue];
		trash = [[self settingForKey:@"trash"] boolValue];
		[eraseButton setTitle:@"Stop"];
		
		dat = [[NSMutableData alloc] init];
		if ([[self settingForKey:@"random"] boolValue]) {
			for (int i = 0; i < bufferSize; i+=4) {
				int c = arc4random();
				[dat appendBytes:(int *)(&c) length:4];
			}
		} else {
			char * data = (char *)malloc(bufferSize);
			for (int i = 0; i < bufferSize; i++) {
				data[i] = (char)(i % 21);
			}
			[dat appendBytes:data length:bufferSize];
			free(data);
		}
		
		wipeThread = [[NSThread alloc] initWithTarget:self selector:@selector(wipePath:) object:[[NSString alloc] initWithString:[filePath stringValue]]];
		[wipeThread start];
		[wipeThread release];
	} else {
		[eraseButton setTitle:@"Wipe"];
		[wipeThread cancel];
		wipeThread = nil;
		[progress setDoubleValue:0];
		[progressLabel setStringValue:@"0%"];
	}
}

- (void)settingsWindow:(id)sender setSetting:(NSString *)key withValue:(id)value {
	[defaults setObject:value forKey:key];
	[defaults synchronize];
	
	return;
}
- (id)settingForKey:(NSString *)key {
	return [defaults objectForKey:key];
}
- (void)settingsWindowDidClose:(id)sender {
	return;
}

@end
