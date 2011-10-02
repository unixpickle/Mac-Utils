//
//  ANChatImageCache.h
//  iChatImages
//
//  Created by Alex Nichol on 10/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANCachedImage.h"

@class ANChatImageCache;

@protocol ANChatImageCacheDelegate <NSObject>

@optional
- (void)chatImageCacheFoundNewFiles:(ANChatImageCache *)cache;
- (void)chatImageCacheFinished:(ANChatImageCache *)cache;
- (void)chatImageCacheFailed:(ANChatImageCache *)cache;

@end

@interface ANChatImageCache : NSObject {
	NSMutableArray * chatImageCache;
	NSThread * reloadThread;
	id<ANChatImageCacheDelegate> delegate;
}

@property (nonatomic, assign) id<ANChatImageCacheDelegate> delegate;

- (void)startReloading;
- (void)cancelReloading;
- (NSArray *)imageFiles;

@end
