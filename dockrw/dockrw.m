#import <Foundation/Foundation.h>
#import "DockItem.h"

void writeHelp (FILE * fp, const char * name) {
	fprintf(fp, "Usage: %s [--option [parameter]]\n\
Options:\n\
--list          lists all dock items and their paths\n\
--add path      adds an application at `path' to the dock\n\
--delete index  removes the application at an index\n\n", name);
	fflush(fp);
}

void restartDock () {
	system("/usr/bin/killall -9 Dock");
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    if (argc < 2) {
		writeHelp(stderr, argv[0]);
		exit(-1);
	}
	
	NSString * path = [NSString stringWithFormat:@"%@/Library/Preferences/com.apple.dock.plist", 
					   NSHomeDirectory()];
	
	NSMutableDictionary * docDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	// read items
	NSMutableArray * items = [[[NSMutableArray alloc] init] autorelease];
	for (NSDictionary * d in [docDictionary objectForKey:@"persistent-apps"]) {
		// create a doc item
		[items addObject:[[[DockItem alloc] initWithDictionary:d] autorelease]];
	}
	
	if (strcmp(argv[1], "--list") == 0) {
		// list everything from the dictionary
		int i = 0;
		for (DockItem * di in items) {
			printf("%d) %s - %s\n", i, [di.label UTF8String], 
				   [di.appPath UTF8String]);
			i++;
		}
	} else if (strcmp(argv[1], "--add") == 0) {
		if (argc != 3) {
			fprintf(stderr, "Invalid usage of --add\n");
			exit(-1);
		}
		// add to the dictionary
		DockItem * di = [[DockItem alloc] initWithPath:[NSString stringWithUTF8String:argv[2]]];
		[items addObject:di];
		NSDictionary * newDictionary = [di itemDictionary];
		if (!newDictionary) {
			fprintf(stderr, "Error adding item!\n");
			exit(1);
		}
		// add to the array
		[[docDictionary objectForKey:@"persistent-apps"] addObject:newDictionary];
		[docDictionary writeToFile:path atomically:YES];
		[di release];
		restartDock();
	} else if (strcmp(argv[1], "--delete") == 0) {
		if (argc != 3) {
			fprintf(stderr, "Invalid usage of --delete\n");
			exit(-1);
		}
		int index = atoi(argv[2]);
		NSMutableArray * papps = [docDictionary objectForKey:@"persistent-apps"];
		if (index < 0 || index >= [papps count]) {
			fprintf(stderr, "Invalid index: %d\n", index);
			exit(1);
		}
		[papps removeObjectAtIndex:index];
		[docDictionary writeToFile:path atomically:YES];
		restartDock();
	} else {
		fprintf(stderr, "Unknown option: %s\n", argv[1]);
		exit(-1);
	}
	
    [pool drain];
    return 0;
}
