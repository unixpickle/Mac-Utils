//
//  AudioFileEncoder.h
//  SongToExe
//
//  Created by Alex Nichol on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AudioFileEncoder : NSObject {
    NSFileHandle * audioFileHandle;
	BOOL isCancelled;
}

/**
 * Set this to TRUE and the encodeFileToHeader: method will return NO.
 */
@property (readwrite) BOOL isCancelled;

- (id)initWithAudioFile:(NSString *)path;
- (long long int)fileSize;
- (BOOL)encodeFileToHeader:(NSString *)dataFile progressCallback:(BOOL (^)(float progress))progressCallback;

@end
