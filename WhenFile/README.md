WhenFile
========

Use this app to set the modified and creation time of a file.

How it works
------------

Basic date/time changing on a file can be done like so (in code):

    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    [dict setObject:[created dateValue] forKey:NSFileCreationDate];
    [dict setObject:[modified dateValue] forKey:NSFileModificationDate];
    NSError * e = nil;
    if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:self.currentPath error:&e]) {
        NSLog(@"Error.");
    }

The app itself is very easy to use, and uses the built-in
NSDatePicker class. It also uses QTMovie to change the
meta-data date stored in video files.

