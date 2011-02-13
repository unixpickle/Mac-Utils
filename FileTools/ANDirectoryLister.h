//
//  ANDirectoryLister.h
//  ShrinkyBops
//
//  Created by Alex Nichol on 12/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ANDirectoryLister : NSObject {

}
+ (NSArray *)contentsOfDirectory:(NSString *)directoryName;
@end
