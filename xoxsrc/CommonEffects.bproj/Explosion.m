
#import "Explosion.h"
#import "ActorMgr.h"
#import "SoundMgr.h"

@implementation Explosion

static char explosionSize[] = {'M', 'S'};

- activate:sender :(int)tag
{
	NXSize tsize = {120,120};
	NXSize tsize2 = {60,60};
	NXSize tsize3 = {30,30};
	char imagename[20];
	Actor *dude = (Actor *)sender;

	[super activate:sender :tag];

	sprintf(imagename,"explosion%c", explosionSize[tag]);

	[self reinitWithImage:imagename
		frameSize: tag ? &tsize2 : &tsize
		numFrames:16
		shape: CIRCLE
		alliance: NEUTRAL
		radius: tag ? tsize3.width : tsize2.width
		buffered: YES
		x: dude->x
		y: dude->y
		theta: dude->theta
		vel: dude->vel
		interval: (int)(randBetween(37,43))
		distToCorner: tag ? &tsize3 : &tsize2];

	return self;
}

- positionChanged
{
	if (timeInMS > changeTime)
	{
		changeTime = timeInMS + interval;
		if (++frame >= numFrames) [actorMgr destroyActor:self];
	}
	return self;
}



@end
