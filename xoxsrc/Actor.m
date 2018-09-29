
#import "Actor.h"
#import "ActorMgr.h"
#import "DisplayManager.h"
#import "CacheManager.h"
#import "collisions.h"
#import <math.h>

extern BOOL coalesce(NSRect *p1, NSRect *p2);

CGFloat gx, gy;

@implementation Actor
@synthesize vel;
@synthesize theta;

// Each Actor subclass keeps a list of its instances; instances are never freed
// since they come and go frequently and allocating them is too expensive.
// Instead, the actor manager walks this list and reuses available actors.
// Plus, since they're never killed, they can wait tables on the side.
+ instanceList
{
	static NSMutableDictionary<NSString*,NSMutableArray*> *mos;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		mos = [[NSMutableDictionary alloc] init];
	});
	if (mos[NSStringFromClass(self.class)] == nil) {
		mos[NSStringFromClass(self.class)] = [[NSMutableArray alloc] init];
	}
	return mos;						// Ack!
}

- init
{
	if (self = [super init]) {
	actorType = (uintptr_t)[self class];
	[(NSMutableArray*)[[self class] instanceList] addObject:self];
	}
	return self;
}

#define S_DEBUG 0

// note that this method is _not_ the object's designated initializer;
// this method may be called more than once (by activate)
- (void)reinitWithImage:(const char *)imageName
	frameSize:(NSSize *) size
	numFrames:(int)frames
	shape: (COLLISION_SHAPE)shape
	alliance: (ALLIANCE)al
	radius: (float) r
	buffered: (BOOL) b
	x: (float)xp
	y: (float)yp
	theta: (float) thta
	vel: (float) v
	interval: (unsigned) time
	distToCorner: (NSSize *)d2c
{
	[self reinitWithImage:@(imageName) frameSize:*size numFrames:frames shape:shape alliance:al radius:r buffered:b point:NSMakePoint(xp, yp) theta:thta vel:v interval:time distToCorner:*d2c];
}

- (void)reinitWithImage:(NSImageName)imageName
			  frameSize:(NSSize) size
			  numFrames:(int)frames
				  shape: (COLLISION_SHAPE)shape
			   alliance: (ALLIANCE)al
				 radius: (CGFloat) r
			   buffered: (BOOL) b
				  point: (NSPoint) pt
				  theta: (CGFloat) thta
					vel: (CGFloat) v
			   interval: (unsigned) time
		   distToCorner: (NSSize)d2c;
{
	image = [self findImageNamed:imageName];

	frame = 0;
	interval = time;
	changeTime = timeInMS+time;

	numFrames = frames;
	frameSize = size;
	theta = thta;
	vel = v;
	xv = vel * -sin(theta);
	yv = vel * cos(theta);
	collisionShape = shape;
	alliance = al;
	radius = r;
	buffered = b;

	drawRect.size = size;
	collisionRect.size = size;
	distToCorner = d2c;
	[self moveToPoint:pt];

	complexShapePtr = NULL;
	eraseRect.size.width = 0;
}

// The ActorManager means objects don't necessarily get created and freed;
// instead they are created once and then activated and retired.
- activate:sender :(int)tag
{
	employed = YES;
	scoreTaker = sender;
	return self;
}

- (void)retire
{
//	[self erase];
	if (buffered && (eraseRect.size.width > 0))
		[cacheMgr displayRect:eraseRect];
	employed = NO;
}

- (void)erase
{
	id<DrawManager> mgr = (buffered ? cacheMgr : displayMgr);
	[mgr erase:eraseRect];
	if (!buffered) eraseRect.size.width = 0;
}

- (void)positionChanged
{
	if (timeInMS > changeTime)
	{
		changeTime = timeInMS + interval;
		if (++frame >= numFrames) frame = 0;
	}
}

- (void)calcDxDy:(inout NSPoint *)dp
{
	dp->x = timeScale * xv;
	dp->y = timeScale * yv;
}

- (void)calcDrawRect
{
	drawRect.origin.x = floor(point.x - gx - distToCorner.width + xOffset);
	drawRect.origin.y = floor(point.y - gy - distToCorner.height + yOffset);
}

- (void)moveBy:(float)dx :(float)dy
{
	point.x += dx;
	collisionRect.origin.x += dx;
	point.y += dy;
	collisionRect.origin.y += dy;

	// calculate offset into view
	[self calcDrawRect];
}

- (void)moveTo:(float)newx :(float)newy
{
	[self moveToPoint:NSMakePoint(newx, newy)];
}
- (void)moveToPoint:(NSPoint)pt
{
	point = pt;
	collisionRect.origin.x = point.x - distToCorner.width;
	collisionRect.origin.y = point.y - distToCorner.height;
	[self calcDrawRect];
}

- (void)setXvYv:(float)xvel :(float)yvel sync:(BOOL)sync
{
	xv = xvel;
	yv = yvel;
	if (sync)
	{
		theta = atan2(yvel, xvel);
		vel = sqrt(xv*xv + yv*yv);
	}
}

- (void)setVel:(float)newVel theta:(float)newTheta sync:(BOOL)sync
{
	self.vel = newVel;
	self.theta = newTheta;
	if (sync)
	{
		xv = vel * -sin(theta);
		yv = vel * cos(theta);
	}
}

- (void)oneStep
{
	NSPoint dXdY;

	if (NSIntersectsRect(screenRect, eraseRect))
	{
		[self erase];
	}

	[self calcDxDy: &dXdY];

	[self moveBy:dXdY.x :dXdY.y];

	complexShapePtr = NULL;

	[self positionChanged];
}

- (void)scheduleDrawing
{
	id mgr = (buffered ? cacheMgr : displayMgr);
	if (employed && NSIntersectsRect(screenRect, drawRect))
	{
		[mgr draw:self];
		if (buffered)
		{
			[self addFlushRects];
		}
//		eraseRect = drawRect;
	}
	else if ((eraseRect.size.width > 0) && buffered)
	{
		// we have an erasure region to flush to the screen
		[cacheMgr displayRect:eraseRect];
		eraseRect.size.width = 0;
	}
}

- (void)draw
{
	NSRect src;
	src.origin.x = (frame & 3) * frameSize.width;
	src.origin.y = (frame >> 2) * frameSize.height;
	src.size = drawRect.size = frameSize;
	
	[image drawAtPoint:drawRect.origin fromRect:src operation:NSCompositingOperationSourceOver fraction:1];
	eraseRect = drawRect;

#if S_DEBUG
	{
		NSRect t = collisionRect;
		t.origin.x = floor(collisionRect.origin.x - gx + xOffset);
		t.origin.y = floor(collisionRect.origin.y - gy + yOffset);
		PSsetrgbcolor(1,0,0);
		NXFrameRect(&t);
		PSnewpath();
		PSsetrgbcolor(0,1,0);
		PSarc(floor(x - gx + xOffset), floor(y - gy + yOffset), 
			radius-1, 0.0, 360.0);
		PSclosepath();
		PSstroke();
	}
#endif
}

// an actor will be sent a tile message when it is time to draw something
// in the virgin buffered background.  This is good for static images so you
// only draw them once.  Most actors move and thus shouldn't draw anything here.
// focus is locked on the virgin buffer when this is called
- (void)tile
{
	
}

// both actors that have collided will be sent a doYouHurt: message to determine if the 
// other will be sent a performCollisionWith: message.  You could use this opportunity to
// store the other's pre-collision vector, if you care about it.

- (BOOL) doYouHurt:sender
{	return YES;
}

- (void)performCollisionWith:(Actor *) dude
{
	if (pointValue) [dude addToScore:pointValue for:self gen:0];
	[actorMgr destroyActor:self];
}

- (BOOL) wrapAtDistance:(float)distx :(float)disty
{
	float dx = 0, dy = 0;
	BOOL didWrap = NO;

	// warp things around as necessary...
	if (point.x > gx + distx)
	{
		dx = -2*distx;
		didWrap = YES;
	}
	else if (point.x < gx - distx)
	{
		dx = 2*distx;
		didWrap = YES;
	}

	if (point.y > gy + disty)
	{
		dy = -2*disty;
		didWrap = YES;
	}
	else if (point.y < gy - disty)
	{
		dy = 2*disty;
		didWrap = YES;
	}
	if (didWrap) [self moveBy:dx :dy];

	return didWrap;
}

- (BOOL) bounceAtDistance:(float)distx :(float)disty
{
	CGFloat dx=0,dy=0;
	BOOL didBounce = NO;

	if (point.x > gx + distx)
	{
		dx = (gx + distx) - point.x;
		if (xv > 0) xv = 0 - xv;
		didBounce = YES;
	}
	else if (point.x < gx - distx)
	{
		dx = (gx - distx) - point.x;
		if (xv < 0) xv = 0 - xv;
		didBounce = YES;
	}

	if (point.y > gy + disty)
	{
		dy = (gy + disty) - point.y;
		if (yv > 0) yv = 0 - yv;
		didBounce = YES;
	}
	else if (point.y < gy - disty)
	{
		dy = (gy - disty) - point.y;
		if (yv < 0) yv = 0 - yv;
		didBounce = YES;
	}

	if (didBounce) [self moveBy:dx :dy];

	return didBounce;
}

#define xabs(x) (x >= 0 ? x : 0-x)
extern XXLine *gln2;

// this is a really quick and dirty hack that hopefully is good
// enough to implement a believable bounce off of a nearly
// stationary rectangular object
// (should be more accurate and probably part of a better mechanism
// for bouncing 2 moving arbitrary shape Actors off each other)
- (int) bounceOff:(Actor *)dude
{
	XXLine vector[3], line[2], t;
	NSPoint pts[3];
	float dx, dy;
	int i, ret=0;
	XXLine *horozLn = &line[0];

	line[0].x1 = dude->collisionRect.origin.x;
	line[0].x2 = dude->collisionRect.origin.x + dude->collisionRect.size.width;
	line[1].y1 = dude->collisionRect.origin.y;
	line[1].y2 = dude->collisionRect.origin.y + dude->collisionRect.size.height;
	if (yv > 0)
	{
		line[0].y1 = line[0].y2 = dude->collisionRect.origin.y;
	}
	else
	{
		line[0].y1 = line[0].y2 = dude->collisionRect.origin.y +
			dude->collisionRect.size.height;
	}
	if (xv > 0)
	{
		line[1].x1 = line[1].x2 = dude->collisionRect.origin.x;
	}
	else
	{
		line[1].x1 = line[1].x2 = dude->collisionRect.origin.x +
			dude->collisionRect.size.width;
	}

	if (xabs(xv) > xabs(yv))	// then favor horozontal collisions
	{
		t=line[0]; line[0]=line[1]; line[1]=t;
		horozLn = &line[1];
	}


	dx = xv * 1024.;
	dy = yv * 1024.;
	pts[0].x = point.x;
	pts[0].y = point.y;
	pts[1].x = point.x - distToCorner.width;
	pts[2].x = point.x + distToCorner.width;
	if ((xv*yv) > 0.0)
	{
		pts[1].y = point.y + distToCorner.height;
		pts[2].y = point.y - distToCorner.height;
	}
	else
	{
		pts[1].y = point.y - distToCorner.height;
		pts[2].y = point.y + distToCorner.height;
	}

	for (i=0; i<3; i++)
	{
		vector[i].x1 = pts[i].x - dx;
		vector[i].x2 = pts[i].x + dx;
		vector[i].y1 = pts[i].y - dy;
		vector[i].y2 = pts[i].y + dy;
	}

	if ((linesCollide(vector,3,NO, line, 2, NO)) && (gln2 == horozLn))
	{
		if (yv > 0)	// bounce off bottom
		{
			[self moveTo:point.x :horozLn->y1-distToCorner.height];
			[self setXvYv:xv :-yv sync:NO];
			ret = 1;
		}
		else		// bounce off top
		{
			[self moveTo:point.x :horozLn->y1+distToCorner.height];
			[self setXvYv:xv :-yv sync:NO];
			ret = 2;
		}
	}
	else
	{
		if (xv > 0)	// bounce off left
		{
			[self moveTo:horozLn->x1-distToCorner.width :point.y];
			[self setXvYv:-xv :yv sync:NO];
			ret = 3;
		}
		else		// bounce off top
		{
			[self moveTo:horozLn->x2+distToCorner.width :point.y];
			[self setXvYv:-xv :yv sync:NO];
			ret = 4;
		}
	}
	return ret;
}



// override in subclasses to lazily construct coords for rotated rects
// or rect lists
- constructComplexShape
{
	return self;
}

+ (NSImage*)findImageNamed:(NSImageName)name
{
	NSImage *ret_image = [NSImage imageNamed:name];
	if (!ret_image)
	{
		ret_image = [[NSBundle bundleForClass:[self class]] imageForResource:name];
	}
	if (!ret_image)
	{
		NSString *path = [[NSBundle bundleForClass:[self class]] pathForImageResource:name];
		if (!path) {
			path = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"tiff"];
		}
		if (path)
		{
			ret_image = [[NSImage alloc]
				initWithContentsOfFile:path];
			[ret_image setName:name];
		}
	}
	return ret_image;
}

- findImageNamed:(NSString *)name
{
	return [[self class] findImageNamed:name];
}

+ (void)cacheImage:(NSImageName)name
{
	NSImage *timage;
	timage = [self findImageNamed:name];
	[timage lockFocus]; [timage unlockFocus];
}

- (int)addToScore:(int)val for:dude gen:(int)age
{
	if (age < 2)
		return [scoreTaker addToScore:val for:self gen:age+1];
	else return 0;
}

- (void)addFlushRects
{
	if (!coalesce(&eraseRect, &drawRect))
	{
		[cacheMgr displayRect:drawRect];
	}
	if (eraseRect.size.width > 0)
		[cacheMgr displayRect:eraseRect];
}

- (BOOL) isGroup
{	return NO;
}

@end

@implementation NSObject (scoreKeepingMethods)
- (int)setScore:(int)val for:dude
{
	return 0;
}

- (int)addToScore:(int)val for:dude gen:(int)age
{
	return 0;
}

- (int)score;
{
	return 0;
}

@end










