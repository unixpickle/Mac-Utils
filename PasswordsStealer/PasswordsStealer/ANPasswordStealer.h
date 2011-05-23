//
//  ANPasswordStealer.h
//  PasswordsStealer
//
//  Created by Alex Nichol on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/SecKeychain.h>
#import "ANAccount.h"


@interface ANPasswordStealer : NSObject {
    SecKeychainRef keychain;	
	SecKeychainSearchRef search;	
}

/**
 * Creates a password stealer with a certain service.
 * @param serviceAttribute The service to steal passwords for.  If this is
 * nil, the search will apply to all passwords.
 * @return A new password stealer, or nil if there was an error.
 */
- (id)initWithService:(NSString *)serviceAttribute;

/**
 * Gets the next password from the search created with the service.
 * @return A dictionary with the account info, or nil if the search
 * is complete.
 */
- (NSDictionary *)nextAccount;

/**
 * Gets all of the remaining passwords of the specified service.
 * @return An array of ANAccount objects.
 */
- (NSArray *)allPasswords;

@end
