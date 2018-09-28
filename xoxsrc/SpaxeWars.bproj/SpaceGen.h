
#import <appkit/appkit.h>
#import "xoxDefs.h"

#import "Actor.h"

#define NSTARS (40)

typedef struct {
	float distance;		// a factor for parallax scrolling
	NXRect position;	// where it is
	NXRect display;		// where it displays
	} STAR;

@interface SpaceGen:Actor
{
	STAR stars[NSTARS];
	NXRect r1[NSTARS];
	NXRect r2[NSTARS];
	NXRect *b;
	NXRect *w;
	float oldX, oldY;
	NXSize mySize;
}


@end
