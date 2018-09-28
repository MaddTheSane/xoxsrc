
#import "ActorMgr.h"
#import "Thinker.h"
#import "Ship.h"
#import "Asteroid.h"
#import "CacheManager.h"
#import "Scenario.h"
#import "GameInfo.h"
#import "ActorMatrix.h"
#import "KeyTimer.h"

int level;
id keyTimerList;
extern BOOL pauseState;

@implementation Object (actorMgrAdditions)
- (BOOL) addToEmployedList:dude
{	return YES;
}

@end

@implementation ActorMgr

- init
{
	[super init];

	employedList = [[List allocFromZone:[self zone]] init];
	retireList = [[List allocFromZone:[self zone]] init];

	goodList = [[List allocFromZone:[self zone]] init];
	badList = [[List allocFromZone:[self zone]] init];
	destroyAllList = [[List allocFromZone:[self zone]] init];
	keyTimerList = [[List allocFromZone:[self zone]] init];

	requestedLevel = -1;

	return self;
}

- createCollisionLists
{
	Actor *act;
	int i, count = [employedList count];
	for (i=0; i<count; i++)
	{
		act = (Actor *)[employedList objectAt:i];
		if ((act->x > gx + collisionDistance*xOffset) || 
			(act->x < gx - collisionDistance*xOffset) || 
			(act->y > gy + collisionDistance*yOffset) || 
			(act->y < gy - collisionDistance*yOffset) ||
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
	int i, j, count, count2;
	Actor *actor1, *actor2;
	id list1=nil, list2=nil;
	COLLISION_PARADIGM how2collide;

	how2collide = [scenario collisionParadigm];

	if (how2collide == GOOD_V_EVIL)
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
				actor1 = (Actor *)[list1 objectAt:i];
				actor2 = (Actor *)[list2 objectAt:j];
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
	else if (how2collide == ALL_V_ALL)
	{	// unoptimized, collide all objects against each other
		count = [employedList count];
		for (i=0; i<count-1; i++)
		for (j=i+1; j<count; j++)
		{
			actor1 = (Actor *)[employedList objectAt:i];
			actor2 = (Actor *)[employedList objectAt:j];

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

- makeActorsPerform:(SEL)action
{
	[employedList performInOrder:action];
	return self;
}

- oneStep
{
	int i, count;
	Actor *actor1;

	if (requestedLevel >= 0)
	{
		[self _createLevel:requestedLevel];
		[[gameList objectAt: gameIndex] setLevel:requestedLevel];
		requestedLevel = -1;
	}

	[keyTimerList performInOrder:@selector(preOneStep)];

	[employedList performInOrder:@selector(oneStep)];

	if (gameStatus == GAME_RUNNING)
		[collider doCollisions];

	// retire actors as necessary
	count = [retireList count];
	for (i=0; i<count; i++)
	{
		actor1 = (Actor *)[retireList objectAt:i];
		if (!actor1->employed)
			[employedList removeObject:actor1];
	}
	[retireList empty];
	[goodList empty];
	[badList empty];
	[destroyAllList empty];

	[employedList performInOrder:@selector(scheduleDrawing)];
	[keyTimerList performInOrder:@selector(postOneStep)];

	return self;
}

- requestLevel:(int)lev
{
	requestedLevel = lev;
	return self;
}

// This method begins with an underbar because it's not safe for
// actors to call it in the midst of the animation cycle.
- _createLevel:(int)lev
{
	[employedList performInOrder:@selector(retire)];
	[employedList empty];
	[retireList empty];

	if (lev == 0)
	{
		lev = 1;
		if ([scenario respondsTo:@selector(newGame)])
				[scenario newGame];
	}
	[scenario _createLevel:lev];

	level = lev;

	if ([scenario respondsTo:@selector(collisionDelegate)])
		collider = [scenario collisionDelegate];
	else collider = self;

	[mainView display];
	[cacheMgr eraseCache];
	return self;
}

- (Actor *) newActor:(int)actorType for:sender tag:(int)tag
{
	List *theList;
	Actor *theActor = nil;
	int i, count;
	BOOL found = NO;

	theList = [(id)actorType instanceList];
	count = [theList count];

	for (i=0; i<count; i++)
	{
		theActor = (Actor *)[theList objectAt:i];
		if (!(theActor->employed))
		{
			found = YES;
			break;
		}
	}
	
	if (!found)
	{
		id myClass = (id)actorType;
		theActor = [[myClass allocFromZone:[self zone]] init];
	}

	[theActor activate:sender :tag];
	[scenario didActivate:theActor];

	if ([sender addToEmployedList:theActor])
		[employedList addObjectIfAbsent:theActor];

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

- draw
{
	[employedList performInOrder:@selector(calcDrawRect)];
	[employedList performInOrder:@selector(draw)];
	return self;
}

- setGameStatus:(GAME_STATUS)gs
{
	id thinker = [NSApp delegate];

	gameStatus = gs;
	switch (gameStatus)
	{
	case GAME_RUNNING:
		[thinker setPauseState:(pauseState & ~(16 | 32))];
		break;
	case GAME_PAUSED:
		[thinker setPauseState:(pauseState | 16)];
		break;
	case GAME_DYING:
		break;
	case GAME_DEAD:
		[thinker setPauseState:(pauseState | 32)];
		break;
	}

	[[gameList objectAt: gameIndex] setStatus:gameStatus];

	return self;
}

- (GAME_STATUS)gameStatus
{
	return gameStatus;
}

@end










