
#import <appkit/appkit.h>

#import "Actor.h"

@interface Cannon:Actor
{
	int hits;
	int currentCannon;
	unsigned lastFireTime;
	unsigned moveChangeTime;
	unsigned panicTime;
	int frameDir;
}

- fire;

@end
