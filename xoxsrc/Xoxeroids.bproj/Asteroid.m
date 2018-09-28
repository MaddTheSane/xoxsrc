
#import "Asteroid.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Xoxeroids.h"
#import "Thinker.h"

@implementation Asteroid

static int lastAsteroidSound;

static char *rocks[] = {
	"ganymede%c",
	"io%c",
	"jupiter%c",
	"rock%c"
	};

static char rockSize[] = {'B', 'M', 'S'};
static int pointvals[] = {15,25,50};

+ initialize
{
	char imagename[30];
	int i, j;

	[super initialize];

	for (i=0; i<4; i++)
	for (j=0; j<3; j++)
	{
		sprintf(imagename,rocks[i],rockSize[j]);
		[[NSApp delegate] addImageResource:imagename for: self];
	}
	return self;
}

- activate:sender :(int)tag
{
	NSSize tsize = {10,10};
	NSSize tsize2 = {10,10};
	char imagename[30];

	[super activate:sender :tag];

	astSize = tag >> 16;
	astStyle = tag & 0xffff;

	sprintf(imagename,rocks[astStyle],rockSize[astSize]);

	image = [self findImageNamed:imagename];
	[image getSize:&tsize];
	tsize2.width = tsize.width/2;
	tsize2.height = tsize.height/2;

	[self reinitWithImage:imagename
		frameSize:&tsize
		numFrames:1
		shape: CIRCLE
		alliance: EVIL
		radius: tsize2.width
		buffered: YES
		x: randBetween(gx+xOffset, gx+3*xOffset)
		y: randBetween(gy+yOffset, gy+3*yOffset)
		theta: randBetween(0,2*PI)
		vel: randBetween(2,12)
		interval: 1000000
		distToCorner: &tsize2];

	pointValue = pointvals[astSize];
	return self;
}

- positionChanged
{
	[self wrapAtDistance: (2*xOffset) :(2*yOffset)];
	return self;
}

- performCollisionWith:(Actor *) dude
{
	int i;

	if (timeInMS > (lastAsteroidSound + 80))
	{
		lastAsteroidSound = timeInMS + (timeInMS & 0xf);
		[soundMgr playSound: (EXP1SND+astSize) at:0.5];
	}


	if (astSize < 2)
	{
		Actor *rock;
		astSize++;
		for (i=-1; i<=1; i+=2)
		{
			rock = [actorMgr newActor:xx_asteroid for:self
				tag:(astSize<<16 | astStyle)];
			rock->theta = theta + i * 10.0 * PI/180.0;
			rock->vel = vel + randBetween(0,7);
			[rock moveTo: (x + rock->radius * -sin(rock->theta))
				:(y + rock->radius * cos(rock->theta))];
			rock->xv = rock->vel * -sin(rock->theta);
			rock->yv = rock->vel * cos(rock->theta);
		}
	}
	else
	{
		[actorMgr newActor:xx_explosion for:self tag:1];
	}

	return [super performCollisionWith: dude];
}

@end
