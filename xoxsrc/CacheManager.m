
#import "CacheManager.h"
#import "ActorMgr.h"

#define XDEBUG 0
@implementation CacheManager

- eraseCache
{
	NXRect r = {{0,0}};
	NXSize theSize;

	[cache getSize:&theSize];
	r.size = theSize;
	if ([cache lockFocus])
	{
		PSsetgray(NX_BLACK);
		NXRectFill(&r);
		if (virgin) [self tileUsing:tile];
		[virgin composite:NX_COPY toPoint:&r.origin];
		[cache unlockFocus];
	}
	return self;
}

- newSize:(NXSize *)sp
{

	[cache free];
	cache = [[NXImage allocFromZone:[self zone]] initSize:sp];
	if (virgin)
	{
		[virgin free];
		virgin = [[NXImage allocFromZone:[self zone]] initSize:sp];
	}
	[self eraseCache];
	[eraseRectList empty];

	return self;
}

- init
{
	[super init];

	displayList = [[List allocFromZone:[self zone]] init];
	drawRectList = [[Storage allocFromZone:[self zone]]
		initCount:8
		elementSize: sizeof(NXRect)
		description: @encode(NXRect)];
	eraseRectList = [[Storage allocFromZone:[self zone]]
		initCount:8
		elementSize: sizeof(NXRect)
		description: @encode(NXRect)];

	return self;
}

// Coalesces 2 rectangles into 1 if they intersect, so that things
// are drawn without flickering and we send as few postscript messages
// as possible while keeping our redraw areas small.  Does nothing
// and returns NO if the regions don't intersect, otherwise the combined
// region is returned in *p1 and returns YES

BOOL coalesce(NXRect *p1, NXRect *p2)
{
	NXRect p3;
	
	if (((p1->origin.x + p1->size.width) < p2->origin.x) ||
		((p2->origin.x + p2->size.width) < p1->origin.x) ||
		((p1->origin.y + p1->size.height) < p2->origin.y) ||
		((p2->origin.y + p2->size.height) < p1->origin.y)) return NO;

	p3.origin.x = MIN(p1->origin.x,p2->origin.x);
	p3.origin.y = MIN(p1->origin.y,p2->origin.y);
	p3.size.width = MAX(p1->origin.x+p1->size.width,
						p2->origin.x+p2->size.width);
	p3.size.width -= p3.origin.x;
	p3.size.height = MAX(p1->origin.y+p1->size.height,
						 p2->origin.y+p2->size.height);
	p3.size.height -= p3.origin.y;

	// only coalesce if the resultant area is less than the sum of
	// (the two input areas plus the simulated cost of an extra blit)

	if ((p3.size.width * p3.size.height) > 
		(p1->size.width * p1->size.height + 
		p2->size.width * p2->size.height + (50.0 * 50.0))) return NO;

	*p1 = p3;

	return YES;
}


- oneStep
{
	NXRect *p1, *p2, *rectArray;
	int i, j, iterations;
	BOOL changed;
	int count;
	Actor *theActor;

	if ([cache lockFocus])
	{

	// first handle all cache erasures
	if (eraseRectList->numElements)
	{
		if (!virgin)
		{
			PSsetgray(NX_BLACK);
			NXRectFillList(eraseRectList->dataPtr, eraseRectList->numElements);
		}
		else
		{
			NXRect *r = (NXRect *) eraseRectList->dataPtr;
			for (i=0; i<eraseRectList->numElements; i++)
				[virgin composite:NX_COPY fromRect:r+i toPoint:&((r+i)->origin)];
		}
		[eraseRectList empty];
	}

	count = [displayList count];
	// now construct next frame in the cache
	for (i=0; i<count; i++)
	{
		theActor = (Actor *)[displayList objectAt:i];

		// while I'm here, store all the rects that need flushing
//		[theActor addFlushRectsTo:drawRectList];

		[theActor draw];
	}

	[cache unlockFocus];
	}

	// coalesce some redraw regions
	rectArray = drawRectList->dataPtr;
	count = [drawRectList count];

	iterations = 0;
	do {
		changed = NO;
		for (i=0; i<(count-1); i++)
		{
			p1 = &rectArray[i];
			if (p1->size.width <=0) continue;

			for (j=i+1; j<count; j++)
			{
				p2 = &rectArray[j];
				if (p2->size.width <=0) continue;

				if (coalesce(p1,p2))
				{
					changed = YES;
					p2->size.width = -1;
				}
			}
		}
//	} while (changed && (++iterations < 4));
	} while (changed && (++iterations < 3));

	for (i=0; i<count; i++)
	{
		if (rectArray[i].size.width > 0)
		{
		[cache composite:NX_COPY fromRect:&rectArray[i]
			toPoint:&rectArray[i].origin];
#if XDEBUG
		{
			NXRect t = rectArray[i];
			PSsetrgbcolor(.2,.2,1);
			NXFrameRect(&t);
		}
#endif
		}
	}

	[drawRectList empty];
	[displayList empty];

	return self;
}

- erase:(NXRect *)r
{
	[eraseRectList addElement:r];
//	[drawRectList addElement:r];
	return self;
}

- displayRect:(NXRect *)r
{
	[drawRectList addElement:r];
	return self;
}

- draw:(Actor *)sender;
{
	[displayList addObject:sender];
	return self;
}

- setBackground:(BOOL)val
{
	NXSize theSize;

	if (val)
	{
		[cache getSize:&theSize];
		if (!virgin) virgin = [[NXImage allocFromZone:[self zone]] initSize:&theSize];
	}
	else
	{
		[virgin free];
		tile = virgin = nil;
	}
	return self;
}

- background
{
	return virgin;
}

- tileUsing:theTile
{
	NXSize tileSize;
	NXSize virginSize;
	NXPoint pt;
	
	[self setBackground:YES];

	if (!theTile) return nil;

	tile = theTile;
	
	[theTile getSize:&tileSize];
	[virgin getSize:&virginSize];

	if ([virgin lockFocus])
	{
		for (pt.y = 0.0; pt.y < virginSize.height; pt.y += tileSize.height)
		{
			for (pt.x = 0.0; pt.x < virginSize.width; pt.x += tileSize.width)
			{
				[theTile composite:NX_SOVER toPoint:&pt];
			}
		}

		[actorMgr makeActorsPerform:@selector(tile)];
		[virgin unlockFocus];
	}
	return self;
}

- retileRect:(NXRect *)rp
{
	NXSize tileSize;
	NXSize virginSize;
	NXPoint pt;
	NXPoint edge;
	NXRect src;
	
	if (!tile) return nil;

	[tile getSize:&tileSize];
	[virgin getSize:&virginSize];

	edge.x = rp->origin.x + rp->size.width;
	edge.y = rp->origin.y + rp->size.height;
	src.origin.y = (int)rp->origin.y % (int)tileSize.height;
	src.size.height = MIN((tileSize.height-src.origin.y),rp->size.height);

	if ([virgin lockFocus])
	{
		for (pt.y = rp->origin.y; pt.y < edge.y;)
		{
			src.origin.x = (int)rp->origin.x % (int)tileSize.width;
			src.size.width = MIN((tileSize.width-src.origin.x),rp->size.width);
			for (pt.x = rp->origin.x; pt.x < edge.x;)
			{
				[tile composite:NX_SOVER fromRect:&src toPoint:&pt];
				pt.x += src.size.width;
				src.origin.x = 0.0;
				src.size.width = MIN((tileSize.width),edge.x-pt.x);
			}
			pt.y += src.size.height;
			src.origin.y = 0.0;
			src.size.height = MIN((tileSize.height),edge.y-pt.y);
		}

		[virgin unlockFocus];
	}
	return self;
}

- draw
{
	NXPoint p = {0,0};
	[virgin composite:NX_COPY toPoint:&p];
	return self;
}

@end





