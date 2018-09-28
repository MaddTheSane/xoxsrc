
#import "SpaceGen.h"

@implementation SpaceGen

extern BOOL pauseState;

- newSize:(NSSize *)s
{
	int i;
	STAR *p;

	mySize = *s;

	for (i=0; i<NSTARS; i++)
	{
		p = &stars[i];

		p->position.origin.x = randBetween(0.0, mySize.width);
		p->position.origin.y = randBetween(0.0, mySize.height);
		p->position.size.width = 2.0;
		p->position.size.height = 1.0;

		p->distance = ((i%4) ? randBetween(1, 4) : 1.0);
//
		p->display.size = p->position.size;
		p->display.origin.x = floor(p->position.origin.x);
		p->display.origin.y = floor(p->position.origin.y);

		w[i] = b[i] = p->display;
	}

	return self;
}

- oneStep
{
	int i;
	NSRect *t;
	STAR *p;
	
	xv = gx - oldX; yv = gy - oldY;
	oldX = gx; oldY = gy;

	for (i=0; i<NSTARS; i++)
	{
		p = &stars[i];

		b[i] = p->display;

		if (p->distance == 1.0)
		{
			p->position.origin.x -= xv;
			p->position.origin.y -= yv;
		}
		else
		{
			p->position.origin.x -= xv/p->distance;
			p->position.origin.y -= yv/p->distance;
		}

		if (p->position.origin.x < 0) 
			p->position.origin.x += mySize.width;
		else if (p->position.origin.x > mySize.width) 
			p->position.origin.x -= mySize.width;

		if (p->position.origin.y < 0) 
			p->position.origin.y += mySize.height;
		else if (p->position.origin.y > mySize.height) 
			p->position.origin.y -= mySize.height;

		p->display.size = p->position.size;
		p->display.origin.x = floor(p->position.origin.x);
		p->display.origin.y = floor(p->position.origin.y);

		w[i] = p->display;
	}

	PSsetgray(NX_BLACK);
	NSRectFillList(b, NSTARS);
	PSsetgray(NX_WHITE);
	NSRectFillList(w, NSTARS);

	t=b; b=w; w=t;

	return self;
}

- activate:sender :(int)tag
{
	NSSize tsize = {1,1};

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
		interval: 1000000
		distToCorner: &tsize];

	b=r1;
	w=r2;

	return self;
}

- scheduleDrawing
{
	return self;
}

- draw
{
	if (pauseState == 0) return self;

	PSsetgray(NX_WHITE);
	NSRectFillList(w, NSTARS);
	return self;
}

@end

