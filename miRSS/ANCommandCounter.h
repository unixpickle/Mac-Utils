//
//  ANCommandCounter.h
//  miRSS
//
//  Created by Alex Nichol on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ANCommandCounter : NSScriptCommand {

}
// used for tracking the main manager
+ (id *)mainManagerPointer;
- (id)executeCommand;

@end
