//
//  GameInfo.h
//

#import <AppKit/AppKit.h>
#import "xoxDefs.h"
#import "Scenario.h"

@interface GameInfo: NSObject
{
	id<Scenario>	scenario;
	NSString *scenarioName;
	NSString *path;
	NSMutableArray<NSString*> *altPaths;
	int level;
	XoXGameStatus gameStatus;
}

- (id)init;
- initWithScenario:(id<Scenario>)aScenario name:(NSString *)aName path:(NSString *)aPath;
- (void)setScenario:(id<Scenario>)newScenario;
- (id<Scenario>)scenario;
@property (readonly, copy) NSString *scenarioName;
@property (copy) NSString *path;
- (void)appendPath: (NSString *)p;
- (BOOL)useNextPath;
- (void)discardAltPaths;
- (int) setLevel:(int)newLevel;
- (int) level;
- (XoXGameStatus) setStatus:(XoXGameStatus)newStatus;
- (XoXGameStatus)status;

@end


@interface GameList:NSMutableArray<GameInfo*>

- (NSString *) nameAtIndex: (NSInteger) i;
- (id<Scenario>)scenarioAtIndex: (NSInteger) i;
- (void)sort;

@end
