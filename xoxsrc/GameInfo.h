//
//  GameInfo.h
//

#import <AppKit/AppKit.h>
#import "xoxDefs.h"

@interface GameInfo: NSObject
{
	id	scenario;
	NSString *scenarioName;
	NSString *path;
	char *altPaths;
	int level;
	GAME_STATUS gameStatus;
}

- (id)init;
- initWithScenario:aScenario name:(NSString *)aName path:(NSString *)aPath;
- setScenario:newScenario;
- scenario;
@property (readonly, copy) NSString *scenarioName;
@property (copy) NSString *path;
- appendPath: (const char *)p;
- useNextPath;
- discardAltPaths;
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
