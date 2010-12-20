//
//  ANRSSArticle.h
//  miRSS
//
//  Created by Alex Nichol on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ANRSSArticle : NSObject {
	NSObject * parentObject;
	NSString * title;
	NSString * content;
	NSString * date;
	NSNumber * index;
}
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, assign) NSObject * parentObject;
@end
