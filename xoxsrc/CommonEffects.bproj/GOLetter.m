
#import "GOLetter.h"
#import "ActorMgr.h"
#import "DisplayManager.h"
// #import "Xoxeroids.h"

@implementation GOLetter
static id myDelegate;
static int endConditions;

typedef struct {
	char *name;
	NSRect r;
	} GOstruct;

static GOstruct goarray[] = {
	"GOg",  {3,	57,	47,	48},
	"GOa",  {50, 57, 36, 33},
	"GOm",  {91, 57, 51, 35},
	"GOe1", {146, 57, 32, 33},
	"GOo",  {22, 4, 45, 50},
	"GOv",  {68, 4, 30, 35},
	"GOe2", {98, 4, 32, 33},
	"GOr",  {131, 4, 31, 34},
	};

static int wobble;

- activate:sender :(int)tag
{
	GOstruct *gp = (GOstruct *)tag;
	NSRect *rp = &gp->r;
	NSSize tsize;

	tsize.width = rp->size.width / 2;
	tsize.height = rp->size.height / 2;
	wobble = (++wobble) & 1;

	[super activate:sender :tag];

	[self reinitWithImage:gp->name
		frameSize:&rp->size
		numFrames:1
		shape: RECT
		alliance: NEUTRAL
		radius: 1.0
		buffered: YES
		x: gx + randBetween(wobble?xOffset:-xOffset,xOffset+2)
		y: gy + randBetween(wobble?-yOffset:yOffset,yOffset+2)
		theta: 0
		vel: 0
		interval: 10000000
		distToCorner: &tsize];

	[self wrapAtDistance: (xOffset+1) :(yOffset+1)];

	destx = gx - 91 + tsize.width + rp->origin.x;
	desty = gy - 54 + tsize.height + rp->origin.y;
	xv = (x - destx) / -35;
	yv = (y - desty) / -35;

	return self;
}

- positionChanged
{
	if ((xv < 0 && x < destx) || (xv > 0 && x > destx))
		{ xv = 0; x = destx; endConditions--; }
	if ((yv < 0 && y < desty) || (yv > 0 && y > desty))
		{ yv = 0; y = desty; endConditions--; }

	if (endConditions <= 0 && 
		([myDelegate respondsTo:@selector(gameOverComplete)]))
		[myDelegate gameOverComplete];
	return self;
}

+ initialize
{
	int i;
	id theImage;

	[super initialize];

	theImage = [self findImageNamed:"GameOver"];	
	for (i=0; i<8; i++)
	{
		NSImage *i2 = [[NSImage allocFromZone:[self zone]]
					initFromImage:theImage rect:&goarray[i].r];
		[i2 setName:goarray[i].name];
	}
	return self;
}

+ gameOver:sender
{
	int i;

	endConditions = 16;
	myDelegate = sender;

	for (i=0; i<8; i++)
	{
 		[actorMgr newActor:(int)self for:actorMgr
			tag:(int)(&goarray[i])];
	}
	return self;
}

@end














