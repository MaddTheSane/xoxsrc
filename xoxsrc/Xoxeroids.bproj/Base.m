
#import "Base.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Explosion.h"
#import "Xoxeroids.h"

@implementation Base

#define MISSILEINTERVAL 10000

- activate:sender :(int)tag
{
	NSSize tsize = {50,50};
	NSSize tsize2 = {25,25};

	[super activate:sender :tag];

	[self reinitWithImage:"base"
		frameSize:&tsize
		numFrames:4
		shape: CIRCLE
		alliance: EVIL
		radius: 15
		buffered: YES
		x: randBetween(gx+xOffset/2, gx+5.5*xOffset)
		y: randBetween(gy+yOffset/2, gy+5.5*yOffset)
		theta: randBetween(0,2*PI)
		vel: randBetween(5,8)
		interval: 50
		distToCorner: &tsize2];

	hits = 0;
	fireTime2 = timeInMS + MISSILEINTERVAL;
	pointValue = 150;
	return self;
}

- positionChanged
{
	float dx, dy, dist2;
	[super positionChanged];
	[self wrapAtDistance: (3*xOffset) :(3*yOffset)];

	dx = x - gx;
	dy = y - gy;
	dist2 =(dx*dx + dy*dy);

	if ((dist2 < (xOffset * xOffset)) && (timeInMS > lastFireTime + 850))
	{
		[self fire];
	}
	if ((timeInMS >= fireTime2) && 
			([actorMgr gameStatus] != XoXGameDying))
	{
		[self fire2];
	}
	return self;
}

- performCollisionWith:(Actor *) dude
{
	id ret = self;
	if (++hits >= 3)
	{
		[soundMgr playSound: (EXP1SND) at:0.5];
		[actorMgr newActor:xx_explosion for:self tag:0];
		ret = [super performCollisionWith: dude];
	}
	else
	{
		[soundMgr playSound: EEOOSND at:0.5];
	}

	return ret;
}

- fire
{
	static int warble = 0;
	warble += 30;
	if (warble > 100) warble -= 100;
	lastFireTime = timeInMS + warble;

	[actorMgr newActor:xx_eye for:self tag: 0];
	return self;
}

extern int rocketCount;

- fire2
{
	fireTime2 = timeInMS + MISSILEINTERVAL;
	if (rocketCount < 18)
		[actorMgr newActor:xx_rocket for:self tag: timeInMS];
	return self;
}

@end







