//
//  DockItem.h
//  dockrw
//
//  Created by Alex Nichol on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DockItem : NSObject {
	NSString * appPath;
	NSString * label;
	NSDictionary * dict;
}

@property (nonatomic, retain) NSString * appPath;
@property (nonatomic, retain) NSString * label;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)initWithPath:(NSString *)app;
- (NSDictionary *)itemDictionary;

@end
