//
//  DragView.h
//  SongToExe
//
//  Created by Alex Nichol on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DragView;

@protocol DragViewDelegate

- (void)dragViewDroppedFile:(DragView *)dv;

@end

@interface DragView : NSView {
    NSImage * dragBg;
	BOOL hasRegistered;
	NSString * fileName;
	id<DragViewDelegate> delegate;
}

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) id<DragViewDelegate> delegate;

@end
