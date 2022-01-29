
#import "SWShip.h"
#import "Bullet.h"
#import "SpaxeWars.h"
#import "ActorMgr.h"
#import "Thinker.h"
#import <math.h>
#import <tgmath.h>

#define ROT_SPEED (37.0)
#define ACCEL (3.0)
#define MAXV (45)

@implementation Actor(spaxeWarsAdditions)

- swApplyGravity
{
    double dist = sqrt((x*x) + (y*y));
    xv += timeScale * (x / (dist * dist * dist)) * sw_gravity;
    yv += timeScale * (y / (dist * dist * dist)) * sw_gravity;
	return self;
}
@end

@implementation SWShip

- activate:sender :(int)tag
{
	NSSize t20 = {36,36};
	NSSize t10 = {18,18};
	int oldFrame = frame;

	[super activate:sender :tag];
	[self reinitWithImage: (tag == GOOD ? "dart0" : "claw0")
		frameSize:&t20
		numFrames:24
		shape: CIRCLE
		alliance: tag
		radius: 15.0
		buffered: YES
		x: (tag == GOOD ? -0.666*xOffset : 0.666*xOffset)
		y: 0.0
		theta: (tag == GOOD ? PI/2 : -PI/2)
		vel: 0.0
		interval: 50
		distToCorner: &t10];

	noflame = image;
	frame = oldFrame;
	[self setThrusting:NO time:0];
	xv = gx = gy = 0;
	yv = (tag == GOOD ? -8 : 8);
	flame1 = [self findImageNamed:(tag == GOOD ? "dart1" : "claw1")];
	flame2 = [self findImageNamed:(tag == GOOD ? "dart2" : "claw2")];
	return self;
}

+ initialize
{
	[super initialize];
	[[NSApp delegate] addImageResource:"dart1" for: self];
	[[NSApp delegate] addImageResource:"dart2" for: self];
	[[NSApp delegate] addImageResource:"claw1" for: self];
	[[NSApp delegate] addImageResource:"claw2" for: self];
	return self;
}

- _flameOn
{
	image = flame1;
	return self;
}

- _flameOff
{
	image = noflame;
	return self;
}

- tweakGxGy
{
	return self;
}

- fire
{
	if ((!employed) || shields || didFire) return self;

	if ([scenario bullets:alliance] < 5)
	{
		[actorMgr newActor:xx_swbullet for:self tag:0];
	}
	return self;
}

- positionChanged
{
	if (sw_bounce)
		[self bounceAtDistance: (xOffset) :(yOffset)];
	else
		[self wrapAtDistance: (xOffset+10) :(yOffset+10)];
	[super positionChanged];
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

	if (sw_gravity) [self swApplyGravity];

	if (xv > MAXV) xv = MAXV;
	else if (xv < -MAXV) xv = -MAXV;
	if (yv > MAXV) yv = MAXV;
	else if (yv < -MAXV) yv = -MAXV;

	dp->x = timeScale * xv;
	dp->y = timeScale * yv;

	didFire = NO;

	return self;
}

@end
