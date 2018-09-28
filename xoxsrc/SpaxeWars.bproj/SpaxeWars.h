
#import <appkit/appkit.h>
#import "Scenario.h"

extern float sw_gravity;
extern int sw_bulletSpeed, sw_bounce;

@interface SpaxeWars:Object <Scenario>
{
	id goodShip;
	id badShip;
	id space;
	int goToNextLevel;
	int explosionCount;

	id infoView;
	id scoreView;
	int goodBullets;
	int badBullets;
	id sun;

	id gravityMatrix;
	id bulletMatrix;
	id settingsMatrix;
	id meteorsSlider;

	id dartButton;
	id dartKillsText;
	id clawButton;
	id clawKillsText;
	int dartKills;
	int clawKills;
	id uselessBox;
}

- (int) bullets : (int) type;
- adjustSettings:sender;

@end

@interface Actor(spaxeWarsAdditions)
- swApplyGravity;
@end

