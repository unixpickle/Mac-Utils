/*
 *  Debugging.h
 *  miRSS
 *
 *  Created by Alex Nichol on 12/13/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

// #define _NO_DEBUG_NSLOG 0

#ifndef _SETLOG
#define _SETLOG 1

#define uselessLogFunction func1929384373

static void uselessLogFunction (void * ptr, ...) {
	// useless log function
}

#endif

// define _NO_DEBUG_NSLOG
// to disable NSLogging
#ifdef _NO_DEBUG_NSLOG

#define NSLog uselessLogFunction

#endif