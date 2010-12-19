//
//  Wait For New Post.h
//  Wait For New Post
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright (c) 2010 __MyCompanyName__, All Rights Reserved.
//

#import <Cocoa/Cocoa.h>
#import <Automator/AMBundleAction.h>
#import "ANRSSProxy.h"

@interface Wait_For_New_Post : AMBundleAction  {
}

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

@end
