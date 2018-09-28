// Objects that implement the Scenario protocol are asked to create each
// Xox level.  Thus, Scenarios create the games that Xox drives.

#import <appkit/appkit.h>
#import "Actor.h"
#import "xoxDefs.h"

@protocol Scenario

// invoked only by the actor manager
- _createLevel:(int)lev;

- infoView;
- didActivate:(Actor *)theActor;
- didRetire:(Actor *)theActor;

- keyDown:(NXEvent *)theEvent;
- keyUp:(NXEvent *)theEvent;

- scenarioSelected;
- scenarioDeselected;

- (COLLISION_PARADIGM)collisionParadigm;

@end


@interface Object (optionalScenarioMethods)

- collisionDelegate;		// who performs collisions?
- tile;						// invoked to tile the game window
- newSize:(NXSize *)s;		// notification of new view size
- (BOOL)newWindowContentSize:(NXSize *)s;

@end
