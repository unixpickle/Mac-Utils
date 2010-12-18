//
//  List miRSS Channel Names.h
//  List miRSS Channel Names
//
//  Created by Alex Nichol on 12/18/10.
//  Copyright (c) 2010 __MyCompanyName__, All Rights Reserved.
//

#import <Cocoa/Cocoa.h>
#import <Automator/AMBundleAction.h>
#import "ANRSSProxy.h"

@interface List_miRSS_Channel_Names : AMBundleAction  {
	BOOL includeURLs;
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary;
- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

@end
