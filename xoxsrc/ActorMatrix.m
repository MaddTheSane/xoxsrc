#import "ActorMatrix.h"
#import "ActorMgr.h"
#import "CacheManager.h"
#import "collisions.h"


@implementation Storage (gimmeTheData)
- (id *) idAt:(int)ndx
{
	id *actorArray = (id *)dataPtr;
	return actorArray + ndx;
}
- actorAt:(int)ndx
{
	return *([self idAt:ndx]);
}

- replaceActorAt:(unsigned int)index with:theActor
{
	id *theActorPtr = [self idAt:index];
	*theActorPtr = theActor;
	return self;
}
@end

@implementation ActorMatrix

// if ActorMatrix was sender, don't add objects to employed list
// (they're subcontractors, so they work cheaper...)

- (BOOL) addToEmployedList:dude
{	return NO;
}

- (BOOL) isGroup
{	return YES;
}

- init
{
	[super init];
	formation = [[Storage allocFromZone:[self zone]]
		initCount:8
		elementSize: sizeof(id)
		description: "@"];

	return self;
}

- activate:sender :(int)tag
{
	NXSize t2;
	NXSize t1;
	MatrixData *md = (MatrixData *)tag;
	int numActors = (md->columns * md->rows);
	int i,j;

	[super activate:sender :tag];

    rows = md->rows;
	columns = md->columns;
	actWidth = md->actWidth;
	actHeight = md->actHeight;
	xgap = md->xgap;
	ygap = md->ygap;

	t2.width = columns * (actWidth + xgap) - xgap;
	t2.height = rows * (actHeight + ygap) - ygap;
	t1.width = t2.width / 2.0;
	t1.height = t2.height / 2.0;

	[self reinitWithImage:"none"
		frameSize:&t2
		numFrames:1
		shape: RECT
		alliance: md->alliance
		radius: 1.0
		buffered: YES
		x: md->x
		y: md->y
		theta: md->theta
		vel: md->vel
		interval: md->interval
		distToCorner: &t1];

	modifyThetas = md->modifyThetas;

	[formation setNumSlots:numActors];


	if (md->autofill)
	{
		id dude;
		float ox = x, oy = y;
		for (j=0; j<rows; j++)
		for (i=0; i<columns; i++)
		{
			x = ox - t1.width + (i*(actWidth+xgap)) + (actWidth/2.0);
			y = oy - t1.height + (j*(actHeight+ygap)) + (actHeight/2.0);
			dude = [actorMgr newActor:(int)md->whichClass 
				for:self tag:tag];
			[formation replaceActorAt:j*columns+i with:dude];
		}
		x = ox; y = oy;
		actorCount = numActors;
	}
	else
	{
		bzero([formation idAt:0],numActors * sizeof(id));
		actorCount = 0;
	}
	return self;
}

- addToFormation: whichClass tag:(int)tag at:(int)col :(int)row 
{
	float ox = x, oy = y;
	id dude;

	x = ox + (col*(actWidth+xgap)) + (actWidth/2.0);
	y = oy + (row*(actHeight+ygap)) + (actHeight/2.0);
	dude = [actorMgr newActor:(int)whichClass 
		for:self tag:tag];
	[formation replaceActorAt:row*columns+col with:dude];
	x = ox; y = oy;
	actorCount++;
	return dude;
}

- nukeActorAt:(int)col :(int)row
{
	[formation replaceActorAt:row*columns+col with:nil];
	if (--actorCount <= 0) [actorMgr destroyActor:self];
	return self;
}

- free
{
	[formation free];
	return [super free];
}

- makeActorsPerform:(SEL)func
{
	int numActors = columns * rows;
	int i;
	id dude;
	for (i=0; i<numActors; i++)
	{
		if (dude = [formation actorAt:i]) [dude perform:func];
	}
	return self;
}

- perform:(SEL)func cols:(int)begc :(int)endc rows:(int)begr :(int)endr
{
	int i,j;
	id dude;

	for (j=begr; j<=endr; j++)
	for (i=begc; i<=endc; i++)
	{
		if (dude = [formation actorAt:j*columns+i]) [dude perform:func];
	}
	return self;
}


// determine if a collision happended into the matrix, and if so, what the
// beginning and ending rows and columns are.

- (BOOL) rowsNcols:(NXRect *)r myRect:(NXRect *)myRect
		:(int *)begc :(int *)endc :(int *)begr :(int *)endr
{
	int t;
	if (!intersectsRect(myRect, r)) return NO;

	t = (NX_X(r) - NX_X(myRect)) / (actWidth + xgap);
	if (NX_X(r) > (NX_X(myRect) + (t+1) * (actWidth + xgap) - xgap))
		t++;
	if (t < 0) t = 0;
	*begc = t;

	t = (NX_MAXX(r) - NX_X(myRect)) / (actWidth + xgap);
	if (t >= columns) t = columns - 1;
	if (t < *begc) return NO;
	*endc = t;



	t = (NX_Y(r) - NX_Y(myRect)) / (actHeight + ygap);
	if (NX_Y(r) > (NX_Y(myRect) + (t+1) * (actHeight + ygap) - ygap))
		t++;
	if (t < 0) t = 0;
	*begr = t;

	t = (NX_MAXY(r) - NX_Y(myRect)) / (actHeight + ygap);
	if (t >= rows) t = rows - 1;
	if (t < *begr) return NO;
	*endr = t;

	return YES;
} 

//-----------------------------------------
- retire
{
	[self makeActorsPerform:@selector(retire)];
	employed = NO;
	return self;
}

- oneStep
{
	NXPoint dXdY;
	int i,j;
	Actor *dude;
	float bx, by;

	if (rNc)
	{
		[self perform:@selector(erase) cols:bc :ec rows:br :er];
	}

	[self calcDxDy: &dXdY];

	[self moveBy:dXdY.x :dXdY.y];

	complexShapePtr = NULL;

	[self positionChanged];

	bx = x - distToCorner.width + (actWidth/2.0);
	by = y - distToCorner.height + (actHeight/2.0);

	rNc = [self rowsNcols:&screenRect myRect:&drawRect :&bc :&ec :&br :&er];

	for (j=0; j<rows; j++)
	for (i=0; i<columns; i++)
	{
		if (dude = [formation actorAt:j*columns+i])
		{
			[dude moveTo: bx + (i*(actWidth+xgap))
				:by + (j*(actHeight+ygap))];
			dude->complexShapePtr = NULL;
			if (modifyThetas) dude->theta = theta;
			[dude positionChanged];

			if ((dude->eraseRect.size.width > 0) &&
				((!rNc) || ((j<br) || (j>er) || (i<bc) || (i>ec))))
			{
				[cacheMgr displayRect:&dude->eraseRect];
				dude->eraseRect.size.width = 0;
			}
		}
	}
	return self;
}

- scheduleDrawing
{
	int i,j;
	Actor *dude;

	if (rNc)
	{
		for (j=br; j<=er; j++)
		for (i=bc; i<=ec; i++)
		{
			if ((dude = [formation actorAt:j*columns+i]) && dude->employed)
			{
				[cacheMgr draw:dude];
				[dude addFlushRects];
//				dude->eraseRect = dude->drawRect;
			}
		}
	}
	return self;
}

- (BOOL) doYouHurt:sender
{	return NO;
}

- performCollisionWith:(Actor *) dude
{
	int i,j;
	id myActor;
	int tbc, tec, tbr, ter;

	if ([self rowsNcols:&dude->collisionRect myRect:&collisionRect :&tbc :&tec :&tbr :&ter])
	{
		for (j=tbr; j<=ter; j++)
		for (i=tbc; i<=tec; i++)
		{
			if (myActor = [formation actorAt:j*columns+i])
			{
				if (actorsCollide(dude,myActor))
				{
					BOOL h1, h2;
					h1 = [myActor doYouHurt:dude];
					h2 = [dude doYouHurt:myActor];
					if (h1) [dude performCollisionWith:myActor];
					if (h2)
					{
						if (![myActor performCollisionWith:dude]) [self nukeActorAt:i :j];
					}
				}
			}
		}
	}
	return employed ? self : nil;
}

@end














