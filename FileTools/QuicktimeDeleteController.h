//
//  QuicktimeDeleteController.h
//  FileTools
//
//  Created by Alex Nichol on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "ANQuicktimeAtom.h"
#import "ANQuicktimeMovie.h"
#import "ANQuicktimeList.h"

@interface QuicktimeDeleteController : NSObject {
	IBOutlet NSTextField * filePath;
	IBOutlet NSTextField * deletionStatus;
}
- (IBAction)pickFile:(id)sender;
- (IBAction)removeTimestamp:(id)sender;
@end
