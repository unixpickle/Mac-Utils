//
//  GTTranslator.m
//  FrenchCheater
//
//  Created by Alex Nichol on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GTTranslator.h"

@interface GTTranslator ()

- (void)translateThread:(NSDictionary *)information;
- (void)callDelegate:(NSDictionary *)finished;

@end

@implementation GTTranslator

@synthesize delegate;

+ (NSString *)shortName:(enum _GTLanguage)language {
	switch (language) {
		case kGTLanguageEnglish:
			return @"en";
			break;
		case kGTLanguageFrench:
			return @"fr";
			break;
		case kGTLanguageGerman:
			return @"de";
			break;
		case kGTLanguageYiddish:
			return @"yi";
			break;
		case kGTLanguageDetect:
			return @"auto";
			break;
		default:
			break;
	}
	return nil;
}
+ (NSString *)longName:(enum _GTLanguage)language {
	switch (language) {
		case kGTLanguageEnglish:
			return @"English";
			break;
		case kGTLanguageFrench:
			return @"French";
			break;
		case kGTLanguageGerman:
			return @"German";
			break;
		case kGTLanguageYiddish:
			return @"Yiddish";
			break;
		case kGTLanguageDetect:
			return @"Auto Detect";
			break;
		default:
			break;
	}
	return nil;
}

#pragma mark Translating

- (id)initWithLanguage:(enum _GTLanguage)original {
	if (self = [super init]) {
		originalLanguage = original;
	}
	return self;
}
- (NSString *)AsynchronouslyTranslate:(NSString *)text toLangauge:(enum _GTLanguage)l {
	// fetch and translate that sucker
	newLanguage = l;
	NSString * escaped = [text stringByEscapingAllAsciiCharacters];
	NSString * apiURL = @"http://translate.google.com/translate_a/t?client=t&text=%@&hl=en&sl=%@&tl=%@&multires=1&otf=1&sc=1";
	NSString * mainURL = [NSString stringWithFormat:apiURL,
						  escaped,
						  [GTTranslator shortName:originalLanguage], 
						  [GTTranslator shortName:l]];
	NSURL * requestURL = [NSURL URLWithString:mainURL];
	NSURLRequest * request = [NSURLRequest requestWithURL:requestURL];
	// send the request
	NSData * jsonData = [NSURLConnection sendSynchronousRequest:request
											  returningResponse:nil
														  error:nil];
	if (!jsonData) return nil;
	NSString * jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSWindowsCP1252StringEncoding] autorelease];
	NSData * asciiData = [jsonString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString * asciiString = [[[NSString alloc] initWithData:asciiData
													encoding:NSASCIIStringEncoding] autorelease];
	
	// parse the data
	GTJSONParser * parser = [[GTJSONParser alloc] init];
	NSArray * a = [parser parseJSONArray:asciiString lastCharacter:NULL];
	
	NSArray * lines = [a objectAtIndex:0];
	NSMutableString * translated = [NSMutableString string];
	// read each line
	for (NSArray * line in lines) {
		[translated appendFormat:@"%@", [line objectAtIndex:0]];
	}
	
	return translated;
}
- (void)translateSynchronously:(NSString *)text toLangauge:(enum _GTLanguage)l {
	newLanguage = l;
	
	if (fetchThread) {
		[fetchThread cancel];
		[fetchThread release];
		fetchThread = nil;
	}
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSDictionary * attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
								 [[text copy] autorelease], @"text", 
								 [GTTranslator shortName:originalLanguage], @"from", 
								 [GTTranslator shortName:l], @"to", nil];
	
	fetchThread = [[NSThread alloc] initWithTarget:self 
										  selector:@selector(translateThread:)
											object:attributes];
	[fetchThread start];
	
	[pool drain];
}

- (void)translateThread:(NSDictionary *)information {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self retain];
	NSString * text = [information objectForKey:@"text"];
	NSString * from = [information objectForKey:@"from"];
	NSString * to = [information objectForKey:@"to"];
	
	// read the URL and call back the delegate
	// fetch and translate that sucker
	NSString * escaped = [text stringByEscapingAllAsciiCharacters];
	NSString * apiURL = @"http://translate.google.com/translate_a/t?client=t&text=%@&hl=en&sl=%@&tl=%@&multires=1&otf=1&sc=1";
	NSString * mainURL = [NSString stringWithFormat:apiURL,
						  escaped,
						  from, 
						  to];
	NSURL * requestURL = [NSURL URLWithString:mainURL];
	NSURLRequest * request = [NSURLRequest requestWithURL:requestURL];
	// send the request
	NSData * jsonData = [NSURLConnection sendSynchronousRequest:request
											  returningResponse:nil
														  error:nil];

	if (!jsonData) return;
	NSString * jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSWindowsCP1252StringEncoding] autorelease];
	NSData * asciiData = [jsonString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString * asciiString = [[[NSString alloc] initWithData:asciiData
													encoding:NSASCIIStringEncoding] autorelease];
	
	
	// parse the data
	GTJSONParser * parser = [[GTJSONParser alloc] init];
	NSArray * a = [parser parseJSONArray:asciiString lastCharacter:NULL];
	
	
	NSArray * lines = [a objectAtIndex:0];
	NSMutableString * translated = [[NSMutableString alloc] init];
	// read each line
	for (NSArray * line in lines) {
		[translated appendFormat:@"%@", [line objectAtIndex:0]];
	}
	
	NSDictionary * final = [[NSDictionary alloc] initWithObjectsAndKeys:
							translated, @"translated",
							[NSValue valueWithPointer:self], @"sender",
							text, @"original", nil];
	
	[information release];

	if ([[NSThread currentThread] isCancelled]) {
		[pool drain];
		return;
	}
	
	[self performSelectorOnMainThread:@selector(callDelegate:)
						   withObject:final waitUntilDone:NO];
	
	[pool drain];
	[self release];
	fetchThread = nil;
}

- (void)callDelegate:(NSDictionary *)finished {
	NSString * translated = [finished objectForKey:@"translated"];
	id sender = [[finished objectForKey:@"sender"] pointerValue];
	NSString * original = [finished objectForKey:@"original"];
	if ([(id)delegate respondsToSelector:@selector(translator:translatedText:intoText:)]) {
		[delegate translator:sender
			  translatedText:original intoText:translated];
	}
	[finished release];
	if (fetchThread) {
		[fetchThread cancel];
		[fetchThread release];
		fetchThread = nil;
	}
}

- (void)stopRequest {
	if (fetchThread) {
		[fetchThread cancel];
		[fetchThread release];
		fetchThread = nil;
	}
}

#pragma mark Properties

- (enum _GTLanguage)originalLanguage {
	return originalLanguage;
}
- (enum _GTLanguage)newLanguage {
	return newLanguage;
}

- (void)dealloc {
	if (fetchThread) {
		NSLog(@"Freeing while fetching!");
		[fetchThread cancel];
		[fetchThread release];
		fetchThread = nil;
	}
	
	[super dealloc];
}

@end
