//
//  ANDeleteFeedCommand.h
//  miRSS
//
//  Created by Alex Nichol on 12/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANCommandCounter.h"
#import "ANRSSFeed.h"
#import "RSSChannel.h"
#import "ANRSSManager.h"

@interface ANDeleteFeedCommand : NSScriptCommand {
	ANRSSFeed * feed;
}
@property (nonatomic, retain) ANRSSFeed * feed;
- (id)executeCommand;
@end
