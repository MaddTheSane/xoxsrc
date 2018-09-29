
// collisions.h
// reasonably fast functions for collision detection on
// a few regular or complex shapes.  Algorithms favor speed over accuracy

#import <AppKit/AppKit.h>
#import "Actor.h"

extern BOOL intersectsRect(NSRect *r1, NSRect *r2) API_DEPRECATED_WITH_REPLACEMENT("NSIntersectsRect", macosx(10.0,10.0));
extern BOOL intersectsCircle(Actor *a1, Actor *a2);
extern void circleToLines(Actor *a1, NSPoint *pt);
extern void rectToLines(NSRect *rO, NSPoint *pt, int minSize);
extern BOOL linesCollide(XXLine *ln1, int cnt1, BOOL packed1,
			XXLine *ln2, int cnt2, BOOL packed2);
extern BOOL actorsCollide(Actor *a1, Actor *a2);
