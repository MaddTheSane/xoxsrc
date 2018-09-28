
#import "BOBall.h"

@implementation BOBall

- activate:sender :(int)tag
{
	NXSize tsize = {52,52};
	NXSize t2 = {26, 26};

	[super activate:sender :tag];

	[self reinitWithImage:"BOballs"
		frameSize:&tsize
		numFrames:10
		shape: RECTCIRC
		alliance: tag
		radius: 26
		buffered: YES
		x: randBetween(-xOffset, xOffset)
		y: randBetween(-yOffset, yOffset)
		theta: randBetween(0, 2 * PI)
		vel: randBetween(12,35)
		interval: randBetween(10,25)
		distToCorner: &t2];

	return self;
}

- positionChanged
{
	[self bounceAtDistance: (xOffset-distToCorner.width)
			:(yOffset-distToCorner.height)];
	[super positionChanged];
	return self;
}

- performCollisionWith:(Actor *) dude
{
	[self bounceOff:dude];
	// don't go away
	return self;
}

@end

@implementation BOSkull

- activate:sender :(int)tag
{
	NXSize tsize = {48,48};
	NXSize t2 = {24,24};

	[super activate:sender :tag];

	[self reinitWithImage:"BOskulls"
		frameSize:&tsize
		numFrames:2
		shape: RECTCIRC
		alliance: NEUTRAL
		radius: 24
		buffered: YES
		x: randBetween(-xOffset, xOffset)
		y: randBetween(-yOffset, yOffset)
		theta: randBetween(0, 2 * PI)
		vel: randBetween(12,25)
		interval: 650
		distToCorner: &t2];

	return self;
}

@end
