
#import <appkit/appkit.h>
#import "xoxDefs.h"

#import "Actor.h"

#define NSTARS2 (200)
#define STARSPERIT (100)

typedef struct {
	float theta;	// angle
	float distance;
	float delta;	// change in distance
	float ddelta;	// change in delta, a constant multiplier
	int changemode;
	float changepoint[6];
	
	NXRect draw;
	NXRect erase;
	
	} SSTAR;

@interface SpaceSpinGen:Actor
{
	SSTAR stars[NSTARS2];
	int nstars;
	int zradius;			// min radius of this view

	NXRect b[NSTARS2];
	NXRect w[NSTARS2];

	NXSize mySize;
	unsigned expireTime;
	float cumuTimeStamp;
}

- convertToXY:(SSTAR *)p;
- oneStep;
- addStar;
- replaceStarAt:(int)index;

@end
