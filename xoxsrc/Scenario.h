// Objects that implement the Scenario protocol are asked to create each
// Xox level.  Thus, Scenarios create the games that Xox drives.

#import <AppKit/AppKit.h>
#import "Actor.h"
#import "xoxDefs.h"

/// Objects that implement the Scenario protocol are asked to create each
/// Xox level.  Thus, Scenarios create the games that Xox drives.
@protocol Scenario <NSObject>

// invoked only by the actor manager
- (void)_createLevel:(int)lev;

- (NSView*)infoView;
- (void)didActivate:(Actor *)theActor;
- (void)didRetire:(Actor *)theActor;

- (void)keyDown:(NSEvent *)theEvent;
- (void)keyUp:(NSEvent *)theEvent;

- (void)scenarioSelected;
- (void)scenarioDeselected;

- (XoXCollisionParadigm)collisionParadigm;

@optional

- (id)collisionDelegate;		//!< who performs collisions?
- tile;						//!< invoked to tile the game window
- newSize:(NSSize *)s;		//!< notification of new view size
- (BOOL)newWindowContentSize:(NSSize *)s;

- (BOOL) shouldObscureCursor;

@end
