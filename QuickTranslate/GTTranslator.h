//
//  GTTranslator.h
//  FrenchCheater
//
//  Created by Alex Nichol on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GTJSONParser.h"
#import "ANStringEscaper.h"

enum _GTLanguage {
	kGTLanguageEnglish = 1,
	kGTLanguageFrench = 2,
	kGTLanguageGerman = 4,
	kGTLanguageYiddish = 8,
	kGTLanguageDetect = 16
};

@class GTTranslator;

@protocol GTTranslatorDelegate

- (void)translator:(GTTranslator *)sender 
	translatedText:(NSString *)oldText
		  intoText:(NSString *)newText;

@end

@interface GTTranslator : NSObject {
	enum _GTLanguage originalLanguage;
	enum _GTLanguage newLanguage;
	id<GTTranslatorDelegate> delegate;
	NSThread * fetchThread;
}

@property (nonatomic, assign) id<GTTranslatorDelegate> delegate;

+ (NSString *)shortName:(enum _GTLanguage)language;
+ (NSString *)longName:(enum _GTLanguage)language;

- (id)initWithLanguage:(enum _GTLanguage)original;
- (NSString *)AsynchronouslyTranslate:(NSString *)text toLangauge:(enum _GTLanguage)l;
- (void)translateSynchronously:(NSString *)text toLangauge:(enum _GTLanguage)l;

- (enum _GTLanguage)originalLanguage;
- (enum _GTLanguage)newLanguage;

@end
