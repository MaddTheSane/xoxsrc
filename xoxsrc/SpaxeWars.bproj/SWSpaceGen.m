
#import "SWSpaceGen.h"

@implementation SWSpaceGen

- activate:sender :(int)tag
{
	xrate = randBetween(-5, 5);
	yrate = randBetween(-5, 5);
	return [super activate:sender :tag];
}

- oneStep
{
	float oldgx = gx, oldgy = gy;
	gx = (myGx += xrate * timeScale);
	gy = (myGy += yrate * timeScale);
	[super oneStep];
	gx = oldgx;
	gy = oldgy;
	return self;
}
@end
