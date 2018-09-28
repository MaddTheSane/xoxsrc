
#import <appkit/appkit.h>

#import "Actor.h"

@interface Base:Actor
{
	int hits;
	unsigned lastFireTime;
	unsigned fireTime2;
}

- fire;
- fire2;

@end
