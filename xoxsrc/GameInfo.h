//
//  GameInfo.h
//

#import <AppKit/AppKit.h>
#import "xoxDefs.h"

@interface GameInfo: NSObject
{
	id	scenario;
	char *scenarioName;
	char *path;
	char *altPaths;
	int level;
	GAME_STATUS gameStatus;
}

- (id)init;
- initWithScenario:aScenario name:(const char *)aName path:(const char *)aPath;
- setScenario:newScenario;
- scenario;
- (const char *) scenarioName;
- (const char *) path;
- setPath: (const char *)p;
- appendPath: (const char *)p;
- useNextPath;
- discardAltPaths;
- free;
- (int) setLevel:(int)newLevel;
- (int) level;
- (GAME_STATUS) setStatus:(GAME_STATUS)newStatus;
- (GAME_STATUS)status;

@end


@interface GameList:List
{
}

- (const char *) nameAt: (int) i;
- scenarioAt: (int) i;
- sort;

@end
