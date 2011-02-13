//
//  ANQuicktimeMovie.h
//  WhenFile
//
//  Created by Alex Nichol on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANQuicktimeAtom.h"

@interface ANQuicktimeMovie : NSObject {
	NSFileHandle * file;
	ANQuicktimeAtom * moov;
	ANQuicktimeAtom * toplevel;
	ANQuicktimeAtom * metadata;
}

- (id)initWithFile:(NSString *)path;
- (ANQuicktimeAtom *)movieAtom;
- (ANQuicktimeAtom *)metaData;
- (void)closeFile;

@end
