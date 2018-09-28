
// collisions.h
// reasonably fast functions for collision detection on
// a few regular or complex shapes.  Algorithms favor speed over accuracy

#import <appkit/appkit.h>
#import "Actor.h"

extern BOOL intersectsRect(NXRect *r1, NXRect *r2);
extern BOOL intersectsCircle(Actor *a1, Actor *a2);
extern void circleToLines(Actor *a1, NXPoint *pt);
extern void rectToLines(NXRect *rO, NXPoint *pt, int minSize);
extern BOOL linesCollide(XXLine *ln1, int cnt1, BOOL packed1,
			XXLine *ln2, int cnt2, BOOL packed2);
extern BOOL actorsCollide(Actor *a1, Actor *a2);
