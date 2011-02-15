//
//  ResourceForkManager.h
//  ResourceForkTesting
//
//  Created by Alex Nichol on 10/30/10.
//  Copyright 2010 Jitsik. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>


@interface ResourceForkManager : NSObject {
	ResFileRefNum resFile;
}
- (BOOL)openResourceForFile:(NSString *)filePath;
- (BOOL)writeDataToFile:(NSData *)d;
- (NSData *)readDataFromFile;
- (NSString *)readStringFromFile;
- (void)closeFile;
@end
