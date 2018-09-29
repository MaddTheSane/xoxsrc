
#import "CacheManager.h"
#import "ActorMgr.h"

#define XDEBUG 0
@implementation CacheManager

- (void)eraseCache
{
	NSRect r = {{0,0}};
	NSSize theSize;

	theSize = [cache size];
	r.size = theSize;
	if ([cache lockFocusIfCanDraw])
	{
		[[NSColor blackColor] set];
		NSRectFill(r);
		if (virgin) [self tileUsing:tile];
		[virgin compositeToPoint:r.origin operation:NSCompositingOperationCopy];
		[cache unlockFocus];
	}
}

- (void)newSize:(NSSize)sp
{

	cache = [[NSImage alloc] initWithSize:sp];
	if (virgin)
	{
		virgin = [[NSImage alloc] initWithSize:sp];
	}
	[self eraseCache];
	[eraseRectList removeAllObjects];
}

- init
{
	if (self = [super init]) {

	displayList = [[NSMutableArray alloc] init];
	drawRectList = [[NSMutableArray alloc] init];
	eraseRectList = [[NSMutableArray alloc] init];
	}
	
	return self;
}

// Coalesces 2 rectangles into 1 if they intersect, so that things
// are drawn without flickering and we send as few postscript messages
// as possible while keeping our redraw areas small.  Does nothing
// and returns NO if the regions don't intersect, otherwise the combined
// region is returned in *p1 and returns YES

BOOL coalesce(NSRect *p1, NSRect *p2)
{
	NSRect p3;
	
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


- (void)oneStep
{
	NSRect *p1, *p2, *rectArray;
	NSInteger i, j, iterations;
	BOOL changed;
	int count;
	Actor *theActor;

	if ([cache lockFocusIfCanDraw])
	{

	// first handle all cache erasures
	if (eraseRectList.count)
	{
		if (!virgin)
		{
			PSsetgray(NX_BLACK);
			NSRectFillList(eraseRectList->dataPtr, eraseRectList->numElements);
		}
		else
		{
			NSRect *r = (NSRect *) eraseRectList->dataPtr;
			for (i=0; i<eraseRectList->numElements; i++)
				[virgin composite:NX_COPY fromRect:r+i toPoint:&((r+i)->origin)];
		}
		[eraseRectList removeAllObjects];
	}

	count = [displayList count];
	// now construct next frame in the cache
	for (i=0; i<count; i++)
	{
		theActor = (Actor *)[displayList objectAtIndex:i];

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
			NSRect t = rectArray[i];
			PSsetrgbcolor(.2,.2,1);
			NXFrameRect(&t);
		}
#endif
		}
	}

	[drawRectList removeAllObjects];
	[displayList removeAllObjects];
}

- (void)erase:(NSRect)r
{
	[eraseRectList addObject:[NSValue valueWithRect:r]];
//	[drawRectList addElement:r];
}

- (void)displayRect:(NSRect)r
{
	[drawRectList addObject:[NSValue valueWithRect:r]];
}

- (void)draw:(Actor *)sender;
{
	[displayList addObject:sender];
}

- (void)setBackground:(BOOL)val
{
	NSSize theSize;

	if (val)
	{
		theSize = [cache size];
		if (!virgin) virgin = [[NSImage alloc] initWithSize:theSize];
	}
	else
	{
		tile = virgin = nil;
	}
}

- background
{
	return virgin;
}

- (void)tileUsing:(NSImage*)theTile
{
	NSSize tileSize;
	NSSize virginSize;
	NSPoint pt;
	
	[self setBackground:YES];

	if (!theTile) return;

	tile = theTile;
	
	tileSize = [theTile size];
	virginSize = virgin.size;

	[virgin lockFocus];
		for (pt.y = 0.0; pt.y < virginSize.height; pt.y += tileSize.height)
		{
			for (pt.x = 0.0; pt.x < virginSize.width; pt.x += tileSize.width)
			{
				[theTile compositeToPoint:pt operation:NSCompositingOperationSourceOver];
			}
		}

		[actorMgr makeActorsPerform:@selector(tile)];
		[virgin unlockFocus];
}

- (BOOL)retileRect:(NSRect)rp
{
	NSSize tileSize;
	NSSize virginSize;
	NSPoint pt;
	NSPoint edge;
	NSRect src;
	
	if (!tile) return NO;

	tileSize = tile.size;
	virginSize = virgin.size;

	edge.x = rp.origin.x + rp.size.width;
	edge.y = rp.origin.y + rp.size.height;
	src.origin.y = (int)rp.origin.y % (int)tileSize.height;
	src.size.height = MIN((tileSize.height-src.origin.y),rp.size.height);

	[virgin lockFocus];
		for (pt.y = rp.origin.y; pt.y < edge.y;)
		{
			src.origin.x = (int)rp.origin.x % (int)tileSize.width;
			src.size.width = MIN((tileSize.width-src.origin.x),rp.size.width);
			for (pt.x = rp.origin.x; pt.x < edge.x;)
			{
				[tile drawAtPoint:pt fromRect:src operation:NSCompositingOperationSourceOver fraction:1];
				pt.x += src.size.width;
				src.origin.x = 0.0;
				src.size.width = MIN((tileSize.width),edge.x-pt.x);
			}
			pt.y += src.size.height;
			src.origin.y = 0.0;
			src.size.height = MIN((tileSize.height),edge.y-pt.y);
		}

		[virgin unlockFocus];
	return YES;
}

- (void)draw
{
	NSPoint p = {0,0};
	[virgin compositeToPoint:p operation:NSCompositingOperationCopy];
}

@end





