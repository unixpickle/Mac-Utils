//
//  WhenFileAppDelegate.h
//  WhenFile
//
//  Created by Alex Nichol on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface WhenFileAppDelegate : NSObject {
    NSWindow * window;
	IBOutlet NSTextField * pathBox;
	IBOutlet NSDatePicker * created;
	IBOutlet NSDatePicker * modified;
	NSString * currentPath;
}

@property (nonatomic, retain) NSString * currentPath;

- (IBAction)pickPath:(id)sender;
- (IBAction)dateChange:(id)sender;
- (IBAction)saveChanges:(id)sender;

@property (assign) IBOutlet NSWindow * window;

@end
