//
//  GeneratePasswordController.m
//  PasswordLearner
//
//  Created by Alex Nichol on 7/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GeneratePasswordController.h"


@implementation GeneratePasswordController

@synthesize passwordStrength;
@synthesize passwordGenerated;
@synthesize generateLength;
@synthesize generateButton;
@synthesize generateTips;
@synthesize passwordDigits;

- (id)init {
	[super init];
	
	return self;
}
- (void)awakeFromNib {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	BOOL stars = [ud boolForKey:@"stars"];
	if (stars) {
		[passwordStrength setCell:[[NSLevelIndicatorCell alloc] initWithLevelIndicatorStyle:NSRatingLevelIndicatorStyle]];
	}
	[generateTips setFont:[passwordGenerated font]];
	weekPasswords = [[NSArray alloc] initWithObjects:@"sex", @"secret", @"love", @"god", 
					 @"sexy", @"whore", @"pass", @"passwd", @"login", @"women",
					 @"sesame", @"opensesame", @"penis", @"vagina", @"fuck", @"girls",
					 @"motherfucker", @"xbox", @"yourmom", @"password", @"tits",
					 @"alloc", @"admin", @"password1", @"password123", @"crowley",
					 @"stud", @"boobs", @"porn", @"yummy", @"bagel", @"12345",
					 @"123456", @"root", @"toor", @"administrator", @"shit", 
					 @"iloveyou", @"licking", @"fucker", @"chad", @"guest",
					 @"shared", @"public", @"etc", @"shadow", @"hidden", nil];
	if (passwordGenerated == nil) {
		NSLog(@"No access to controls");
	} else {
		[passwordGenerated setDelegate:self];
	}
	NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
	NSRect windowFrame = [[self window] frame];
	[[self window] setFrame:NSMakeRect((visibleFrame.size.width - windowFrame.size.width) * 0.5,
									((visibleFrame.size.height / 2) - (windowFrame.size.height / 2)),
									windowFrame.size.width, windowFrame.size.height) display:YES];
}
- (void)controlTextDidChange:(NSNotification *)aNotification {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	BOOL stars = [ud boolForKey:@"stars"];
	if (stars) {
		[passwordStrength setCell:[[NSLevelIndicatorCell alloc] initWithLevelIndicatorStyle:NSRatingLevelIndicatorStyle]];
		[passwordStrength setCriticalValue:1];
		[passwordStrength setWarningValue:2];
		[passwordStrength setMaxValue:5];
		[passwordStrength setIntValue:0];
	} else {
		[passwordStrength setCell:[[NSLevelIndicatorCell alloc] initWithLevelIndicatorStyle:NSContinuousCapacityLevelIndicatorStyle]];
		[passwordStrength setCriticalValue:1];
		[passwordStrength setWarningValue:2];
		[passwordStrength setMaxValue:5];
		[passwordStrength setIntValue:0];
	}
	if (passwordGenerated == nil) {
		NSLog(@"No access to controls");
	} else {
		[self passwordChanged];
	}
}
- (int)amountOfPointsOfChar:(char)c {
	if (c == 'a' || c == 'b' || c == 'c' || c == 'd' || c == 'e' || c == 'f'
		|| c == 'g' || c == 'h' || c == 'i' || c == 'j' || c == 'k' || c == 'l'
		|| c == 'm' || c == 'n' || c == 'o' || c == 'p' || c == 'q' || c == 'r'
		|| c == 's' || c == 't' || c == 'u' || c == 'v' || c == 'w' || c == 'x'
		|| c == 'y' || c == 'z') {
		return 4;
	}
	if (c == 'A' || c == 'B' || c == 'C' || c == 'D' || c == 'E' || c == 'F'
		|| c == 'G' || c == 'H' || c == 'I' || c == 'J' || c == 'K' || c == 'L'
		|| c == 'M' || c == 'N' || c == 'O' || c == 'P' || c == 'Q' || c == 'R'
		|| c == 'S' || c == 'T' || c == 'U' || c == 'V' || c == 'W' || c == 'X'
		|| c == 'Y' || c == 'Z') {
		return 5;
	}
	if (c == '1' || c == '2' || c == '3' || c == '4' || c == '5' || c == '6'
		|| c == '7' || c == '8' || c == '9' || c == '0') {
		return 6;
	}
	if (c == ',' || c == '.' || c == '?' || c == '/' || c == '<' || c == '>'
		|| c == '(' || c == ')' || c == '!' || c == '@' || c == '[' || c == ']'
		|| c == '{' || c == '}' || c == '\\' || c == '|' || c == '%'
		|| c == '+' || c == '-' || c == '_' || c == '=') {
		return 7;
	}
	if (c == ' ' || c == '%' || c == '$' || c == '&' || c == '*') {
		return 9;
	}
	return 12;
}
- (BOOL)checkForChar:(NSString *)searching inString:(NSString *)str {
	int i;
	for (i = 0; i < [str length]; i++) {
		NSString *checkChar = [[NSString alloc] initWithFormat:@"%c", (char)[str characterAtIndex:i]];
		if ([checkChar isEqual:searching]) {
			return YES;
		}
	}
	return NO;
}
- (BOOL)checkForString:(NSString *)searching inString:(NSString *)str {
	if ([searching isEqual:str])
		return YES;
	int i;
	int totalLen = [str length];
	int searchLen = [searching length];
	for (i = 0; i < (totalLen - searchLen) - 1; i++) {
		NSString *checkFor;
		NSLog(@"%d, %d", i, i + (searchLen - 1));
		if (i == 0)
			checkFor = [[NSString alloc] initWithString:[str substringWithRange:NSMakeRange(0, 1)]];
		else
			checkFor = [[NSString alloc] initWithString:[str substringWithRange:NSMakeRange(i, i + (searchLen - 1))]];
		NSLog(@"SearchLen = %d; TotalLen = %d; checkFor = %@; i = %d", searchLen, totalLen, checkFor, i);
		if ([checkFor isEqual:searching])
			return YES;
	}
	NSLog(@"Went up to %d", i);
	return NO;
}
- (NSString *)tipsForPassword:(NSString *)passwd {
	NSString *passwdBack = [[NSString alloc] initWithString:passwd];
	NSString *hintString = [[NSString alloc] init];
	if ([weekPasswords containsObject:[passwd lowercaseString]])
		hintString = [hintString stringByAppendingString:@"Password is commonly used.\n"];
	if ([self checkForChar:@" " inString:passwdBack])
		hintString = [hintString stringByAppendingString:@"Password has a space in it.  It may not be used on some sites.\n"];
	if ([self checkForChar:@"=" inString:passwdBack])
		hintString = [hintString stringByAppendingString:@"Password has an = in it.  It may not be used on some sites.\n"];
	if ([self checkForChar:@"&" inString:passwdBack])
		hintString = [hintString stringByAppendingString:@"Password has an & in it.  It may not be used on some sites.\n"];
	if ([self checkForChar:@"?" inString:passwdBack])
		hintString = [hintString stringByAppendingString:@"Password has a ? in it.  It may not be used on some sites.\n"];
	if ([self checkForChar:@"%" inString:passwdBack])
		hintString = [hintString stringByAppendingString:@"Password has a % in it.  It may not be used on some sites.\n"];
	if ([self checkForChar:@"@" inString:passwdBack])
		hintString = [hintString stringByAppendingString:@"Password has an @ in it.  It may not be used on some sites.\n"];
	if ([passwd length] <= 7)
		hintString = [hintString stringByAppendingString:@"Password should be longer.\n"];
	if ([passwd length] <= 5)
		hintString = [hintString stringByAppendingString:@"Password is to short.\n"];
	if ([passwd length] > 31)
		hintString = [hintString stringByAppendingString:@"Most websites/services will not accept this long of a password.\n"];
	if ([hintString isEqual:@""])
		return @"No tips";
	else
		return hintString;
}
- (void)passwordChanged {
	NSString * genPass = [[NSString alloc] initWithString:[passwordGenerated stringValue]];
	int i = 0;
	int len = [genPass length];
	int strength = 0;
	for (i = 0; i < len; i++) {
		strength = strength + [self amountOfPointsOfChar:((char)[genPass characterAtIndex:i])];
		if (strength >= 100)
			break;
	}
	if ([weekPasswords containsObject:[genPass lowercaseString]]) {
		strength = 11;
	}
	NSString * tips = [[self tipsForPassword:[passwordGenerated stringValue]] retain];
	[generateTips setString:[tips retain]];
	NSString * strengthText = [[NSString alloc] init];
	strengthText = @"Strength: Terrible";
	[passwordStrength setIntValue:0];
	if (strength > 10 && strength < 21) {
		[passwordStrength setIntValue:1];
		strengthText = @"Strength: Poor";
	}
	if (strength > 20 && strength < 41) {
		[passwordStrength setIntValue:2];
		strengthText = @"Strength: OK";
	}
	if (strength > 40 && strength < 61) {
		[passwordStrength setIntValue:3];
		strengthText = @"Strength: Good";
	}
	if (strength > 60 && strength < 81) {
		[passwordStrength setIntValue:4];
		strengthText = @"Strength: Great";
	}
	if (strength > 80) {
		[passwordStrength setIntValue:5];
		strengthText = @"Strength: Wonderful";
	}
	[passwordStrengthText setStringValue:strengthText];
	[passwordDigits setIntValue:[[passwordGenerated stringValue] length]];
}
- (IBAction)generatePassword:(id)sender {
	int i = 0;
	int mallocLen = [generateLength intValue];
	NSString * generated = [[NSString alloc] initWithString:@""];
	char chars[200];
	sprintf(chars, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890%{}[]()");
	for (i = 0; i < mallocLen; i++) {
		NSLog(@"%d < %d", i, mallocLen);
		int index = (arc4random() % 69);
		generated = [generated stringByAppendingFormat:@"%c", chars[index]];
	}
	[passwordGenerated setStringValue:[generated retain]];
	[self passwordChanged];
}
- (IBAction)changeLevel:(id)sender {
	if ([(NSLevelIndicator*)sender intValue] == 0) {
		[generateButton setEnabled:NO];
	} else {
		[generateButton setEnabled:YES];
	}
}
@end
