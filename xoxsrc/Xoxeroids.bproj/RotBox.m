
#import "RotBox.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Explosion.h"
#import "Xoxeroids.h"

extern int xx_ship;

@implementation RotBox

- activate:sender :(int)tag
{
	NXSize tsize = {124,149};
	NXSize tsize2 = {62,75};
	Actor *dude = (Actor *)sender;
	char *whatImage = tag ? "rotBox2" : "rotBox1";

	[super activate:sender :tag];

	[self reinitWithImage:whatImage
		frameSize:&tsize
		numFrames:1
		shape: LINEARRAY
		alliance: DESTROYALL
		radius: tsize2.width
		buffered: YES
		x: ((!tag) ? (randBetween(gx+xOffset/2, gx+5.5*xOffset-151)) :
			dude->x + 150)
		y: ((!tag) ? (randBetween(gy+yOffset/2, gy+5.5*yOffset-61)) :
			dude->y + 60)
		theta: ((!tag) ? (randBetween(0,2*PI)) : dude->theta)
		vel: ((!tag) ? (randBetween(2,4)) : 0)
		interval: ((!tag) ? 12345678 : 10000000)
		distToCorner: &tsize2];

	// a cave is deconstructed into 8 lines for further collision testing
	complexShapeCnt = 6;

	myBall = [actorMgr newActor:(int)[RotBall class] for:self tag:tag];

	if (!tag) 
		myBuddy = [actorMgr newActor:(int)[RotBox class] for:self tag:1];
	else myBuddy = sender;

	return self;
}

- buddy
{
	return myBuddy;
}

- positionChanged
{
	[super positionChanged];
	if (vel)
	{
		[self wrapAtDistance: (3*xOffset) :(3*yOffset)];
		[myBuddy moveTo:(x + 150) :(y + 60)];
	}

	[myBall moveTo:x :y];

	return self;
}

- performCollisionWith:(Actor *) dude
{
//	[soundMgr playSound: FUTILITYSND at:0.5];

	return self;
}

static XXLine myShape[] = {
	0,117,54,0,		// left
	12,109,57,16,	// left mid
	0,117,67,149,	// top
	5,104,73,136,	// mid top
	47,12,117,43,	// mid bottom
	54,0,123,31,	// bottom
	71,135,113,42,	// right mid
	67,149,123,28,	// right
	};

- constructComplexShape
{
	int i;
	int offset = ((interval == 12345678) ? 0 : 2);
	for (i=0; i<6; i++)
	{
		outline[i] = myShape[i+offset];
		outline[i].x1 += x - 62;
		outline[i].x2 += x - 62;
		outline[i].y1 += y - 75;
		outline[i].y2 += y - 75;
	}
	complexShapePtr = (NXRect *)(&outline[0]);
	return self;
}

- (BOOL) doYouHurt:sender
{
	Actor *dude = (Actor *)sender;
	// fix me! This should be done using dot products...
	// ie the reflection of vector v on line l with normal n
	// where l and n are normalized is and the result is v' is:
	// v' = (v.l)l - (v.n)n
	// screw these slow transcendentals...

	// here is the line the bullet collided with
	XXLine *myLine = (XXLine *)dude->collisionThing;
	float myAngle = atan2(myLine->y2 - myLine->y1, 
		myLine->x2 - myLine->x1);
	float bulletsAngle = atan2(dude->yv,dude->xv);
	float newTheta = (2.0 * myAngle) - bulletsAngle - (PI/2.0);
	float xfactor = -sin(newTheta), yfactor = cos(newTheta);
	float oldVel = sqrt(dude->xv*dude->xv + dude->yv*dude->yv);

	// first back off bullet
	[dude moveBy: (-0.5 * timeScale * dude->xv)
				: (-0.5 * timeScale * dude->yv)];

	// shots reflected around normal of collision line
	[dude setXvYv:oldVel * xfactor :oldVel * yfactor sync:NO];
	[dude setVel:oldVel];

	[dude positionChanged];

	if (dude->actorType == xx_ship) return YES;

	[dude setTheta:newTheta];

	return NO;
}

@end


@implementation RotBall

- activate:sender :(int)tag
{
	NXSize tsize = {32,32};
	NXSize tsize2 = {16,16};
	Actor *dude = (Actor *)sender;

	[super activate:sender :tag];

	[self reinitWithImage:"rotBall"
		frameSize:&tsize
		numFrames:10
		shape: CIRCLE
		alliance: EVIL
		radius: tsize2.width
		buffered: YES
		x: dude->x
		y: dude->y
		theta: dude->theta
		vel: 0
		interval: 70
		distToCorner: &tsize2];

	pointValue = 400;
	kind = tag;
	frame = (int) (randBetween(0,9.9));
	return self;
}

- positionChanged
{
	[super positionChanged];
	if (frame == 6) interval = 160;
	else if (frame == 7) interval = 70;
//	[self wrapAtDistance: (3*xOffset) :(3*yOffset)];
	return self;
}

- performCollisionWith:(Actor *) dude
{
	id ret = self;
	Actor *mine;
	Actor *myBox = (Actor *)scoreTaker;

	if (dude->actorType == xx_ship)
	{
//		[soundMgr playSound: (EXP3SND) at:0.5];
		mine = (Actor *)[actorMgr newActor:xx_mine for:self tag:0];
		[mine moveTo:(x + (kind ? -35 : 35))
			:(y + (kind ? -132 : 132))];

		if (myBox->xv == 0) myBox = [(RotBox*)myBox buddy];

		mine->xv = myBox->xv;
		mine->yv = myBox->yv;

		ret = [super performCollisionWith: dude];
	}

	return ret;
}

- (BOOL) doYouHurt:sender
{
	Actor *dude = (Actor *)sender;
	if (dude->actorType == xx_ship)
	{
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


