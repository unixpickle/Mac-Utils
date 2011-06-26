//
//  ExportWindow.m
//  SongToExe
//
//  Created by Alex Nichol on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExportWindow.h"

@interface ExportWindow (Private)

- (BOOL)createTempDir:(NSString *)path;
- (long long int)exportAudioFile:(NSString *)path output:(NSString *)songDataHeader;
- (NSString *)updatedMainFileData:(long long int)fileSize existing:(NSString *)mainTxt;
- (void)runBackgroundCompile:(NSString *)mainFile;
- (void)saveAndWait;

- (BOOL)isCancelled;
- (void)setIsCancelled:(BOOL)flag;
- (int)returnCode;
- (void)setReturnCode:(int)retCode;

- (void)setProgressObj:(NSNumber *)numProgress;
- (void)notifyError:(NSString *)errorMsg;

- (void)backgroundMain;
- (void)threadDone;

- (void)saveDialogue;

@end

@implementation ExportWindow

@synthesize tempDirectory;

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) {
		cancelledLock = [[NSLock alloc] init];
		returnCodeLock = [[NSLock alloc] init];
	}
	return self;
}

#pragma mark Startup & Sequence

- (void)cancelPressed:(id)sender {
	[self setIsCancelled:YES];
}

- (void)backgroundMain:(NSString *)file {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self startExporting:file];
	[self performSelectorOnMainThread:@selector(threadDone) withObject:nil waitUntilDone:NO];
	[pool drain];
}

- (void)threadDone {
	[NSApp endSheet:self];
	[self orderOut:self];
}

- (void)startExporting:(NSString *)audioFile {
	if ([[NSThread currentThread] isMainThread]) {
		// run it in the background
		[NSThread detachNewThreadSelector:@selector(backgroundMain:) toTarget:self withObject:[[audioFile copy] autorelease]];
		return;
	}
	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/gcc"]) {
		[self notifyError:@"Xcode must be installed and gcc must be in /usr/bin/gcc in order for you to export executable audio files."];
		return;
	}
	[self setStage:@"Exporting ..."];
	NSString * tempFile = [NSString stringWithFormat:@"SongToExe,%d%d", time(NULL), arc4random() % 1000];
	NSString * tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:tempFile];
	NSString * mainCodePath = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"txt"];
	if (!mainCodePath || ![[NSFileManager defaultManager] fileExistsAtPath:mainCodePath]) {
		[self notifyError:@"Failed to locate main code file in bundle resources!"];
		return;
	}
	if (![self createTempDir:tempDir]) {
		return;
	}
	
	/* Export header */
	[self setStage:@"Creating large header file ..."];
	NSString * songDataHeader = [tempDir stringByAppendingPathComponent:@"songData.h"];
	long long int length = [self exportAudioFile:audioFile output:songDataHeader];
	if (length < 0 || [self isCancelled]) {
		if (![self isCancelled]) [self notifyError:@"Failed to write the temporary header."];
		[[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil];
		return;
	}
	
	/* Create main.m */
	[self setStage:@"Composing main source file ..."];
	[self setProgress:-1];
	NSString * mainCodeDest = [tempDir stringByAppendingPathComponent:@"main.m"];
	NSString * updated = [self updatedMainFileData:length existing:mainCodePath];
	// note: if update is nil, the following call will return NO and an error will be displayed.
	if (![[updated dataUsingEncoding:NSUTF8StringEncoding] writeToFile:mainCodeDest atomically:NO]) {
		[self notifyError:@"Failed to save main code file."];
		[[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil];
		return;
	}
	[NSThread sleepForTimeInterval:0.5];
	
	/* Compile main.m in a new working directory. */
	[self setStage:@"Compiling program ..."];
	[self setProgress:-1];
	if (chdir([tempDir UTF8String]) < 0) {
		[self notifyError:@"Failed to chdir()."];
		[[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil];
		return;
	}
	
	[self setReturnCode:257];
	[NSThread detachNewThreadSelector:@selector(runBackgroundCompile:) toTarget:self withObject:mainCodeDest];
	while (true) {
		if ([self returnCode] != 257) break;
		[NSThread sleepForTimeInterval:0.5];
	}
	if ([self returnCode] != 0) {
		[self notifyError:@"Failed to compile main source file."];
		[[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil];
		return;
	}
	
	/* Display save dialogue.  Wait for result. */
	self.tempDirectory = [[tempDir copy] autorelease];
	[self saveAndWait];
	[[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil];
	self.tempDirectory = nil;
}

#pragma mark Compile Stages

- (BOOL)createTempDir:(NSString *)path {
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[self notifyError:@"Temporary export directory exists.  Failing."];
		return NO;
	}
	if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil]) {
		[self notifyError:@"Failed to create temporary directory."];
		return NO;
	}
	return YES;
}

- (long long int)exportAudioFile:(NSString *)path output:(NSString *)songDataHeader {
	AudioFileEncoder * encoder = [[AudioFileEncoder alloc] initWithAudioFile:path];
	long long int length = [encoder fileSize];
	if (![encoder encodeFileToHeader:songDataHeader progressCallback:^(float progress) {
		// progress changed
		[self setProgress:progress];
		if ([self isCancelled]) {
			return NO;
		}
		return YES;
	}]) {
		[self notifyError:@"Failed to export audio file to a C-style header."];
		[encoder release];
		return -1;
	}
	[encoder release];
	return length;
}
- (NSString *)updatedMainFileData:(long long int)fileSize existing:(NSString *)mainTxt {
	NSString * codeFileContents = [NSString stringWithContentsOfFile:mainTxt encoding:NSUTF8StringEncoding error:nil];
	if (!codeFileContents) {
		return nil;
	}
	NSString * dataLength = [NSString stringWithFormat:@"#define dataLength %ld", (long)fileSize];
	NSString * updated = [codeFileContents stringByReplacingOccurrencesOfString:@"#define dataLength 0" withString:dataLength];
	return updated;
}
- (void)runBackgroundCompile:(NSString *)mainFile {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int result = system([[NSString stringWithFormat:@"gcc %@ -framework Cocoa", mainFile] UTF8String]);
	[self setReturnCode:result];
	[pool drain];
}
- (void)saveAndWait {
	[self setStage:@"Done"];
	[self setProgress:-1];
	[self setReturnCode:0];
	[self performSelectorOnMainThread:@selector(saveDialogue) withObject:nil waitUntilDone:YES];
	while (true) {
		if ([self returnCode] != 0) break;
		[NSThread sleepForTimeInterval:0.5];
	}
}

#pragma mark Endings

- (void)notifyError:(NSString *)errorMsg {
	if (![[NSThread currentThread] isMainThread]) {
		[self performSelectorOnMainThread:@selector(notifyError:) withObject:errorMsg waitUntilDone:NO];
		return;
	}
	NSRunAlertPanel(@"Export failed", errorMsg, @"OK", nil, nil);
}

- (void)saveDialogue {
	NSSavePanel * spanel = [NSSavePanel savePanel];
	NSString * path = @"~/Desktop";
	[spanel setDirectory:[path stringByExpandingTildeInPath]];
	[spanel setPrompt:@"Save Executable"];
	[spanel setRequiredFileType:@""];
	
	[spanel beginSheetForDirectory:[spanel directory]
							  file:nil
					modalForWindow:self
					 modalDelegate:self
					didEndSelector:@selector(didEndSaveSheet:returnCode:conextInfo:)
					   contextInfo:NULL];
}

- (void)didEndSaveSheet:(NSSavePanel *)savePanel returnCode:(int)_returnCode conextInfo:(void *)contextInfo {
	if (_returnCode == NSOKButton) {
		NSString * aOut = [tempDirectory stringByAppendingPathComponent:@"a.out"];
		[[NSFileManager defaultManager] copyItemAtPath:aOut toPath:[savePanel filename] error:nil];
	} else {
		
	}
	[self setReturnCode:1];
	[NSApp endSheet:self];
	[self orderOut:self];
}

#pragma mark Properties

- (BOOL)isCancelled {
	[cancelledLock lock];
	BOOL isCancelled = cancelled;
	[cancelledLock unlock];
	return isCancelled;
}

- (void)setIsCancelled:(BOOL)flag {
	[cancelledLock lock];
	cancelled = flag;
	[cancelledLock unlock];
}

- (int)returnCode {
	[returnCodeLock lock];
	int retCode = returnCode;
	[returnCodeLock unlock];
	return retCode;
}

- (void)setReturnCode:(int)retCode {
	[returnCodeLock lock];
	returnCode = retCode;
	[returnCodeLock unlock];
}

#pragma mark Progress Updates

- (void)setStage:(NSString *)stage {
	if ([NSThread currentThread] != [NSThread mainThread]) {
		[self performSelector:@selector(setStage:) onThread:[NSThread mainThread] withObject:stage waitUntilDone:NO];
		return;
	}
	if (!cancelButton) {
		cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(((NSView *)[self contentView]).frame.size.width - 90, 10, 80, 24)];
		[cancelButton setTitle:@"Cancel"];
		[cancelButton setTarget:self];
		[cancelButton setAction:@selector(cancelPressed:)];
		[cancelButton setEnabled:YES];
		[cancelButton setButtonType:NSMomentaryLightButton];
		[cancelButton setBezelStyle:NSRoundRectBezelStyle];
		[[self contentView] addSubview:cancelButton];
	}
	if (!loadingStage) {
		loadingStage = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 55, [[self contentView] bounds].size.width - 20, 20)];
		[[self contentView] addSubview:loadingStage];
		[loadingStage setBordered:NO];
		[loadingStage setSelectable:NO];
		[loadingStage setBackgroundColor:[NSColor clearColor]];
	}
	if (!loadingBar) {
		loadingBar = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(10, 35, [[self contentView] bounds].size.width - 20, 17)];
		[loadingBar setIndeterminate:NO];
		[loadingBar setMinValue:0];
		[loadingBar setMaxValue:1];
		[[self contentView] addSubview:loadingBar];
	}
	[loadingStage setStringValue:stage];
	[loadingBar setDoubleValue:0];
	[loadingBar setIndeterminate:NO];
}

- (void)setProgress:(float)stageProgress {
	[self setProgressObj:[NSNumber numberWithFloat:stageProgress]];
}

- (void)setProgressObj:(NSNumber *)numProgress {
	if ([NSThread currentThread] == [NSThread mainThread]) {
		float stageProgress = (float)([numProgress floatValue]);
		if (stageProgress < 0) {
			[loadingBar setIndeterminate:YES];
			[loadingBar startAnimation:nil];
			return;
		}
		[loadingBar stopAnimation:nil];
		[loadingBar setIndeterminate:NO];
		if (stageProgress >= 1.0f) [loadingBar setDoubleValue:1];
		else [loadingBar setDoubleValue:stageProgress];
	} else {
		[self performSelector:@selector(setProgressObj:) onThread:[NSThread mainThread] withObject:numProgress waitUntilDone:NO];
	}
}

#pragma mark Disposal

- (void)dealloc {
	[tempDirectory release];
	[cancelledLock release];
	[returnCodeLock release];
	[loadingBar release];
	[loadingStage release];
	[cancelButton release];
    [super dealloc];
}

@end
