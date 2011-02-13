//
//  ANQuicktimeList.h
//  FileTools
//
//  Created by Alex Nichol on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANQuicktimeAtom.h"

@interface ANQuicktimeList : NSObject {
	NSMutableArray * dataComponents;
}

@property (nonatomic, retain) NSMutableArray * dataComponents;

- (id)initWithData:(NSData *)ilst;
- (NSData *)encodeData;

@end
