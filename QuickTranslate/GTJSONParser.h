//
//  GTJSONParser.h
//  FrenchCheater
//
//  Created by Alex Nichol on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GTJSONParser : NSObject {

}

- (NSArray *)parseJSONArray:(NSString *)jsonArray lastCharacter:(int *)last;

@end
