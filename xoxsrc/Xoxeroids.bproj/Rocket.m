
#import "Rocket.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Explosion.h"
#import "Xoxeroids.h"
#import "Thinker.h"

@implementation Rocket

- activate:sender :(int)tag
{
	NXSize tsize = {42,42};
	NXSize tsize2 = {21,21};
	Actor *dude = (Actor *)sender;
	float ttheta = (135. * (PI/180.) * (tag%8));

	[super activate:sender :tag];

	[self reinitWithImage:"rocket1"
		frameSize:&tsize
		numFrames:24
//		shape: LINEARRAY
		shape: RECTCIRC
		alliance: EVIL
		radius: 21
		buffered: YES
		x: dude->x - (sin(ttheta) * (dude->radius + 10))
		y: dude->y + cos(ttheta) * (dude->radius + 10)
		theta: ttheta
		vel: randBetween(10,16)
		interval: 50
		distToCorner: &tsize2];

	hits = 0;
	turnRate = randBetween(0.8,1.2) * PI/30.0;
	wobbleRate = randBetween(0.8,1.2) * (2.0*PI) / 10.0;
	thrustState = timeInMS;
	chicken = tag & 1;
	pointValue = 100;
	return self;
}

+ initialize
{
	[super initialize];
	[[NXApp delegate] addImageResource:"rocket1" for: self];
	[[NXApp delegate] addImageResource:"rocket2" for: self];
	return self;
}

- init
{
	[super init];
	r1 = [self findImageNamed:"rocket1"];
	r2 = [self findImageNamed:"rocket2"];
	return self;
}

- calcDxDy:(NXPoint *)dp
{
	if (timeInMS >= moveChangeTime)
	{
		float aimX, aimY, desiredAngle, desiredChange;
		float dx,dy, dist;
		moveChangeTime = timeInMS + 100;
		dx = gx-x; dy=gy-y;
		dist = sqrt(dx*dx+dy*dy);

		wobble += wobbleRate;
		aimX = gx + .75 * dist * sin(wobble);
		aimY = gy - .75 * dist * cos(wobble);
//		desiredAngle = atan2(x - aimX, aimY - y);
		desiredAngle = atan2(aimX - x, y - aimY);
		desiredChange = theta - desiredAngle;
		if (desiredChange < PI) desiredChange += 2.0 * PI;
		if (desiredChange >= PI) desiredChange -= 2.0 * PI;

		if (desiredChange < PI) desiredChange += 2.0 * PI;
		if (desiredChange >= PI) desiredChange -= 2.0 * PI;

		if (desiredChange < -turnRate) desiredChange = -turnRate;
		if (desiredChange > turnRate) desiredChange = turnRate;

		theta += desiredChange;
		xv = vel * -sin(theta);
		yv = vel * cos(theta);
	}
	[super calcDxDy:dp];
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

	while (theta < 0) theta += (2*PI);
	while (theta >= (2*PI)) theta -= (2*PI);

	t_theta = theta + (7.5 * PI / 180.0);
	if (t_theta >= 2.0*PI) t_theta -= 2.0*PI;
	frame = (t_theta/(15.0 * PI / 180.0));

	[self wrapAtDistance: (3*xOffset) :(3*yOffset)];

	return self;
}

- performCollisionWith:(Actor *) dude
{
	id ret = self;
	if (++hits >= 4)
	{
		[soundMgr playSound: (EXP2SND) at:0.5];
		[actorMgr newActor:xx_explosion for:self tag:1];
		ret = [super performCollisionWith: dude];
	}
	else
	{
		theta = atan2(dude->xv, -dude->yv);
		if (chicken) theta += PI;
		moveChangeTime = timeInMS;
		[soundMgr playSound: FUTILITYSND at:0.5];
	}

	return ret;
}

@end
