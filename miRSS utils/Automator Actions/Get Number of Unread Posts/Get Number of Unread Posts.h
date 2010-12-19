//
//  Get Number of Unread Posts.h
//  Get Number of Unread Posts
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright (c) 2010 __MyCompanyName__, All Rights Reserved.
//

#import <Cocoa/Cocoa.h>
#import <Automator/AMBundleAction.h>
#import "ANRSSProxy.h"

@interface Get_Number_of_Unread_Posts : AMBundleAction  {
}

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

@end
