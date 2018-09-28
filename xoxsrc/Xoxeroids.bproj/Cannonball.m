
#import "Cannonball.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Explosion.h"
#import "Xoxeroids.h"

@implementation Cannonball

- activate:sender :(int)tag
{
	NXSize tsize = {30,30};
	NXSize tsize2 = {15,15};
	Actor *dude = (Actor *)sender;
	float ttheta = (90. * (PI/180.) * (tag%4));

	[super activate:sender :tag];

	[self reinitWithImage:"cannonball1"
		frameSize:&tsize
		numFrames:5
		shape: CIRCLE
		alliance: EVIL
		radius: 15
		buffered: YES
		x: dude->x - (sin(ttheta) * (dude->radius + 10))
		y: dude->y + cos(ttheta) * (dude->radius + 10)
		theta: ttheta
		vel: randBetween(9,13)
		interval: 70
		distToCorner: &tsize2];

	hits = 0;
	pointValue = 70;
	return self;
}

- calcDxDy:(NXPoint *)dp
{
	if (timeInMS > moveChangeTime)
	{
		float dx, dy, dist, dxv, dyv;
		moveChangeTime = timeInMS + 300;
		dx = gx-x; dy=gy-y;
		dist = sqrt(dx*dx+dy*dy);
		dxv = vel * dx/dist;
		dyv = vel * dy/dist;
		if (dxv < xv) xv-=1;
		else if (dxv > xv) xv+=1;
		if (dyv < yv) yv-=1;
		else if (dyv > yv) yv+=1;
	}
	[super calcDxDy:dp];
	return self;
}

- positionChanged
{
	[super positionChanged];
	[self wrapAtDistance: (3*xOffset) :(3*yOffset)];
	return self;
}

- performCollisionWith:(Actor *) dude
{
	id ret = self;
	if (++hits >=2)
	{
		[soundMgr playSound: (EXP2SND) at:0.5];
		[actorMgr newActor:xx_explosion for:self tag:1];
		ret = [super performCollisionWith: dude];
	}
	else
	{
		[soundMgr playSound: FUTILITYSND at:0.5];
	}

	return ret;
}

@end
