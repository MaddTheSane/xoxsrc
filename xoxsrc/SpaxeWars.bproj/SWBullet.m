
#import "SWBullet.h"
#import "SpaxeWars.h"
#include <tgmath.h>

extern int sw_nastyShots;
extern int sw_bulletMass;

@implementation SWBullet


- activate:sender :(int)tag
{
	NSSize tsize = {8,8};
	NSSize t2 = {4, 4};
	Actor *dude = (Actor *)sender;
	float xfactor = -sin(dude->theta), yfactor = cos(dude->theta);
	float bulletDistance = sw_nastyShots ? 9 : 4;

	[super activate:sender :tag];

	speed = sw_bulletSpeed;

	[self reinitWithImage:(dude->alliance == GOOD ? 
				"spbullet0" : "spbullet1")
		frameSize:&tsize
		numFrames:8
		shape: RECTCIRC
		alliance: sw_nastyShots ? DESTROYALL : dude->alliance
		radius: 2
		buffered: NO
		x: dude->x + (dude->radius + bulletDistance) * xfactor
		y: dude->y + (dude->radius + bulletDistance) * yfactor
		theta: dude->alliance == GOOD ? 0 : PI
		vel: dude->vel + speed
		interval: 80
		distToCorner: &t2];

	xv = dude->xv + xfactor * speed;
	yv = dude->yv + yfactor * speed;

	expireTime = timeInMS + 1900;

	min_frame = 0;
	max_frame = 7;

	return self;
}

- (void)positionChanged
{
	if (sw_bounce)
		[self bounceAtDistance: (xOffset) :(yOffset)];
	else
		[self wrapAtDistance: (xOffset+10) :(yOffset+10)];
	[super positionChanged];
}

#define MAXV 105
- calcDxDy:(NSPoint *)dp
{
	if (sw_gravity && sw_bulletMass) [self swApplyGravity];

	if (xv > MAXV) xv = MAXV;
	else if (xv < -MAXV) xv = -MAXV;
	if (yv > MAXV) yv = MAXV;
	else if (yv < -MAXV) yv = -MAXV;

	return [super calcDxDy:(NSPoint *)dp];
}
@end
