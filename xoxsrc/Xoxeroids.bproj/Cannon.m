
#import "Cannon.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Explosion.h"
#import "Xoxeroids.h"

@implementation Cannon

- activate:sender :(int)tag
{
	NSSize tsize = {48,48};
	NSSize tsize2 = {24,24};

	[super activate:sender :tag];

	[self reinitWithImage:"cannon1"
		frameSize:&tsize
		numFrames:4
		shape: CIRCLE
		alliance: EVIL
		radius: tsize2.width
		buffered: YES
		x: randBetween(gx+xOffset/2, gx+5.5*xOffset)
		y: randBetween(gy+yOffset/2, gy+5.5*yOffset)
		theta: randBetween(0,2*PI)
		vel: randBetween(1,4)
		interval: 100
		distToCorner: &tsize2];

	hits = 0;
	frameDir = 1;
	pointValue = 125;
	return self;
}

- positionChanged
{
	if (timeInMS > changeTime)
	{
		changeTime = timeInMS + interval;
		frame += frameDir;
		if (frame >= numFrames-1) frameDir = -1;
		else if (frame <= 0) frameDir = 1;
	}
	[self wrapAtDistance: (3*xOffset) :(3*yOffset)];
	return self;
}

- calcDxDy:(NSPoint *)dp
{
	if (timeInMS > moveChangeTime)
	{
		float dx, dy, dist;
		moveChangeTime = timeInMS + 1000;
		dx = gx-x; dy=gy-y;
		dist = sqrt(dx*dx+dy*dy);
		xv = vel * dx/dist;
		yv = vel * dy/dist;
	}
	[super calcDxDy:dp];
	return self;
}

- performCollisionWith:(Actor *) dude
{
	id ret = self;
	if (++hits >= 6)
	{
		[soundMgr playSound: (EXP3SND) at:0.5];
		[actorMgr newActor:xx_explosion for:self tag:0];
		ret = [super performCollisionWith: dude];
	}
	else
	{
		[soundMgr playSound: FUTILITYSND at:0.5];
		if ((timeInMS < panicTime) || !((hits-1)%3))
			[self fire];
	}

	panicTime = timeInMS+220;
	return ret;
}

- fire
{
	lastFireTime = timeInMS;
	[actorMgr newActor:xx_cannonball for:self tag: ++currentCannon];
	return self;
}

@end







