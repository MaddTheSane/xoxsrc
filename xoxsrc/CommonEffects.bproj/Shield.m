
#import "Shield.h"
#import "Ship.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Thinker.h"

@implementation Shield

+ initialize
{
	[super initialize];
	[[NXApp delegate] addImageResource:"shield" for: self];
	return self;
}

- activate:sender :(int)tag
{
	NXSize tsize = {40,40};
	NXSize tsize2 = {20,20};

	[super activate:sender :tag];

	ship = sender;

	[self reinitWithImage:"shield"
		frameSize:&tsize
		numFrames:8
		shape: CIRCLE
		alliance: NEUTRAL
		radius: 40
		buffered: NO
		x: ship->x
		y: ship->y
		theta: 0
		vel: 0
		interval: 10000000
		distToCorner:&tsize2];

	oldShields = 0;

	return self;
}

- positionChanged
{
	[self moveTo:ship->x :ship->y];

	if (oldShields != ship->shieldStrength)
	{
		oldShields = ship->shieldStrength;
		frame = 8 - (ceil(oldShields / 12.5));
		if (frame < 0) frame = 0;
		else if (oldShields <= 0) [actorMgr destroyActor:self];
	}

	return self;
}

@end
