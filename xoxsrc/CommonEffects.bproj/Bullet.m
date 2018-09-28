
#import "Bullet.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "DisplayManager.h"
#import "Xoxeroids.h"

@implementation Bullet

static int lastBulletSound;

- activate:sender :(int)tag
{
	NSSize tsize = {3,2};
	NSSize t2 = {1.5, 1.0};
	Actor *dude = (Actor *)sender;
	float xfactor = -sin(dude->theta), yfactor = cos(dude->theta);

	[super activate:sender :tag];

	speed = (tag & BUL_SLOW) ? 22: 24;

	[self reinitWithImage:"bullets1"
		frameSize:&tsize
		numFrames:8
		shape: RECTCIRC
		alliance: dude->alliance
		radius: 1.5
		buffered: NO
		x: dude->x + dude->radius * xfactor
		y: dude->y + dude->radius * yfactor
		theta: dude->theta
		vel: dude->vel + speed
		interval: 80
		distToCorner: &t2];

	xv = dude->xv + xfactor * speed;
	yv = dude->yv + yfactor * speed;

	expireTime = timeInMS + 2200;

	if (timeInMS > (lastBulletSound + 125))
	{
		lastBulletSound = timeInMS + (timeInMS & 0xf);
		[soundMgr playSound: BULLET1SND at:0.5];
	}

	[self setBulletImage:tag];

	return self;
}

- setBulletImage:(int)tag
{
	switch (tag & BUL_CORN)
	{
		case BUL_SPIN:
			min_frame = 0;
			max_frame = 3;
			break;
		case BUL_PLUS:
			interval = 3000;
			min_frame = max_frame = 4;
			break;
		case BUL_RECT:
			interval = 3000;
			min_frame = max_frame = 5;
			break;
		case BUL_CORN:
			interval = 120;
			min_frame = 6;
			max_frame = 7;
			break;
	}

	if (!(tag & BUL_IMAGE)) min_frame = -1;

	return self;
}

- positionChanged
{
	if ((min_frame >= 0) && (timeInMS > changeTime))
	{
		changeTime = timeInMS + interval;
		if (++frame > max_frame) frame = min_frame;
	}
	return self;
}

- calcDxDy:(NSPoint *)dp
{
	if (timeInMS > expireTime)
		[actorMgr destroyActor:self];

	dp->x = timeScale * xv;
	dp->y = timeScale * yv;

	return self;
}

// the default behavior composites, but the drawrect routine is faster.
- draw
{
	if (min_frame >= 0) return [super draw];

	drawRect.size = frameSize;
	[displayMgr drawWhiteRect:&drawRect];
	eraseRect = drawRect;

	return self;
}

@end
