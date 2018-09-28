
#import <appkit/appkit.h>

#import "Actor.h"

@interface Rocket:Actor
{
	int hits;
	unsigned moveChangeTime;
	float wobble;
	id r1,r2;
	short thrustState;
	float turnRate;
	float wobbleRate;
	BOOL chicken;
}


@end
