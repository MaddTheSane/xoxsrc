// An actor is something that animates in Xox or otherwise requires 
// notification of every frame.  You generally shouldn't directly invoke
// the methods in there; they are hooks for subclassing and most are
// notifications sent only by the various managers.

#import <AppKit/AppKit.h>
#import "xoxDefs.h"

@interface Actor: NSObject
{
// make 'em all public, I wanna peek!
@public
	int numFrames;
	int frame;
	NSSize frameSize;
	NSImage *image;
	BOOL employed;
	CGFloat theta;			// generally the direction of travel
	CGFloat vel;				// used to determine xv & yv
	CGFloat xv, yv;
	CGFloat x, y;				// centroid position in universe
	unsigned changeTime;
	int interval;
	COLLISION_SHAPE collisionShape;
	ALLIANCE alliance;
	TIER tier;
	NSRect drawRect;		// position in cache
	NSRect eraseRect;		// optimization, draw rect likely to overlap erasure
	NSRect collisionRect;	// position in universe
	CGFloat radius;			// used for circular collisions
	BOOL buffered;
	NSSize distToCorner;
	int actorType;

	NSRect *complexShapePtr;	// a pointer to rect list or lines, as necessary
	int complexShapeCnt;
	NSPoint shapeArray[5];		// area for converting rects and circs to lines
								// may be used as scratch area by collision manager
	int pointValue;
	id scoreTaker;

	COLLISION_REASON collisionReason;	// indicates what collisionThing points to
	void *collisionThing;			// info about why collision happened.
}

+ (NSArray<__kindof Actor*>*)instanceList;

//! this method reinitializes an Actor, it may be called many times
//! typically from within activate
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
	distToCorner: (NSSize *)d2c;

//! this method reinitializes an Actor, it may be called many times
//! typically from within activate
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

// only sent by the actor manager, should reintialize the object
- activate:sender :(int)tag;

// only sent by the actor manager
- (void)retire;

- (void)erase;

- positionChanged;
- (void)calcDxDy:(inout NSPoint *)dp;
- (void)calcDrawRect;
- (void)moveBy:(float)dx :(float)dy;
- (void)moveTo:(float)newx :(float)newy;
- (void)moveToPoint:(NSPoint)pt;

- (void)setXvYv:(float)xvel :(float)yvel sync:(BOOL)sync;
- (void)setVel:(float)newVel theta:(float)newTheta sync:(BOOL)sync;
@property CGFloat vel;
@property CGFloat theta;
- (void)oneStep;
- (void)scheduleDrawing;
- (void)draw;
- (void)tile;
// - (BOOL) collideWith:(Actor *) dude;
- (BOOL) doYouHurt:sender;
- (void)performCollisionWith:(Actor *) dude;
- (BOOL) wrapAtDistance:(float)distx :(float)disty;
- (BOOL) bounceAtDistance:(float)distx :(float)disty;
- (int) bounceOff:(Actor *)dude;
- constructComplexShape;
- (NSImage*)findImageNamed:(NSImageName)name;
+ (NSImage*)findImageNamed:(NSImageName)name;
+ (void)cacheImage:(NSImageName)name;
- addFlushRects;
- (BOOL) isGroup;

@end

extern BOOL actorsCollide(Actor *a1, Actor *a2);

@protocol ActorScoreKeepingMethods <NSObject>

- (int)setScore:(int)val for:dude;
- (int)addToScore:(int)val for:dude gen:(int)age;
- (int)score;
@end









