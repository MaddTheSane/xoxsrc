
#import "RocketMatrix.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Explosion.h"
#import "Xoxeroids.h"
#import "Rocket.h"

@interface DumbRocket:Rocket
{
	int maxHits;
}
@end

@implementation DumbRocket
- activate:sender :(int)tag
{
	NXSize tsize = {42,42};
	NXSize tsize2 = {21,21};
	Actor *dude = (Actor *)sender;

	employed = YES;

	[self reinitWithImage:"rocket1"
		frameSize:&tsize
		numFrames:24
		shape: RECTCIRC
		alliance: EVIL
		radius: 21
		buffered: YES
		x: dude->x
		y: dude->y
		theta: dude->theta
		vel: dude->vel
		interval: 50
		distToCorner: &tsize2];

	hits = 0;
	maxHits = randBetween(3,6);
	thrustState = maxHits;
	return self;
}

- positionChanged
{
	float t_theta;
	if (timeInMS > changeTime)
	{
		changeTime = timeInMS + interval;
		if (++thrustState & 1) image = r1;
		else image = r2;
	}

	t_theta = theta + (7.5 * PI / 180.0);
	if (t_theta >= 2.0*PI) t_theta -= 2.0*PI;
	frame = (t_theta/(15.0 * PI / 180.0));

	return self;
}

- performCollisionWith:(Actor *) dude
{
	id ret = self;
	if (++hits >= maxHits)
	{
		[soundMgr playSound: (EXP2SND) at:0.5];
		[actorMgr newActor:xx_explosion for:self tag:1];
		ret = [super performCollisionWith: dude];
	}
	else
	{
//		[soundMgr playSound: FUTILITYSND at:0.5];
	}

	return ret;
}
@end

@implementation RocketMatrix

- activate:sender :(int)tag
{
	MatrixData md;

	md.autofill = YES;
	md.whichClass = [DumbRocket class];
	md.alliance = EVIL;
	md.x = randBetween(xOffset,5*xOffset);
	md.y = randBetween(yOffset,5*yOffset);
	md.theta = randBetween(0,2*PI);
	md.vel = randBetween(7,12);
	md.rows = randBetween(4,6.9);
	md.columns = 4;
	md.xgap = randBetween(20,50);
	md.ygap = randBetween(20,50);
	md.actWidth = 42;
	md.actHeight = 42;
	md.interval = 200;
	md.modifyThetas = YES;

	[super activate:self :(int)&md];
	return self;
}

- positionChanged
{
	[self wrapAtDistance: (3*xOffset) :(3*yOffset)];
	while (theta < 0) theta += (2*PI);
	while (theta >= (2*PI)) theta -= (2*PI);
	return self;
}

- calcDxDy:(NXPoint *)dp
{
	if (timeInMS > changeTime)
	{
		changeTime = timeInMS + interval;
		theta += randBetween(-PI/10.0,PI/10.0);
		xv = vel * -sin(theta);
		yv = vel * cos(theta);
	}
	[super calcDxDy:dp];
	return self;
}
