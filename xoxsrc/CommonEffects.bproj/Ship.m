
#import "Ship.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Bullet.h"
#import "Xoxeroids.h"
#import "Thinker.h"

#define ROT_SPEED (37.0)
#define ACCEL (3.0)
#define MAXV (70)

extern float gx, gy;

@implementation Ship

- activate:sender :(int)tag
{
	NSSize t20 = {20,20};
	NSSize t10 = {10,10};
	int oldFrame = frame;

	[super activate:sender :tag];
	[self reinitWithImage:"ship"
		frameSize:&t20
		numFrames:24
		shape: RECTCIRC
		alliance: GOOD
		radius: 10.0
		buffered: YES
		x: 0.0
		y: 0.0
		theta: theta
		vel: 0.0
		interval: 50
		distToCorner: &t10];

	noflame = image;
	frame = oldFrame;
	[self setThrusting:NO time:0];
	xv = yv = gx = gy = 0;
	shieldStrength = 100;
	shields = NULL;
	return self;
}

+ initialize
{
	[super initialize];
	[[NSApp delegate] addImageResource:"ship" for: [Ship class]];
	[[NSApp delegate] addImageResource:"flame1" for: [Ship class]];
	[[NSApp delegate] addImageResource:"flame2" for: [Ship class]];

	return self;
}

- init
{
	[super init];

	flame1 = [self findImageNamed:"flame1"];
	flame2 = [self findImageNamed:"flame2"];
	theta = 0.0;

	thrustVal = [[KeyTimer allocFromZone:[self zone]] init];
	leftVal = [[KeyTimer allocFromZone:[self zone]] init];
	rightVal = [[KeyTimer allocFromZone:[self zone]] init];
	[leftVal setDelegate:rightVal];
	[rightVal setDelegate:leftVal];

	return self;
}

- free
{
	[thrustVal free];
	[leftVal free];
	[rightVal free];
	return [super free];
}

- _flameOn
{
	NSSize t30 = {30,30};
	NSSize t15 = {15,15};
	frameSize = t30;
	distToCorner = t15;
	image = flame1;
	return self;
}

- _flameOff
{
	NSSize t20 = {20,20};
	NSSize t10 = {10,10};
	frameSize = t20;
	distToCorner = t10;
	image = noflame;
	return self;
}

- setThrusting:(BOOL)val time:(long)time
{
	thrusting = val;
	if (thrusting)
	{
		changeTime = timeInMS + interval;
		[self _flameOn];
		[thrustVal keyDownAt:time];
	}
	else
	{
		[self _flameOff];
		if (time) [thrustVal keyUpAt:time];
	}

    return self;
}

- setTurning:(ROTATION)dir down:(BOOL)keyDn time:(long)time
{
	if (dir == LEFT)
	{
		if (keyDn) [leftVal keyDownAt:time];
		else [leftVal keyUpAt:time];
	}
	else if (dir == RIGHT)
	{
		if (keyDn) [rightVal keyDownAt:time];
		else [rightVal keyUpAt:time];
	}
	return self;
}

- tweakGxGy
{
	gx = x;
	gy = y;
	return self;
}

- positionChanged
{
	float t_theta, rotVal;

	[self tweakGxGy];
	[self calcDrawRect];

	if (thrusting && (timeInMS > changeTime))
	{
		changeTime = timeInMS + interval;
		if (++thrustState & 1) image = flame1;
		else image = flame2;
	}

	if (shields && (timeInMS > shieldTime))
	{
			shieldStrength -= 3.125;
			if (shieldStrength < 0) shieldStrength = 0;
			shieldTime = timeInMS + 650;
	}

	rotVal = [leftVal val] - [rightVal val];
	if (rotVal != 0) theta += rotVal * (ROT_SPEED * PI / 180.0);
	while (theta < 0) theta += (2*PI);
	while (theta >= (2*PI)) theta -= (2*PI);

	t_theta = theta + (7.5 * PI / 180.0);
	if (t_theta >= 2.0*PI) t_theta -= 2.0*PI;
	frame = (t_theta/(15.0 * PI / 180.0));

	return self;
}

- calcDxDy:(NSPoint *)dp
{
	float thrust = [thrustVal val];
	if (thrust > 0)
	{
		xv += thrust * ACCEL * -sin(theta);
		yv += thrust * ACCEL * cos(theta);
	}

	if (xv > MAXV) xv = MAXV;
	else if (xv < -MAXV) xv = -MAXV;
	if (yv > MAXV) yv = MAXV;
	else if (yv < -MAXV) yv = -MAXV;

	dp->x = timeScale * xv;
	dp->y = timeScale * yv;

	didFire = NO;

	return self;
}


- fire
{
	int i;
	float oldTheta = theta;

	if ((!employed) || shields || didFire) return self;

	if (bigGuns)
	{
		theta -= 9.0 * PI/180.0;
		for (i=0; i<3; i++)
		{
			[actorMgr newActor:xx_bullet for:self tag:
				(i != 1) ? (BUL_SLOW|BUL_IMAGE) : 0];
			theta += 9.0 * PI/180.0;
		}

		theta = oldTheta;
	}
	else
	{
 		[actorMgr newActor:xx_bullet for:self tag:BUL_IMAGE];
	}

	didFire = YES;

	return self;
}

- performCollisionWith:(Actor *) dude
{
	int i;
	float t_theta;
	id ret = self;

	if (shields)
		shieldStrength -= 12.5;
	else 
		shieldStrength = -1;

	if (shieldStrength < 0)
	{
		shieldStrength = 0;
		bigGuns = NO;
		// How is he, Bones?

		[soundMgr playSound: SHIPSND at:0.5];
		t_theta = theta;
#define ZXPLOSIONS (7)
		for (i=0; i<ZXPLOSIONS; i++)
		{
			vel = randBetween(1.5,3.1);
			xv = vel * -sin(theta);
			yv = vel * cos(theta);
			t_theta += ((360./ZXPLOSIONS) * PI/180.0);
			theta = t_theta + randBetween(-6.*PI/180.,6.*PI/180.);
			[actorMgr newActor:xx_explosion for:self tag:i&1];
		
		}
		theta = 0.0;
		frame = 0;
		ret = [super performCollisionWith: dude];
	}

	return ret;
}

- setShields:(int)state;
{
	if ((state) && (shieldStrength > 0))
	{
		if (!shields)
		{
			shields = [actorMgr newActor:xx_shield for:self tag:0];
			shieldTime = timeInMS + 650;
		}
	}
	else
	{
		[actorMgr destroyActor:shields];
		shields = NULL;
	}
	return self;
}

- scenarioSelected
{
	[keyTimerList addObject:thrustVal];
	[keyTimerList addObject:leftVal];
	[keyTimerList addObject:rightVal];
	return self; 
}

@end










