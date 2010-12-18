//
//  Combine Text List.h
//  Combine Text List
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright (c) 2010 __MyCompanyName__, All Rights Reserved.
//

#import <Cocoa/Cocoa.h>
#import <Automator/AMBundleAction.h>

@interface Combine_Text_List : AMBundleAction 
{
}

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

@end
