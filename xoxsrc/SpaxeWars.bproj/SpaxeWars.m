
#import "SpaxeWars.h"
#import "BackView.h"
#import "Ship.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "SWBullet.h"
#import "SWShip.h"
#import "SWSpaceGen.h"
#import "SWSun.h"
#import "SWMeteor.h"
#import "GOLetter.h"
#import "Explosion.h"
#import "Thinker.h"


int xx_swbullet, xx_swship, xx_swspace;
float sw_gravity;
int sw_bulletSpeed, sw_bounce, sw_meteors, sw_nastyShots;
int sw_bulletMass;

@implementation SpaxeWars

- newGame
{
	dartKills = clawKills = 0;
	[[clawKillsText setIntValue:clawKills] display];
	[[dartKillsText setIntValue:dartKills] display];
	return self;
}

// invoked only by the actor manager
- _createLevel:(int)lev
{
	int i;
	NXRect r;
	char title[40];

	goToNextLevel = explosionCount = goodBullets = badBullets = 0;

	goodShip = [actorMgr newActor:xx_swship for:self tag:GOOD];
	badShip = [actorMgr newActor:xx_swship for:self tag:EVIL];

	space = [actorMgr newActor:xx_swspace	for:self tag:0];
	if (sun) sun = [actorMgr newActor:(int)[SWSun class] for:self tag:0];
	for (i=0; i<sw_meteors; i++)
		[actorMgr newActor:(int)[SWMeteor class] for:self tag:0];
	[mainView getBounds:&r];
	[space newSize:&r.size];

	sprintf(title,"Spaxe Wars");
	[[mainView window] setTitle:title];

	return self;
}

- infoView
{
	return infoView;
}

- didActivate:(Actor *)theActor
{
	if(theActor->actorType == xx_explosion)
		explosionCount++;
	else if(theActor->actorType == xx_swbullet)
	{
		(theActor->theta == 0.) ? goodBullets++ : badBullets++;
	}
	else
	{
	}
	return self;
}

- didRetire:(Actor *)theActor
{
	if(theActor->actorType == xx_swship)
	{
		if (theActor->alliance == GOOD)
		{
			[[clawKillsText setIntValue:++clawKills] display];
		}
		else
		{
			[[dartKillsText setIntValue:++dartKills] display];
		}

		if (dartKills >= 10 || clawKills >= 10)
		{
			if ([actorMgr gameStatus] != GAME_DYING)
				[GOLetter gameOver:self];
			[actorMgr setGameStatus: GAME_DYING];
			goToNextLevel = 0;
		}
		else goToNextLevel = 1;
	}
	else if(theActor->actorType == xx_explosion)
	{
		if ((--explosionCount <= 0) && goToNextLevel)
		{
			[actorMgr requestLevel: 1];
		}
	}
	else if(theActor->actorType == xx_swbullet)
	{
		(theActor->theta == 0.) ? goodBullets-- : badBullets--;
	}
	else
	{
	}

	return self;
}



- keyDown:(NXEvent *)theEvent
{
	if (theEvent->data.key.repeat > 0) return self;

	switch(theEvent->data.key.charCode)
	{
		case 'z':		// rotate left
			[goodShip setTurning:LEFT down:YES time:theEvent->time];
			break;
		case 'x':		// rotate right
			[goodShip setTurning:RIGHT down:YES time:theEvent->time];
			break;
		case '.':		// fire
			[goodShip fire];
			break;
		case ',':		// thrust
			[goodShip setThrusting:YES time:theEvent->time];
			break;
		case ' ':		// shields
			[goodShip setShields:1];
			break;

		case '1':		// rotate left
			[badShip setTurning:LEFT down:YES time:theEvent->time];
			break;
		case '2':		// rotate right
			[badShip setTurning:RIGHT down:YES time:theEvent->time];
			break;
		case '9':		// fire
			[badShip fire];
			break;
		case '6':		// thrust
			[badShip setThrusting:YES time:theEvent->time];
			break;
		case '\003':		// shields
			[badShip setShields:1];
			break;
	}
	return self;
}

- keyUp:(NXEvent *)theEvent
{
	switch(theEvent->data.key.charCode)
	{
		case 'z':		// rotate left
			[goodShip setTurning:LEFT down:NO time:theEvent->time];
			break;
		case 'x':		// rotate right
			[goodShip setTurning:RIGHT down:NO time:theEvent->time];
			break;
		case ',':		// thrust
			[goodShip setThrusting:NO time:theEvent->time];
			break;
		case ' ':		// shields
			[goodShip setShields:0];
			break;

		case '1':		// rotate left
			[badShip setTurning:LEFT down:NO time:theEvent->time];
			break;
		case '2':		// rotate right
			[badShip setTurning:RIGHT down:NO time:theEvent->time];
			break;
		case '6':		// thrust
			[badShip setThrusting:NO time:theEvent->time];
			break;
		case '\003':		// shields
			[badShip setShields:0];
			break;
	}
	return self;
}

- scenarioSelected
{
	goodShip = [actorMgr newActor:xx_swship for:self tag:GOOD];
	badShip = [actorMgr newActor:xx_swship for:self tag:EVIL];
	[goodShip scenarioSelected];
	[badShip scenarioSelected];
	return self; 
}

- scenarioDeselected
{	return self; }

- newSize:(NXSize *)s
{
	[space newSize:s];
	return self;
}

- (COLLISION_PARADIGM)collisionParadigm
{
	return GOOD_V_EVIL;
}

- init
{
	char path[256];
	id cv, subviews;

	[super init];

	if ([[NXBundle bundleForClass:[self class]]
		getPath:path
		forResource:"spaxewars"
		ofType:"nib"])
	{
		[NXApp loadNibFile:path
			owner:self
			withNames:NO
			fromZone:[self zone]];

		cv = [uselessBox contentView];
		subviews = [cv subviews];
		while ([subviews count] > 0)
			[scoreView addSubview:[subviews objectAt:0]];
		
	}

	xx_swbullet = (int)[SWBullet class];
	xx_swship = (int)[SWShip class];
	xx_swspace = (int)[SWSpaceGen class];

	[self adjustSettings:self];

	[[NXApp delegate] addImageResource:"explosionM" for: [Explosion class]];
	[[NXApp delegate] addImageResource:"explosionS" for: [Explosion class]];
	[[NXApp delegate] addSoundResource:	SHIPSND];

	return self;
}

- tile
{
	NXRect r;
	float f;

	[gcontentView getBounds:&r];
	r.size.width -= 60;
	f = r.size.width;
	[abackView setFrame:&r];
	[gcontentView getBounds:&r];
	r.size.width = 60;
	r.origin.x = f;
	[scoreView setFrame:&r];
	[gcontentView addSubview:abackView];
	[gcontentView addSubview:scoreView];
	return abackView;
}

- (int) bullets : (int) type
{
	return (type == GOOD) ? goodBullets : badBullets;
}

- adjustSettings:sender
{
	switch([gravityMatrix selectedRow])
	{
		case 0: sw_gravity = 30000; break;
		case 1: sw_gravity = 0; break;
		case 2: sw_gravity = -30000; break;
		case 3: sw_gravity = -66000; break;
	}
	switch([bulletMatrix selectedRow])
	{
		case 0: sw_bulletSpeed = 13; break;
		case 1: sw_bulletSpeed = 22; break;
		case 2: sw_bulletSpeed = 34; break;
	}

	if ([[settingsMatrix cellAt:0:0] state])
	{	// sun enabled
		if (!sun) sun = [actorMgr newActor:(int)[SWSun class] for:self tag:0]; 
	}
	else
	{
		if (sun) [actorMgr destroyActor:sun];
		sun = nil;
	}

	sw_bounce = ([[settingsMatrix cellAt:1:0] state]);
	sw_nastyShots = ([[settingsMatrix cellAt:2:0] state]);
	sw_bulletMass = ([[settingsMatrix cellAt:3:0] state]);

	sw_meteors = ([meteorsSlider intValue]);

	return self;
}

@end




