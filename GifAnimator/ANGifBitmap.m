//
//  ANGifBitmap.m
//  Giraffe
//
//  Created by Alex Nichol on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANGifBitmap.h"

static UInt8 make3 (UInt8 m) {
	if (m >= 4) m = 3;
	return m;
}

@implementation ANGifBitmap

- (id)initWithImage:(NSImage *)image {
	if (self = [super init]) {
		bmpImage = [[ANImageBitmapRep alloc] initWithImage:(CIImage *)image];
	}
	return self;
}
- (CGSize)size {
	return [bmpImage size];
}
- (void)setSize:(CGSize)s {
	[bmpImage setSize:s];
}
- (UInt32)getPixel:(CGPoint)pt {
	UInt32 pxl = 0;
	CGFloat pixel[4];
	[bmpImage getPixel:pixel atX:(int)pt.x y:(int)pt.y];
	unsigned char * pxlData = (unsigned char *)&pxl;
	// set the bytes
	pxlData[0] = pixel[3] * 255.0f;
	pxlData[1] = pixel[0] * 255.0f;
	pxlData[2] = pixel[1] * 255.0f;
	pxlData[3] = pixel[2] * 255.0f;
	return pxl;
}

- (NSData *)smallBitmapData {
	// go through and get every single pixel, 
	// then turn it into one byte/pixel
	NSMutableData * returnData = [NSMutableData data];
	CGSize s = [self size];
	int width = (int)s.width;
	int height = (int)s.height;
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			// read the information
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
			//NSLog(@"Reading: %d, %d", x, y);
			UInt32 pixel = [self getPixel:CGPointMake(x,y)];
			UInt8 * pxlData = (UInt8 *)&pixel;
			//NSLog(@"Done.");
			// now we need to compress the pixel
			UInt8 small = 0;
			small |= make3((int)round((float)pxlData[1] / 64.0f));
			small |= make3((int)round((float)pxlData[2] / 64.0f)) << 2;
			small |= make3((int)round((float)pxlData[3] / 64.0f)) << 4;
			small |= make3((int)round((float)pxlData[0] / 64.0f)) << 6;
			if (small == 0) small = 128;
			// NSLog(@"%d", pxlData[0]);
			if (pxlData[0] < 128) small = 0;
			[returnData appendBytes:&small length:1];
			//NSLog(@"Size: %d", [returnData length]);
			[pool drain];
			//NSLog(@"Done freepool.");
		}
	}
	
	NSLog(@"Done conversion.");
	
	return returnData;
}

- (void)dealloc {
	[bmpImage release];
	[super dealloc];
}

@end
