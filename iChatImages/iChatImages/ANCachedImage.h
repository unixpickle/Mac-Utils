//
//  ANCachedImage.h
//  iChatImages
//
//  Created by Alex Nichol on 10/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANCachedImage : NSObject {
	NSString * fileName;
	NSImage * thumbnail;
	NSDate * dateModified;
}

@property (readonly) NSString * fileName;
@property (readonly) NSImage * thumbnail;
@property (readonly) NSDate * dateModified;

- (id)initWithImageFile:(NSString *)fileName;
- (NSComparisonResult)compare:(ANCachedImage *)anImage;

@end
