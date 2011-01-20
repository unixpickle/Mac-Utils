//
//  QuickTranslateAppDelegate.m
//  QuickTranslate
//
//  Created by Alex Nichol on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuickTranslateAppDelegate.h"

@implementation QuickTranslateAppDelegate

@synthesize window;

- (IBAction)switchOrder:(id)sender {
	if (order == 0) {
		order = 1;
	} else order = 0;
	if (order == 0) {
		[labelOne setStringValue:@"French"];
		[labelTwo setStringValue:@"English"];
	} else if (order == 1) {
		[labelOne setStringValue:@"English"];
		[labelTwo setStringValue:@"French"];
	}
}

- (void)translator:(GTTranslator *)sender translatedText:(NSString *)oldText intoText:(NSString *)newText {
	if (sender == translator)
		[secondField setStringValue:newText];
	[sender release];
	translator = nil;
}

- (IBAction)translate:(id)sender {
	[translator stopRequest];
	[translator release];
	GTTranslator * translate = [[GTTranslator alloc] initWithLanguage:order == 0 ? kGTLanguageFrench : kGTLanguageEnglish];
	[translate setDelegate:self];
	[translate translateSynchronously:[firstField stringValue]
						   toLangauge:(order == 0 ? kGTLanguageEnglish : kGTLanguageFrench)];
	translator = translate;
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
	[self translate:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	[firstField setDelegate:self];
}

@end
