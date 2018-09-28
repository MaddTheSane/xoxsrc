
#import "Mine.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Explosion.h"
#import "Xoxeroids.h"
#import "XXShip.h"
#import "Thinker.h"

@implementation Mine

+ initialize
{
	[super initialize];
	[[NSApp delegate] addImageResource:"bigMineArray" for: self];
	[[NSApp delegate] addImageResource:"bigMineArray2" for: self];
	return self;
}

- activate:sender :(int)tag
{
	NSSize tsize = {48,48};
	NSSize tsize2 = {24,24};

	[super activate:sender :tag];

	[self reinitWithImage:"bigMineArray"
		frameSize:&tsize
		numFrames:10
		shape: CIRCLE
		alliance: EVIL
		radius: tsize2.width
		buffered: YES
		x: randBetween(gx+xOffset/2, gx+5.5*xOffset)
		y: randBetween(gy+yOffset/2, gy+5.5*yOffset)
		theta: randBetween(0,2*PI)
		vel: randBetween(0,3)
		interval: randBetween(750,1150)
		distToCorner: &tsize2];

	frame = (int) randBetween(0,9.95);
	frameDir = (frame & 1) ? -1 : 1;

	badMine = image;
	goodMine = [self findImageNamed:"bigMineArray2"];

	mineState = tag & 1;
	if (mineState) image = goodMine;
	else image = badMine;

	pointValue = 75;
	return self;
}

- positionChanged
{
	if (timeInMS > changeTime)
	{
		changeTime = timeInMS + interval;
		frame += frameDir;
		if (frame >= numFrames) frame = 0;
		else if (frame < 0) frame = numFrames - 1;
	}
	[self wrapAtDistance: (3*xOffset) :(3*yOffset)];
	return self;
}

- performCollisionWith:(Actor *) dude
{
	float t_theta;
	int i;

	if ((frame != 0) || (dude->actorType != (int)[XXShip class]))
	{
		[soundMgr playSound: (EXP1SND) at:0.5];

		[actorMgr newActor:xx_explosion for:self tag:mineState];

		t_theta = theta;
		for (i=0; i<8; i++)
		{
			t_theta += (45. * PI/180.0);
			theta = t_theta + randBetween(-6.*PI/180.,6.*PI/180.);
			[actorMgr newActor:xx_minefragment for:self tag:(i*3)];	
		}
	}
	else
		[actorMgr newActor:xx_explosion for:self tag:1];

	return [super performCollisionWith: dude];
}

- (int) mineType
{
	return mineState;
}

@end
