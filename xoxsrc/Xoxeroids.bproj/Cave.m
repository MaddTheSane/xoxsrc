
#import "Cave.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Explosion.h"
#import "Xoxeroids.h"
#import "Bullet.h"

extern int xx_ship;

@implementation Cave

- activate:sender :(int)tag
{
	NSSize tsize = {150,150};
	NSSize tsize2 = {75,75};

	[super activate:sender :tag];

	[self reinitWithImage:"cave"
		frameSize:&tsize
		numFrames:1
		shape: LINEARRAY
		alliance: EVIL
		radius: tsize2.width
		buffered: YES
		x: randBetween(gx+xOffset/2, gx+5.5*xOffset)
		y: randBetween(gy+yOffset/2, gy+5.5*yOffset)
		theta: randBetween(0,2*PI)
		vel: randBetween(1,4)
		interval: 10000000
		distToCorner: &tsize2];

	// a cave is deconstructed into 8 lines for further collision testing
	complexShapeCnt = 8;

	mySmile = [actorMgr newActor:(int)[Smiley class] for:self tag:0];

	return self;
}

- positionChanged
{
	[super positionChanged];
	[self wrapAtDistance: (3*xOffset) :(3*yOffset)];
	[mySmile moveTo:(x-30) :(y-5)];
	mySmile->xv = xv;
	mySmile->yv = yv;
	return self;
}

- performCollisionWith:(Actor *) dude
{
//	[soundMgr playSound: FUTILITYSND at:0.5];

	return self;
}

static XXLine myShape[] = {
	99,148,0,118,
	0,118,0,31,
	0,31,78,0,
	106,0,148,48,
	108,128,15,100,
	15,100,16,49,
	16,49,90,13,
	90,13,135,64
	};

- constructComplexShape
{
	int i;
	for (i=0; i<8; i++)
	{
		cave[i] = myShape[i];
		cave[i].x1 += x - 75;
		cave[i].x2 += x - 75;
		cave[i].y1 += y - 75;
		cave[i].y2 += y - 75;
	}
	complexShapePtr = (NSRect *)(&cave[0]);
	return self;
}

- (BOOL) doYouHurt:sender
{
	Actor *dude = (Actor *)sender;
	if (dude->actorType == xx_bullet)
	{
		[(Bullet *)dude setBulletImage:0];
		// shots simply return
		dude->xv = -dude->xv;
		dude->yv = -dude->yv;
		dude->theta += PI;
		dude->alliance = XoXDestroyAll;
		return NO;
	}
	return YES;
}

@end


@implementation Smiley

- activate:sender :(int)tag
{
	NSSize tsize = {40,40};
	NSSize tsize2 = {20,20};
	Actor *dude = (Actor *)sender;

	[super activate:sender :tag];

	[self reinitWithImage:"smiley"
		frameSize:&tsize
		numFrames:4
		shape: CIRCLE
		alliance: EVIL
		radius: tsize2.width
		buffered: YES
		x: dude->x - 30
		y: dude->y - 5
		theta: dude->theta
		vel: 0
		interval: 200
		distToCorner: &tsize2];

	frameDir = 1;
	pointValue = 400;
	myCave = sender;
	hits = 0;
	return self;
}

- positionChanged
{
	if (timeInMS > changeTime)
	{
		changeTime = timeInMS + interval;
		frame += frameDir;
		if (frame >= numFrames-1) frameDir = -1;
		else if (frame <= 0) frameDir = 1;
	}
//	[self wrapAtDistance: (3*xOffset) :(3*yOffset)];
	return self;
}

- performCollisionWith:(Actor *) dude
{
	id ret = self;

	if ((++hits % 6) == 0)
		[actorMgr newActor:(int)[Skull class] for:self tag:0];
	if (hits >= 20)
	{
		[actorMgr destroyActor:myCave];
		[soundMgr playSound: (EXP3SND) at:0.5];
		[actorMgr newActor:xx_explosion for:self tag:0];
		ret = [super performCollisionWith: dude];
	}
	else
	{
		[soundMgr playSound: FUTILITYSND at:0.5];
	}

	return ret;
}

- (BOOL) doYouHurt:sender
{
	Actor *dude = (Actor *)sender;
	if (dude->actorType == xx_ship)
	{
		[sender addToScore:pointValue for:self gen:0];
		return NO;
	}
	return YES;
}

- moveBy:(float)dx :(float)dy
{
	// just ignore, wait for the moveTo::
	return self;
}

@end


@implementation Skull

- activate:sender :(int)tag
{
	NSSize tsize = {48,48};
	NSSize tsize2 = {24,24};
	Actor *dude = (Actor *)sender;

	[super activate:sender :tag];

	[self reinitWithImage:"skulls"
		frameSize:&tsize
		numFrames:2
		shape: CIRCLE
		alliance: EVIL
		radius: tsize2.width
		buffered: YES
		x: dude->x
		y: dude->y
		theta: 1.6 * PI
		vel: randBetween(12,15)
		interval: 650
		distToCorner: &tsize2];

	hits = 0;
	pointValue = 125;
	velChange = randBetween(1.5,2);
	dirUpdate = (unsigned)randBetween(220,300);
	return self;
}

- calcDxDy:(NSPoint *)dp
{
	if (timeInMS > moveChangeTime)
	{
		float dx, dy, dist, dxv, dyv;
		moveChangeTime = timeInMS + dirUpdate;
		dx = gx-x; dy=gy-y;
		dist = sqrt(dx*dx+dy*dy);
		dxv = vel * dx/dist;
		dyv = vel * dy/dist;
		if (dxv < xv) xv-=velChange;
		else if (dxv > xv) xv+=velChange;
		if (dyv < yv) yv-=velChange;
		else if (dyv > yv) yv+=velChange;
	}
	[super calcDxDy:dp];
	return self;
}

- positionChanged
{
	[super positionChanged];
	[self wrapAtDistance: (3*xOffset) :(3*yOffset)];
	return self;
}

- performCollisionWith:(Actor *) dude
{
	id ret = self;
	if (++hits >=6)
	{
		[soundMgr playSound: (EXP2SND) at:0.5];
		[actorMgr newActor:xx_explosion for:self tag:1];
		ret = [super performCollisionWith: dude];
	}
	else
	{
		[soundMgr playSound: FUTILITYSND at:0.5];
	}

	return ret;
}


@end







