
#import "SWMeteor.h"
#import "SpaxeWars.h"
#import "ActorMgr.h"
#import "SoundMgr.h"

@implementation SWMeteor

static int wobble;

- activate:sender :(int)tag
{
	NXSize tsize = {37,35};
	NXSize t2 = {18,18};

	wobble = (++wobble) & 1;

	[super activate:sender :tag];

	[self reinitWithImage:"swmeteor"
		frameSize:&tsize
		numFrames:1
		shape: CIRCLE
		alliance: DESTROYALL
		radius: 18
		buffered: YES
		x: randBetween(wobble?xOffset:-xOffset,xOffset+2)
		y: randBetween(wobble?-yOffset:yOffset,yOffset+2)
		theta: randBetween(0,2*PI)
		vel: randBetween(5,10)
		interval: 1000000
		distToCorner: &t2];

	[self wrapAtDistance: (xOffset+1) :(yOffset+1)];
	[self bounceAtDistance: (xOffset) :(yOffset)];

	hits = 0;

	return self;
}

- killAndReplace
{
	Actor *dude = (Actor *)[actorMgr newActor:xx_explosion for:self tag:1];
	[dude setXvYv:xv :yv sync:NO];
	[soundMgr playSound: EXP1SND at:0.5];
	[actorMgr destroyActor:self];
	[actorMgr newActor:(int)[self class] for:self tag:1];
	return self;
}
- positionChanged
{
	if ((x < 10) && (x > -10) && (y < 10) && (y > -10))
	{
		[self killAndReplace];
		return self;
	}

	if (sw_bounce)
		[self bounceAtDistance: (xOffset) :(yOffset)];
	else
		[self wrapAtDistance: (xOffset+10) :(yOffset+10)];
	[super positionChanged];
	return self;
}

#define MAXV 30
- calcDxDy:(NXPoint *)dp
{
	x *=2; y*=2;
	if (sw_gravity) [self swApplyGravity];
	x/=2; y/=2;

	if (xv > MAXV) xv = MAXV;
	else if (xv < -MAXV) xv = -MAXV;
	if (yv > MAXV) yv = MAXV;
	else if (yv < -MAXV) yv = -MAXV;

	return [super calcDxDy:(NXPoint *)dp];
}

- performCollisionWith:(Actor *) dude
{
	if (++hits < 5) return self;

	[self killAndReplace];
	return nil;
}

- (BOOL) doYouHurt:sender
{
	Actor *dude = (Actor *)sender;
	if (dude->actorType == xx_swbullet)
	{
		xv += dude->xv * .12;
		yv += dude->yv * .12;
	}

	return YES;
}

@end
