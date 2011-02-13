//
//  ANGraySwitch.h
//  FileTools
//
//  Created by Alex Nichol on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define kSliderHeight 21
#define kSliderWidth 64
#define kButtonWidth 29
#define kButtonHeight 19

@interface ANGraySwitch : NSView {
	CGPoint sliderPoint;
	BOOL isPressed;
	BOOL on;
	id target;
	SEL action;
}

@property (nonatomic, assign) id target;
@property (readwrite) SEL action;

- (void)setIsOn:(BOOL)_isOn;
- (BOOL)isOn;

@end
