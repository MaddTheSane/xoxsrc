
#import "collisions.h"
#import "Actor.h"
#import "ActorMgr.h"
#import "DisplayManager.h"
#import "CacheManager.h"

BOOL intersectsRect(NSRect *r1, NSRect *r2)
{
	return NSIntersectsRect(*r1, *r2);
}

BOOL intersectsCircle(Actor *a1, Actor *a2)
{
	CGFloat dx, dy, dist, sumrad;

	dx = a1->point.x - a2->point.x;
	dy = a1->point.y - a2->point.y;
	dist = dx*dx + dy*dy;
	sumrad = (a1->radius + a2->radius);
	if (dist > (sumrad * sumrad)) return NO;
	return YES;
}

void circleToLines(Actor *a1, NSPoint *pt)
{
	pt[0].x = pt[2].x = pt[4].x = a1->point.x;
	pt[1].y = pt[3].y = a1->point.y;
	pt[0].y = pt[4].y = a1->point.y - a1->radius;
	pt[2].y = a1->point.y + a1->radius;
	pt[1].x = a1->point.x + a1->radius;
	pt[3].x = a1->point.x - a1->radius;
}

#define MINRECTSIZE 11

void rectToLines(NSRect *rO, NSPoint *pt, int minSize)
{
	NSRect r = *rO;

	if (r.size.width < minSize)
	{
		r.origin.x -= (minSize-r.size.width)/2.0;
		r.size.width = minSize;
	}
	if (r.size.height < minSize)
	{
		r.origin.y -= (minSize-r.size.height)/2.0;
		r.size.height = minSize;
	}
	pt[0].x = pt[3].x = pt[4].x = r.origin.x;
	pt[0].y = pt[4].y = pt[1].y = r.origin.y;
	pt[1].x = pt[2].x = r.origin.x + r.size.width;
	pt[2].y = pt[3].y = r.origin.y + r.size.height;
}

// a macro for determining which side of a line a point is on
// returns 0 for points on the line
static inline float xSign(float px, float py, 
		float lx1, float ly1, float lx2, float ly2)
{
	return ((ly2 - ly1) * (px - lx1)) - ((lx2 - lx1) * (py - ly1));
}

// macros for the points of 2 lines
#define P1 ln1->x1,ln1->y1
#define P2 ln1->x2,ln1->y2
#define P3 ln2->x1,ln2->y1
#define P4 ln2->x2,ln2->y2
#define L1 P1,P2
#define L2 P3,P4

#define XDEBUG 0

XXLine *gln1, *gln2;

// lines intersect if the end points of each line are on opposite sides
// of the other line.  Look ma, no division, no slope or parallel problems
BOOL linesCollide(XXLine *ln1, int cnt1, BOOL packed1,
			XXLine *ln2s, int cnt2, BOOL packed2)
{
	int i,j;
	NSPoint *tpp;

	for (i=0; i<cnt1; i++)
	{
		XXLine *ln2 = ln2s;
		for (j=0; j<cnt2; j++)
		{
#if XDEBUG
		{
			float x1,y1,x2,y2;
			x1 = ln1->x1 - gx + xOffset;
			y1 = ln1->y1 - gy + yOffset;
			x2 = ln1->x2 - gx + xOffset;
			y2 = ln1->y2 - gy + yOffset;
			PSgsave();
			PSsetrgbcolor(.1,.2,.6);
			PSnewpath();
			PSmoveto(x1,y1);
			PSlineto(x2,y2);

			x1 = ln2->x1 - gx + xOffset;
			y1 = ln2->y1 - gy + yOffset;
			x2 = ln2->x2 - gx + xOffset;
			y2 = ln2->y2 - gy + yOffset;
			PSmoveto(x1,y1);
			PSlineto(x2,y2);
			PSstroke();
			PSgrestore();
		}
#endif
			if (((xSign(P1,L2)*xSign(P2,L2)) <= 0) &&
				((xSign(P3,L1)*xSign(P4,L1)) <= 0))
			{
				// lines intersect
				gln1 = ln1;
				gln2 = ln2;
				return YES;
			}

			if (packed2)
			{
				tpp = (NSPoint *)ln2;
				tpp++;
				ln2 = (XXLine *)tpp;
			}
			else ln2++;
		}
		if (packed1)
		{
			tpp = (NSPoint *)ln1;
			tpp++;
			ln1 = (XXLine *)tpp;
		}
		else ln1++;
	}
	return NO;
}

BOOL actorsCollide(Actor *a1, Actor *a2)
{
	Actor *a3;
	int i,j;

//	if (a1->alliance == a2->alliance ||
	if (a1 == a2 ||
			a1->alliance == NEUTRAL || a2->alliance == NEUTRAL ||
			!a1->employed || !a2->employed ||
		!NSIntersectsRect(a1->collisionRect,a2->collisionRect))
		return NO;

	if (a2->collisionShape < a1->collisionShape)
	{
		a3=a1;a1=a2;a2=a3;
	}

	a1->collisionThing = a2;
	a2->collisionThing = a1;

	switch(a1->collisionShape)
	{
	case NOSHAPE:
		return NO;
		break;
	case RECTCIRC:
		switch(a2->collisionShape)
		{
		case RECTCIRC:
		case RECT:
			a1->collisionReason = a2->collisionReason = ACTORSRECT;
			return YES;
		case RECTARRAY:
			if (!a2->complexShapePtr) [a2 constructComplexShape];
			for (i=0; i<a2->complexShapeCnt; i++)
			{
				if (NSIntersectsRect(a1->collisionRect,*(a2->complexShapePtr+i)))
				{
					a1->collisionReason = XRECT;
					a1->collisionThing = a2->complexShapePtr+i;
					a2->collisionReason = ACTORSRECT;
					return YES;
				}
			}
			return NO;
		case CIRCLE:
			if (intersectsCircle(a1,a2))
			{
				a1->collisionReason = a2->collisionReason = ACTORSCIRC;
				return YES;
			}
			return NO;
		case LINEARRAY:
			if (!a1->complexShapePtr)
			{
				rectToLines(&a1->collisionRect,a1->shapeArray, MINRECTSIZE);
				a1->complexShapePtr = (NSRect *)a1->shapeArray;
			}
			if (!a2->complexShapePtr) [a2 constructComplexShape];
			if (linesCollide((XXLine *)a1->shapeArray,4,YES,
						(XXLine *)a2->complexShapePtr,a2->complexShapeCnt,NO))
			{
				a1->collisionReason = a2->collisionReason = XLINE;
				a1->collisionThing = gln2;
				a2->collisionThing = gln1;
				return YES;
			}
			return NO;
		default:
			return NO;
		}
		break;

	case RECT:
		switch(a2->collisionShape)
		{
		case RECT:
			a1->collisionReason = a2->collisionReason = ACTORSRECT;
			return YES;
		case RECTARRAY:
			if (!a2->complexShapePtr) [a2 constructComplexShape];
			for (i=0; i<a2->complexShapeCnt; i++)
			{
				if (NSIntersectsRect(a1->collisionRect,*(a2->complexShapePtr+i)))
				{
					a1->collisionReason = XRECT;
					a1->collisionThing = a2->complexShapePtr+i;
					a2->collisionReason = ACTORSRECT;
					return YES;
				}
			}
			return NO;
		case CIRCLE:
			if (!a1->complexShapePtr)
			{
				rectToLines(&a1->collisionRect,a1->shapeArray, MINRECTSIZE);
				a1->complexShapePtr = (NSRect *)a1->shapeArray;
			}
			if (!a2->complexShapePtr)
			{
				circleToLines(a2,a2->shapeArray);
				a2->complexShapePtr = (NSRect *)a2->shapeArray;
			}
			if (linesCollide((XXLine *)a1->complexShapePtr,4,YES,
						(XXLine *)a2->complexShapePtr,4,YES))
			{
				a1->collisionReason = a2->collisionReason = XLINE;
				a1->collisionThing = gln2;
				a2->collisionThing = gln1;
				return YES;
			}
			return NO;
		case LINEARRAY:
			if (!a1->complexShapePtr)
			{
				rectToLines(&a1->collisionRect,a1->shapeArray, MINRECTSIZE);
				a1->complexShapePtr = (NSRect *)a1->shapeArray;
			}
			if (!a2->complexShapePtr) [a2 constructComplexShape];
			if (linesCollide((XXLine *)a1->complexShapePtr,4,YES,
						(XXLine *)a2->complexShapePtr,a2->complexShapeCnt,NO))
			{
				a1->collisionReason = a2->collisionReason = XLINE;
				a1->collisionThing = gln2;
				a2->collisionThing = gln1;
				return YES;
			}
			return NO;
		default:
			return NO;
		}
		break;

	case RECTARRAY:
		if (!a1->complexShapePtr) [a1 constructComplexShape];
		switch(a2->collisionShape)
		{
		case RECTARRAY:
			if (!a2->complexShapePtr) [a2 constructComplexShape];
			for (i=0; i<a1->complexShapeCnt; i++)
			{
				for (j=0; j<a2->complexShapeCnt; j++)
				{
					if (NSIntersectsRect(*(a1->complexShapePtr+i),*(a2->complexShapePtr+j)))
					{
						a1->collisionReason = a2->collisionReason = XRECT;
						a1->collisionThing = a2->complexShapePtr+j;
						a2->collisionThing = a1->complexShapePtr+i;
						return YES;
					}
				}
			}
			return NO;
		case CIRCLE:
			if (!a2->complexShapePtr)
			{
				circleToLines(a2,a2->shapeArray);
				a2->complexShapePtr = (NSRect *)a2->shapeArray;
			}
			for (i=0; i<a1->complexShapeCnt; i++)
			{
				rectToLines(a1->complexShapePtr+i,a1->shapeArray, MINRECTSIZE);
				if (linesCollide((XXLine *)a1->shapeArray,4,YES,
						(XXLine *)a2->complexShapePtr,4,YES))
				{
					a1->collisionReason = a2->collisionReason = XLINE;
					a1->collisionThing = gln2;
					a2->collisionThing = gln1;
					return YES;
				}
			}
			return NO;
		case LINEARRAY:
			if (!a2->complexShapePtr) [a2 constructComplexShape];
			for (i=0; i<a1->complexShapeCnt; i++)
			{
				rectToLines(a1->complexShapePtr+i,a1->shapeArray, MINRECTSIZE);
				if (linesCollide((XXLine *)a1->shapeArray,4,YES,
						(XXLine *)a2->complexShapePtr, a2->complexShapeCnt,NO))
				{
					a1->collisionReason = a2->collisionReason = XLINE;
					a1->collisionThing = gln2;
					a2->collisionThing = gln1;
					return YES;
				}
			}
			return NO;
		default:
			return NO;
		}
		break;

	case CIRCLE:
		switch(a2->collisionShape)
		{
		case CIRCLE:
			return intersectsCircle(a1,a2);
		case LINEARRAY:
			if (!a1->complexShapePtr)
			{
				circleToLines(a1,a1->shapeArray);
				a1->complexShapePtr = (NSRect *)a1->shapeArray;
			}
			if (!a2->complexShapePtr) [a2 constructComplexShape];
			if (linesCollide((XXLine *)a1->shapeArray,4,YES,
					(XXLine *)a2->complexShapePtr, a2->complexShapeCnt,NO))
			{
				a1->collisionReason = a2->collisionReason = XLINE;
				a1->collisionThing = gln2;
				a2->collisionThing = gln1;
				return YES;
			}
			return NO;
		default:
			return NO;
		}
		break;

	case LINEARRAY:
		switch(a2->collisionShape)
		{
		case LINEARRAY:
			if (!a1->complexShapePtr) [a1 constructComplexShape];
			if (!a2->complexShapePtr) [a2 constructComplexShape];
			if (linesCollide((XXLine *)a1->shapeArray, a1->complexShapeCnt,NO,
					(XXLine *)a2->complexShapePtr, a2->complexShapeCnt,NO))
			{
				a1->collisionReason = a2->collisionReason = XLINE;
				a1->collisionThing = gln2;
				a2->collisionThing = gln1;
				return YES;
			}
			return NO;
		default:
			return NO;
		}
		break;

	default:
		return NO;
	}
}






















