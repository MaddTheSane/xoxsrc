
#import "MineFragment.h"
#import "SoundMgr.h"
#import "ActorMgr.h"
#import "Xoxeroids.h"
#import "Thinker.h"

@implementation MineFragment

static int lastMineFragSound;

+ initialize
{
	[super initialize];
	[[NSApp delegate] addImageResource:"mineFrag" for: self];
	return self;
}

- activate:sender :(int)tag
{
	NSSize tsize = {25,25};
	NSSize tsize2 = {12.5,12.5};
	Actor *dude = (Actor *)sender;
	float xfactor = -sin(dude->theta), yfactor = cos(dude->theta);
	float speed;

	[super activate:sender :tag];

	speed = randBetween(12.5,15.5);

	[self reinitWithImage:"mineFrag"
		frameSize:&tsize
		numFrames:6
		shape: CIRCLE
		alliance: XoXDestroyAll
		radius: tsize2.width
		buffered: NO
		x: dude->x
		y: dude->y
		theta: dude->theta
		vel: dude->vel
		interval: 50
		distToCorner: &tsize2];

	xv = xfactor * speed;
	yv = yfactor * speed;
	frame = (tag & 0xffff)%6;
	generation = tag>>16;

	expireTime = timeInMS + (int)(randBetween(1550,1850));
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

- performCollisionWith:(Actor *) dude
{
	int i;
	float t_theta;

	if (timeInMS > (lastMineFragSound + 80))
	{
		lastMineFragSound = timeInMS + (timeInMS & 0xf);
		[soundMgr playSound: EXP3SND at:0.5];
	}
//	[actorMgr newActor:xx_explosion for:self tag:1];

	if (dude->actorType == xx_bullet && generation < 2)
	{
		t_theta = theta;
		for (i=-1; i<=1; i+=2)
		{
			theta = t_theta + i * randBetween(4.0*PI/180.,10.0*PI/180.);
			[actorMgr newActor:xx_minefragment for:self 
				tag:((generation+1)<<16) | frame];
		}
	}
	return [super performCollisionWith: dude];
}

@end
