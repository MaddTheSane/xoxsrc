
#import "Eye.h"
#import "SoundMgr.h"
#import "ActorMgr.h"
#import "Xoxeroids.h"

@implementation Eye

- activate:sender :(int)tag
{
	static unsigned short mfbuffered;
	NXSize tsize = {19,19};
	NXSize tsize2 = {9.5,9.5};
	Actor *dude = (Actor *)sender;
	float ttheta = atan2(dude->x - gx, gy - dude->y);

	[super activate:sender :tag];

	[self reinitWithImage:"eye"
		frameSize:&tsize
		numFrames:6
		shape: CIRCLE
		alliance: DESTROYALL
		radius: tsize2.width
		buffered: ((mfbuffered++) & 1)
		x: dude->x - (sin(ttheta) * (dude->radius + 12))
		y: dude->y + cos(ttheta) * (dude->radius + 12)
		theta: ttheta
		vel: randBetween(16,22)
		interval: 70
		distToCorner: &tsize2];

	expireTime = timeInMS + 1800;
	frameCnt = timeInMS & 0xf;

	return self;
}

- positionChanged
{
	static char efn[] = { 0,0,1,2,1,0,1,2,1,0,0,3,4,5,4,3 };

	if (timeInMS > changeTime)
	{
		changeTime = timeInMS + interval;
		frameCnt++;
		if (frameCnt > 15) frameCnt = 0;
		frame = efn[frameCnt];
	}
	return self;
}

- calcDxDy:(NXPoint *)dp
{
	if (timeInMS > expireTime)
		[actorMgr destroyActor:self];

	dp->x = timeScale * xv;
	dp->y = timeScale * yv;

	return self;
}

- performCollisionWith:(Actor *) dude
{
	id ret = self;
	if (dude->actorType != actorType) 
	{
		[soundMgr playSound: EXP1SND at:0.5];
		[actorMgr newActor:xx_explosion for:self tag:1];
		ret = [super performCollisionWith: dude];
	}

	return ret;
}

@end


@implementation CrabNebula

- activate:sender :(int)tag
{
	NXSize tsize = {107,125};
	NXSize tsize2 = {53,62};

	[super activate:sender :tag];

	[self reinitWithImage:"crabneb"
		frameSize:&tsize
		numFrames:1
		shape: CIRCLE
		alliance: NEUTRAL
		radius: tsize2.width
		buffered: YES
		x: randBetween(gx+xOffset, gx+3*xOffset)
		y: randBetween(gy+yOffset, gy+3*yOffset)
		theta: randBetween(0,2*PI)
		vel: randBetween(0.01,0.5)
		interval: 1000000
		distToCorner: &tsize2];

	return self;
}

- positionChanged
{
	float dgx = gx-ogx, dgy = gy - ogy;
	[self moveBy:dgx*.666 :dgy*.666];
	[self wrapAtDistance: (2.5*xOffset) :(2.5*yOffset)];
	ogx = gx; ogy = gy;
	return self;
}

@end
