//
//  ANGifBitmap.h
//  Giraffe
//
//  Created by Alex Nichol on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANImageBitmapRep.h"

@interface ANGifBitmap : NSObject {
	ANImageBitmapRep * bmpImage;
}

- (id)initWithImage:(NSImage *)image;
- (CGSize)size;
- (void)setSize:(CGSize)s;
- (UInt32)getPixel:(CGPoint)pt;
- (NSData *)smallBitmapData;

@end
