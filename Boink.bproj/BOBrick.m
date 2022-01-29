
#import "BOBrick.h"
#import "CacheManager.h"

@implementation BOBrick


- activate:sender :(int)tag
{
	NXSize tsize = {200,100};
	NXSize ts2 = {228,124};
	NXSize t2 = {100, 50};

	[super activate:sender :tag];

	[self reinitWithImage:"BObrick"
		frameSize:&tsize
		numFrames:1
		shape: RECT
		alliance: EVIL
		radius: 50
		buffered: YES
		x: 0
		y: 0
		theta: 0
		vel: 0
		interval: 4000
		distToCorner: &t2];

	drawRect.size = frameSize = ts2;
	return self;
}

- calcDrawRect
{
	drawRect.origin.x = floor(x - gx - distToCorner.width + xOffset);
	drawRect.origin.y = floor(y - gy - distToCorner.height + yOffset - 24);
	return self;
}

- performCollisionWith:(Actor *) dude
{
	// don't go away
	return self;
}

// since this is a stationary object, we never shedule drawing;
// we just draw into the virgin buffer once and forget it.

- oneStep
{
	if (timeInMS > changeTime)
	{
		[self calcDrawRect];
		eraseRect = drawRect;
		if (alliance == EVIL)
		{
			changeTime = timeInMS+1500;
			alliance = XoXNeutral;
			[cacheMgr retileRect:&drawRect];
		}
		else
		{
			changeTime = timeInMS+4000;
			alliance = EVIL;
			[[cacheMgr background] lockFocus];
			[super draw];
			[[cacheMgr background] unlockFocus];
		}
		[self erase];
		needToDraw = YES;
	}
	return self;
}

- scheduleDrawing
{
	if (needToDraw)
	{
		[super scheduleDrawing];
		needToDraw = NO;
	}
	return self;
}

- draw	// so I don't draw on drawself messages...
{
	return self;
}

- tile
{
	[self calcDrawRect];
	if (alliance == EVIL)
	{
		[super draw];	// super's implementation really draws
	}
	return self;
}

@end
