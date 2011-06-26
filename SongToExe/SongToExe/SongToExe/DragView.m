//
//  DragView.m
//  SongToExe
//
//  Created by Alex Nichol on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DragView.h"


@implementation DragView

@synthesize fileName;
@synthesize delegate;

- (void)typeRegister {
	if (hasRegistered) return;
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	hasRegistered = YES;
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self typeRegister];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self typeRegister];
	}
	return self;
}

- (void)dealloc {
	[dragBg release];
	self.fileName = nil;
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
	if (!dragBg) {
		dragBg = [[NSImage imageNamed:@"drag_bg.png"] retain];
	}
	[dragBg drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

#pragma mark Drag & Drop

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric) {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
		//are offering
        return NSDragOperationGeneric;
    } else {
        //since they aren't offering the type of operation we want, we have 
		//to tell them we aren't interested
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) == NSDragOperationGeneric) {
        return NSDragOperationGeneric;
    } else {
        return NSDragOperationNone;
    }
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard * paste = [sender draggingPasteboard];
	//gets the dragging-specific pasteboard from the sender
    NSArray * types = [NSArray arrayWithObjects:NSTIFFPboardType, 
					   NSFilenamesPboardType, nil];
	//a list of types that we can accept
    NSString * desiredType = [paste availableTypeFromArray:types];
    NSData * carriedData = [paste dataForType:desiredType];
	
    if (nil == carriedData) {
        //the operation failed for some reason
        NSRunAlertPanel(@"Paste Error", @"Sorry, but the past operation failed", 
						nil, nil, nil);
        return NO;
    } else {
        // the pasteboard was able to give us some meaningful data
        if ([desiredType isEqualToString:NSFilenamesPboardType]) {
            NSArray * fileArray = [paste propertyListForType:@"NSFilenamesPboardType"];
			if ([fileArray count] != 1) {
				NSRunAlertPanel(@"No Folders", @"You cannot encode more than one file.", @"OK", nil, nil);
				[self setFileName:nil];
				return NO;
			}
            NSString * path = [fileArray objectAtIndex:0];
			BOOL isDir = NO;
			if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
				return NO;
			}
			if (isDir) {
				NSRunAlertPanel(@"No Folders", @"You cannot encode a folder.", @"OK", nil, nil);
				[self setFileName:nil];
				return NO;
			}
			[self setFileName:path];
        } else {
            NSRunAlertPanel(@"Not a file", @"This only supports files.", @"OK", nil, nil);
            return NO;
        }
    }
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    //re-draw the view with our new data
	if ([self fileName]) {
		NSLog(@"Calling callback.");
		[delegate dragViewDroppedFile:self];
		NSLog(@"Called callback.");
	}
}

@end
