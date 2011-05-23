//
//  ANPassword.h
//  PasswordsStealer
//
//  Created by Alex Nichol on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ANAccount : NSObject {
    NSString * username;
	NSString * password;
	NSString * service;
}

@property (readonly) NSString * username;
@property (readonly) NSString * password;
@property (readonly) NSString * service;

/**
 * Creates an account object with various info.
 * @param aUsername The username to use
 * @param aPassword The password to use
 * @param theService The service to use
 */
- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword service:(NSString *)theService;

/**
 * Creates an account with a dictionary containing keys of information.
 * @param infoDict The dictionary that contains keys such as "Service", "Username",
 * and "Password."
 */
- (id)initWithDictionary:(NSDictionary *)infoDict;

@end
