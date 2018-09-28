
#import "SpaceSpinGen.h"
#import "xoxDefs.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Xoxeroids.h"

#import <dpsclient/wraps.h>
#import <appkit/NXImage.h>
#import <objc/zone.h>
#import <mach/mach.h>
#import <c.h>
#import <libc.h>
#import <math.h>

#define PI (3.141592653589)

NXSize sizeArray[] = {{1,1},{2,1},{2,2},{3,2},{3,3},{4,3},{4,4}};

@implementation SpaceSpinGen

- newSize:(NXSize *)s
{
	int i;
	float tx,ty;

	mySize = *s;
	tx = mySize.width;
	ty = mySize.height;
	zradius = (sqrt(tx*tx + ty*ty))/2;

	nstars = 0;
	for (i=0; i<NSTARS2/2; i++) [self addStar];

	return self;
}

//takes theta and distance and stuffs it into x &y for *p
- convertToXY:(SSTAR *)p
{
	p->draw.origin.x = floor(mySize.width / 2 + (p->distance * cos(p-> theta)));
	p->draw.origin.y = floor(mySize.height / 2 + (p->distance * sin(p-> theta)));
	return self;
}


- oneStep
{
	int i, count, starsInArray = 0;
	SSTAR *p;
	
	if (timeInMS > expireTime)
		[actorMgr destroyActor:self];

	if (nstars < NSTARS2) [self addStar];

	for (i=0; i<nstars; i++)
	{
		p = &stars[i];
		p->distance += timeScale * p->delta;
		cumuTimeStamp += timeScale;
		if (cumuTimeStamp > 1)
		{
			p->delta *= p->ddelta * cumuTimeStamp;
//			p->delta *= p->ddelta;
			cumuTimeStamp = 0;
		}
		p->theta += timeScale * 0.05;
		if (p->theta > (2*PI)) p->theta -= (2*PI);

		[self convertToXY:p];

		// only draw the star if it moved > 1 pixel
		if (p->draw.origin.x != p->erase.origin.x || 
			p->draw.origin.y != p->erase.origin.y)
		{
			// add star to the erasure array
			b[starsInArray] = p->erase;

			if (p->distance > p->changepoint[p->changemode])
			{
				(p->changemode)++;
				p->draw.size = sizeArray[p->changemode];
			}

			// clipping is off, so we must not draw outside view.
			// replace stars that go too far...
			if (p->draw.origin.x < 0 ||
				p->draw.origin.y < 0 ||
				p->draw.origin.x + 4 > mySize.width ||
				p->draw.origin.y + 4 > mySize.height)
			{
				[self replaceStarAt:i];
			}

			w[starsInArray++] = p->draw;
			
			p->erase = p->draw;
		}
	}

	if (starsInArray)
	{
		count = 0;
		while (count < starsInArray)
		{
			// You get the best performance if you put out all the stars
			// at once.  This causes noticable flicker, so I put out 
			// 100 of the stars per iteration.  This gives reasonable speed
			// and flicker is hardly noticable.  Besides, stars
			// _should_ flicker a little...
		
			int t = (starsInArray - count);
			i = (t < STARSPERIT)?t:STARSPERIT;
			
			PSsetgray(NX_BLACK);
			NXRectFillList(&b[count],i);
			
			PSsetgray(NX_WHITE);
			NXRectFillList(&w[count],i);
			
			count += STARSPERIT;
		}
	}

	return self;
}

- activate:sender :(int)tag
{
	NXSize tsize = {1,1};

	[soundMgr playSound: WARPSND at:0.5];

	[super activate:sender :tag];

	[self reinitWithImage:"ship"
		frameSize:&tsize
		numFrames:1
		shape: NOSHAPE
		alliance: NEUTRAL
		radius: 1
		buffered: NO
		x: -1000000
		y: -1000000
		theta: 0
		vel: 0
		interval: 10000
		distToCorner: &tsize];

	expireTime = timeInMS + 2300;
	cumuTimeStamp = 0;

	return self;
}

- scheduleDrawing
{
	return self;
}

// only call addStar if there is room in the stars array!
- addStar
{
	[self replaceStarAt:nstars++];
	return self;
}

- replaceStarAt:(int)index
{
	float dist, t;
	int tries = 0;
	SSTAR *p = &stars[index];
	BOOL inBounds;

	do {
		p->theta = randBetween(0,(2*PI));

		if (tries++ < 3) p->distance = randBetween(1, zradius);
		else p->distance = randBetween(1, p->distance);

		inBounds = YES;
		[self convertToXY:p];

		if (p->draw.origin.x < 0 || p->draw.origin.y < 0 ||
			p->draw.origin.x + 4 > mySize.width ||
			p->draw.origin.y + 4 > mySize.height)
		{
			inBounds = NO;
		}
	} while (!inBounds);

	p->draw.size = sizeArray[0];

//	p->delta = (0.4);
	p->delta = (0.5);

	p->ddelta = randBetween(1.1, 1.25);
//	p->ddelta = randBetween(1.2, 1.35);

	t = randBetween(0, (0.42*zradius));
	dist = MAX(20,t);
	p->changepoint[0] = p->distance + 5;			// 2nd
	p->changepoint[1] = p->changepoint[0] - 5 + dist + dist;	// 3rd

	p->changepoint[2] = p->changepoint[1] + dist;		// 4th
	p->changepoint[3] = p->changepoint[2] + dist;		// 5th
	p->changepoint[4] = p->changepoint[3] + dist;		// 6th
	p->changepoint[5] = 100000;				// never change to 7th

	p->changemode = 0;
	
	p->erase = p->draw;

	return self;
}


@end

