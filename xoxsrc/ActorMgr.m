
#import "ActorMgr.h"
#import "Thinker.h"
#import "Ship.h"
#import "Asteroid.h"
#import "CacheManager.h"
#import "Scenario.h"
#import "GameInfo.h"
#import "ActorMatrix.h"
#import "KeyTimer.h"
#import "Thinker.h"

int level;
id keyTimerList;
extern BOOL pauseState;

@implementation NSObject (actorMgrAdditions)
- (BOOL) addToEmployedList:dude
{	return YES;
}

@end

@implementation ActorMgr

- init
{
	if (self = [super init]) {

	employedList = [[NSMutableArray alloc] init];
	retireList = [[NSMutableArray alloc] init];

	goodList = [[NSMutableArray alloc] init];
	badList = [[NSMutableArray alloc] init];
	destroyAllList = [[NSMutableArray alloc] init];
	keyTimerList = [[NSMutableArray alloc] init];

	requestedLevel = -1;
	}

	return self;
}

- createCollisionLists
{
	Actor *act;
	NSInteger i, count = [employedList count];
	for (i=0; i<count; i++)
	{
		act = (Actor *)[employedList objectAtIndex:i];
		if ((act->point.x > gx + collisionDistance*xOffset) ||
			(act->point.x < gx - collisionDistance*xOffset) ||
			(act->point.y > gy + collisionDistance*yOffset) ||
			(act->point.y < gy - collisionDistance*yOffset) ||
				!act->employed)
			continue;
		switch((int)(act->alliance))
		{
			case GOOD:
				[goodList addObject:act];
				break;
			case EVIL:
				[badList addObject:act];
				break;
			case DESTROYALL:
				[destroyAllList addObject:act];
				break;
			// these will be collided twice against destroyall actors
			case GOODNBAD:
				[goodList addObject:act];
				[badList addObject:act];
				break;
		}
	}
	return self;
}


- doCollisions
{
	NSInteger i, j, count, count2;
	Actor *actor1, *actor2;
	NSArray *list1=nil, *list2=nil;
	XoXCollisionParadigm how2collide;

	how2collide = [scenario collisionParadigm];

	if (how2collide == XoXCollisionGoodVersusEvil)
	{	int k;

		[self createCollisionLists];
		for (k=0; k<3; k++)
		{
			switch (k)
			{
			case 0:
				list1 = destroyAllList;
				list2 = goodList;
				break;
			case 1:
				list1 = destroyAllList;
				list2 = badList;
				break;
			case 2:
				list1 = goodList;
				list2 = badList;
				break;
			}
			count = [list1 count];
			count2 = [list2 count];
			for (i=0; i<count; i++)
			for (j=0; j<count2; j++)
			{
				actor1 = (Actor *)[list1 objectAtIndex:i];
				actor2 = (Actor *)[list2 objectAtIndex:j];
				if (actorsCollide(actor1,actor2))
//				if ([actor1 collideWith:actor2])
				{
					BOOL h1, h2;
					h1 = [actor2 doYouHurt:actor1];
					h2 = [actor1 doYouHurt:actor2];
					if (h1) [actor1 performCollisionWith:actor2];
					if (h2) [actor2 performCollisionWith:actor1];
				}
			}
		}
	}
	else if (how2collide ==     XoXCollisionAllVersusAll)
	{	// unoptimized, collide all objects against each other
		count = [employedList count];
		for (i=0; i<count-1; i++)
		for (j=i+1; j<count; j++)
		{
			actor1 = (Actor *)[employedList objectAtIndex:i];
			actor2 = (Actor *)[employedList objectAtIndex:j];

			if (actorsCollide(actor1,actor2))
//			if ([actor1 collideWith:actor2])
			{
				BOOL h1, h2;
				h1 = [actor2 doYouHurt:actor1];
				h2 = [actor1 doYouHurt:actor2];
				if (h1) [actor1 performCollisionWith:actor2];
				if (h2) [actor2 performCollisionWith:actor1];
			}
		}
	}
	else
	{
		// no collision paradigm recognized
	}
	return self;
}

- (void)makeActorsPerform:(SEL)action
{
	[employedList makeObjectsPerformSelector:action];
}

- (void)oneStep
{
	NSInteger i, count;
	Actor *actor1;

	if (requestedLevel >= 0)
	{
		[self _createLevel:requestedLevel];
		[[gameList objectAtIndex: gameIndex] setLevel:requestedLevel];
		requestedLevel = -1;
	}

	[keyTimerList makeObjectsPerformSelector:@selector(preOneStep)];

	[employedList makeObjectsPerformSelector:@selector(oneStep)];

	if (gameStatus == XoXGameRunning)
		[collider doCollisions];

	// retire actors as necessary
	count = [retireList count];
	for (i=0; i<count; i++)
	{
		actor1 = (Actor *)[retireList objectAtIndex:i];
		if (!actor1->employed)
			[employedList removeObject:actor1];
	}
	[retireList removeAllObjects];
	[goodList removeAllObjects];
	[badList removeAllObjects];
	[destroyAllList removeAllObjects];

	[employedList makeObjectsPerformSelector:@selector(scheduleDrawing)];
	[keyTimerList makeObjectsPerformSelector:@selector(postOneStep)];
}

- (void)requestLevel:(int)lev
{
	requestedLevel = lev;
}

// This method begins with an underbar because it's not safe for
// actors to call it in the midst of the animation cycle.
- (void)_createLevel:(int)lev
{
	[employedList makeObjectsPerformSelector:@selector(retire)];
	[employedList removeAllObjects];
	[retireList removeAllObjects];

	if (lev == 0)
	{
		lev = 1;
		if ([scenario respondsToSelector:@selector(newGame)])
				[scenario newGame];
	}
	[scenario _createLevel:lev];

	level = lev;

	if ([scenario respondsToSelector:@selector(collisionDelegate)])
		collider = [scenario collisionDelegate];
	else collider = self;

	[mainView display];
	[cacheMgr eraseCache];
}

- (Actor *) newActor:(int)actorType for:sender tag:(int)tag
{
	NSMutableArray *theList;
	Actor *theActor = nil;
	NSInteger i, count;
	BOOL found = NO;

	theList = [(id)actorType instanceList];
	count = [theList count];

	for (i=0; i<count; i++)
	{
		theActor = (Actor *)[theList objectAtIndex:i];
		if (!(theActor->employed))
		{
			found = YES;
			break;
		}
	}
	
	if (!found)
	{
		id myClass = (id)actorType;
		theActor = [[myClass alloc] init];
	}

	[theActor activate:sender :tag];
	[scenario didActivate:theActor];

	if ([sender addToEmployedList:theActor])
		[employedList addObject:theActor];

	return theActor;
}

- destroyActor:(Actor *)theActor
{
	if (theActor && (theActor->employed))
	{
		[theActor retire];
		[scenario didRetire:theActor];
		[retireList addObject: theActor];
	}
	return self;
}

- (void)draw
{
	[employedList makeObjectsPerformSelector:@selector(calcDrawRect)];
	[employedList makeObjectsPerformSelector:@selector(draw)];
}

- (void)setGameStatus:(XoXGameStatus)gs
{
	id thinker = [NSApp delegate];

	gameStatus = gs;
	switch (gameStatus)
	{
	case XoXGameRunning:
		[thinker setPauseState:(pauseState & ~(16 | 32))];
		break;
	case XoXGamePaused:
		[thinker setPauseState:(pauseState | 16)];
		break;
	case XoXGameDying:
		break;
	case XoXGameDead:
		[thinker setPauseState:(pauseState | 32)];
		break;
	}

	[[gameList objectAtIndex: gameIndex] setStatus:gameStatus];
}

@synthesize gameStatus;

@end










