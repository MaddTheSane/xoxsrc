
#import "Actor.h"
#import <Foundation/Foundation.h>

@interface ActorMatrix:Actor
{
	NSArray *formation;
    int rows;
	int columns;
	float actWidth;
	float actHeight;
	float xgap;
	float ygap;
	int bc, ec, br, er;
	int actorCount;
	BOOL modifyThetas;
	BOOL rNc;
}

- addToFormation: whichClass tag:(int)tag at:(int)col :(int)row;
- nukeActorAt:(int)col :(int)row;
- (void)makeActorsPerformSelector:(SEL)func;
- perform:(SEL)func cols:(int)begc :(int)endc rows:(int)begr :(int)endr;
- (BOOL) rowsNcols:(NSRect *)r myRect:(NSRect *)myRect
		:(int *)begc :(int *)endc :(int *)begr :(int *)endr;


@end

typedef struct ActorMatrixData {
	BOOL autofill;
	id whichClass;
	XoXAlliance alliance;
	float x;
	float y;
	float theta;
	float vel;
	int rows;
	int columns;
	float xgap;
	float ygap;
	float actWidth;
	float actHeight;
	unsigned interval;
	BOOL modifyThetas;
} MatrixData;
