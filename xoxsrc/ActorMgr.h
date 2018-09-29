
#import <AppKit/AppKit.h>
#import "xoxDefs.h"
#import "Actor.h"

@interface ActorMgr: NSObject
{
    IBOutlet NSMutableArray	*employedList;
    IBOutlet NSMutableArray	*retireList;
	int requestedLevel;
	NSMutableArray	*goodList, *badList, *destroyAllList;
	id collider;
	GAME_STATUS gameStatus;
}

- createCollisionLists;
- (void)makeActorsPerform:(SEL)action;
- (void)oneStep;
- (void)requestLevel:(int)lev;
- (void)_createLevel:(int)lev;
- (Actor *) newActor:(int)actorType for:sender tag:(int)tag;
- destroyActor:theActor;
- (void)draw;
@property (nonatomic) GAME_STATUS gameStatus;

@end

@interface NSObject (actorMgrAdditions)
// senders will be queried if newly activated actors will be added
// to employed list
- (BOOL) addToEmployedList:dude;
@end

@interface NSObject (newGameNotification)
- newGame;
@end
