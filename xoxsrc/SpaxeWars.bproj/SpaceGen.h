
#import <AppKit/AppKit.h>
#import "xoxDefs.h"

#import "Actor.h"

#define NSTARS (40)

typedef struct {
	float distance;		// a factor for parallax scrolling
	NSRect position;	// where it is
	NSRect display;		// where it displays
	} STAR;

@interface SpaceGen:Actor
{
	STAR stars[NSTARS];
	NSRect r1[NSTARS];
	NSRect r2[NSTARS];
	NSRect *b;
	NSRect *w;
	float oldX, oldY;
	NSSize mySize;
}


@end
