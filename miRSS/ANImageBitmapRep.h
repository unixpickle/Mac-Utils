//
//  ANImageBitmapRep.h
//  ANImageBitmapRep
//
//  Created by Alex Nichol on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>


@interface ANImageBitmapRep : NSObject {
	CGContextRef ctx;
	CGImageRef img;
	BOOL changed;
	char * bitmapData;
}
- (void)clearBitmap;
- (void)setChanged;
+ (CGImageRef)CGImageForNSImage:(id)_img;
+ (NSImage*)NSImageFromCGImageRef:(CGImageRef)image;
+ (CGContextRef)CreateARGBBitmapContextWithSize:(CGSize)size;
+ (CGContextRef)CreateARGBBitmapContextWithImage:(CGImageRef)image;
- (id)initWithImage:(NSImage *)_img;
- (id)initWithSize:(NSSize)size;
- (void)invertColors;
- (ANImageBitmapRep *)cropWithFrame:(CGRect)frm;
+ (id)imageBitmapRepWithImage:(NSImage *)_img;
+ (id)imageBitmapRepNamed:(NSString *)_resourceName;
- (void)getPixel:(CGFloat *)pxl atX:(int)x y:(int)y;
- (void)setPixel:(CGFloat *)pxl atX:(int)x y:(int)y;
- (CGImageRef)CGImage;
- (NSImage *)image;
- (void)setSize:(CGSize)size;
- (CGSize)size;
- (CGContextRef)graphicsContext;
- (void)drawInRect:(NSRect)rect;
- (void)inverseColors;
@end
