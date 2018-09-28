
#import "Actor.h"
#import <objc/Storage.h>

@interface ActorMatrix:Actor
{
	Storage *formation;
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
- makeActorsPerform:(SEL)func;
- perform:(SEL)func cols:(int)begc :(int)endc rows:(int)begr :(int)endr;
- (BOOL) rowsNcols:(NXRect *)r myRect:(NXRect *)myRect
		:(int *)begc :(int *)endc :(int *)begr :(int *)endr;


@end

@interface Storage (gimmeTheData)
- (id *) idAt:(int)ndx;
- actorAt:(int)ndx;
- replaceActorAt:(unsigned int)index with:theActor;
@end

typedef struct {
	BOOL autofill;
	id whichClass;
	ALLIANCE alliance;
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


