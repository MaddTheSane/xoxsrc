
#import "XXShip.h"
#import "Mine.h"
#import "ActorMgr.h"

@implementation XXShip

- performCollisionWith:(Actor *) dude
{
	id ret = self;

	if ((dude->actorType == (int)[Mine class]) && dude->frame == 0) 
	{
		if (!shields)
		{
			[self addToScore:500 for:self gen:0];
			if ([(Mine *)dude mineType] == 1)
			{
				bigGuns = YES;
			}
			else
			{
				shieldStrength += 35;
				if (shieldStrength > 100) shieldStrength = 100;
			}
		}
	}
	else
	{
		ret = [super performCollisionWith: dude];
	}
	return ret;
}

@end
