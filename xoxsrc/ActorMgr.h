
#import <AppKit/AppKit.h>
#import "xoxDefs.h"
#import "Actor.h"

@interface ActorMgr: NSObject
{
    id	employedList;
    id	retireList;
	int requestedLevel;
	id	goodList, badList, destroyAllList;
	id collider;
	GAME_STATUS gameStatus;
}

- createCollisionLists;
- makeActorsPerform:(SEL)action;
- oneStep;
- requestLevel:(int)lev;
- _createLevel:(int)lev;
- (Actor *) newActor:(int)actorType for:sender tag:(int)tag;
- destroyActor:theActor;
- draw;
- (void)setGameStatus:(GAME_STATUS)gs;
- (GAME_STATUS)gameStatus;

@end

@interface NSObject (actorMgrAdditions)
// senders will be queried if newly activated actors will be added
// to employed list
- (BOOL) addToEmployedList:dude;
@end

@interface NSObject (newGameNotification)
- newGame;
@end
