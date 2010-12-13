//
//  ANApplicationHotKey.h
//  KeyShot
//
//  Created by Alex Nichol on 3/30/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANKeyEvent.h"


@interface ANApplicationHotKey : NSObject {
	ANKeyEvent * keyEvent;
	NSString * appName;
	NSString * appPath;
}
- (void)keyPressed:(id)sender;
@property (nonatomic, retain) NSString * appName;
@property (nonatomic, retain) NSString * appPath;
- (ANKeyEvent *)keyEvent;
- (void)setKeyEvent:(ANKeyEvent *)ke;
@property (nonatomic, assign) ANKeyEvent * keyEvent;
- (NSDictionary *)dictionaryValue;
@end
