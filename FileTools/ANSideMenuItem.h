//
//  ANSideMenuItem.h
//  FancySideMenu
//
//  Created by Alex Nichol on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define kSideMenuContentOffset 20

@class ANSideMenuItem;

@protocol ANSideMenuItemDelegate

- (void)sideMenuSelected:(ANSideMenuItem *)sender;

@end

@interface ANSideMenuItem : NSView {
	NSImageView * imageIcon;
	NSString * title;
	BOOL isSelected;
	BOOL isActive;
	BOOL fullColor;
	
	id<ANSideMenuItemDelegate> delegate;
	int tag;
}

@property (nonatomic, assign) id delegate;

- (int)tag;
- (void)setTag:(int)_tag;

- (NSDictionary *)stringAttributes;
- (NSColor *)textColor;

- (id)initWithTitle:(NSString *)title icon:(NSImage *)image;
- (void)setTitle:(NSString *)string;
- (NSString *)title;
- (void)setIcon:(NSImage *)icon;

- (BOOL)isSelected;
- (void)setSelected:(BOOL)selected;
- (BOOL)isActive;
- (void)setActive:(BOOL)active;
- (BOOL)fullColor;
- (void)setFullColor:(BOOL)fColor;

@end
