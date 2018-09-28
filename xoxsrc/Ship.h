
#import "Actor.h"
#import "KeyTimer.h"

@interface Ship:Actor
{
@public
    BOOL thrusting;
	ROTATION rotation;
	id noflame;
	id flame1;
	id flame2;
	int thrustState;
	BOOL bigGuns;
	id shields;
	float shieldStrength;
	unsigned shieldTime;

	KeyTimer *thrustVal;
	KeyTimer *rightVal;
	KeyTimer *leftVal;

	BOOL didFire;
}

- setThrusting:(BOOL)val time:(long)time;
- setTurning:(ROTATION)dir down:(BOOL)keyDn time:(long)time;
- fire;
- setShields:(int)state;
- scenarioSelected;

@end
