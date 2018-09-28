
#import "Xoxeroids.h"
#import "BackView.h"
#import "Asteroid.h"
#import "Base.h"
#import "Eye.h"
#import "XXShip.h"
#import "Mine.h"
#import "MineFragment.h"
#import "Explosion.h"
#import "Rocket.h"
#import "RocketMatrix.h"
#import "Cannon.h"
#import "Cannonball.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "KeyTimer.h"
#import "GOLetter.h"
#import "Cave.h"
#import "RotBox.h"
#import "Thinker.h"

int		HISND,
		EEOOSND;

int rocketCount;

// cache classes for speed in identifying
int xx_asteroid, xx_base, xx_cannon, xx_cannonball, xx_eye;
int xx_mine, xx_minefragment, xx_rocket, xx_ship;

@implementation Xoxeroids

- newGame
{
	XXShip *myShip;
	score = 0;
	lives = 3;
	nextBonus = 10000;
	myShip = (XXShip *)ship;
	if (myShip) myShip->bigGuns = NO;
	return self;
}

// invoked only by the actor manager
- _createLevel:(int)lev
{
	int i;
	NXRect r;

	badGuyCount = explosionCount = shipCount = rocketCount = 0;

	if ((lev > 1) && (lev < 6))
		[actorMgr newActor:(int)[CrabNebula class] for:self tag:0];

	ship = [actorMgr newActor:xx_ship for:self tag:GOOD];

	space = [actorMgr newActor:xx_space	for:self tag:0];
	[mainView getBounds:&r];
	[space newSize:&r.size];

	[[mainView window] setTitle:"Xoxeroids"];

	for (i=0; i<lev+3; i++)
	{
		[actorMgr newActor:xx_asteroid for:self tag:(i%4)];
	}
	for (i=0; i<lev+2; i++)
	{
		[actorMgr newActor:xx_mine for:self tag:i];
	}

	// starting at level 2, every 3 levels add 1
	for (i=0; i<((lev+1)/3); i++)
	{
		[actorMgr newActor:xx_cannon for:self tag:i];
	}

	// starting at level 4, every 3 levels add 1
	for (i=0; i<((lev-1)/3); i++)
	{
		[actorMgr newActor:xx_base for:self tag:i];
	}

	if (lev > 5)
		[actorMgr newActor:(int)[RocketMatrix class] for:self tag:0];

	if (lev > 7)
		[actorMgr newActor:(int)[Cave class] for:self tag:0];

	if ((lev % 3) == 0)
		[actorMgr newActor:(int)[RotBox class] for:self tag:0];

	[soundMgr playSound: HISND at:0.5];

	oldScore = score;
	oldLives = lives;
	oldBonus = nextBonus;

	return self;
}

- infoView
{
	return infoView;
}

- didActivate:(Actor *)theActor
{
	if(theActor->actorType == xx_ship)
		shipCount++;
	else if(theActor->actorType == xx_explosion)
	{
		if (shipCount > 0) explosionCount++;
	}
	else if(theActor->actorType == xx_rocket)
	{
		rocketCount++;
		if (theActor->alliance == EVIL)
				badGuyCount++;
	}
	else
	{
		if ((theActor->alliance == EVIL) &&
			(theActor->actorType != (int)[RotBox class]))
				badGuyCount++;
	}
	return self;
}

- didRetire:(Actor *)theActor
{
	NXRect r;

	if(theActor->actorType == xx_ship)
	{
		if (--lives <= 0)
		{
			[GOLetter gameOver:self];
			[actorMgr setGameStatus: GAME_DYING];
		}
		shipCount--;
	}
	else if((theActor->actorType == xx_spacespin) && 
			([actorMgr gameStatus] != GAME_DYING))
		[actorMgr requestLevel: level+1];
	else if(theActor->actorType == xx_explosion)
	{
		if (--explosionCount <= 0)
		{
			if (shipCount <= 0)
			{
				if ([actorMgr gameStatus] != GAME_DYING)
					[actorMgr requestLevel: level];
			}
//			else if (badGuyCount <= 0)
			else if ((badGuyCount <= 0) && (explosionCount == 0))
			{
//				nextLevel = level+1;
				space = [actorMgr newActor:xx_spacespin	for:self tag:0];
				[mainView getBounds:&r];
				[space newSize:&r.size];
			}
		}
	}
	else
	{
		if (theActor->alliance == EVIL) badGuyCount--;
		if(theActor->actorType == xx_rocket) rocketCount--;
	}

	return self;
}


- keyDown:(NXEvent *)theEvent
{
	if (theEvent->data.key.repeat > 0) return self;

	switch(theEvent->data.key.charCode)
	{
		case 'z':		// rotate left
			[ship setTurning:LEFT down:YES time:theEvent->time];
			break;
		case 'x':		// rotate right
			[ship setTurning:RIGHT down:YES time:theEvent->time];
			break;

		case '.':		// fire
			[ship fire];
			break;
		case ',':		// thrust
			[ship setThrusting:YES time:theEvent->time];
			break;
		case ' ':		// shields
			[ship setShields:1];
			break;
	}
	return self;
}

- keyUp:(NXEvent *)theEvent
{
	switch(theEvent->data.key.charCode)
	{
		case 'z':		// rotate left
			[ship setTurning:LEFT down:NO time:theEvent->time];
			break;
		case 'x':		// rotate right
			[ship setTurning:RIGHT down:NO time:theEvent->time];
			break;
		case ',':		// thrust
			[ship setThrusting:NO time:theEvent->time];
			break;
		case ' ':		// shields
			[ship setShields:0];
			break;
	}
	return self;
}

- scenarioSelected
{
	score = oldScore;
	lives = oldLives;
	nextBonus = oldBonus;

	ship = [actorMgr newActor:xx_ship for:self tag:GOOD];
	[ship scenarioSelected];
	return self; 
}

- scenarioDeselected
{
	return self; 
}

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
		forResource:"xoxeroids"
		ofType:"nib"])
	{
		[NXApp loadNibFile:path
			owner:self
			withNames:NO
			fromZone:[self zone]];

		cv = [uselessView contentView];
		subviews = [cv subviews];
		while ([subviews count] > 0)
			[scoreView addSubview:[subviews objectAt:0]];
	}

	HISND = [soundMgr addSound:"sndHi" sender:self];
	EEOOSND = [soundMgr addSound:"sndEeOo" sender:self];

	xx_asteroid = (int)[Asteroid class];
	xx_base = (int)[Base class];
	xx_cannon = (int)[Cannon class];
	xx_cannonball = (int)[Cannonball class];
	xx_eye = (int)[Eye class];
	xx_mine = (int)[Mine class];
	xx_minefragment = (int)[MineFragment class];
	xx_rocket = (int)[Rocket class];
	xx_ship = (int)[XXShip class];

	[[NXApp delegate] addImageResource:"explosionM" for: [Explosion class]];
	[[NXApp delegate] addImageResource:"explosionS" for: [Explosion class]];
	[[NXApp delegate] addSoundResource:	EXP1SND];
	[[NXApp delegate] addSoundResource:	EXP2SND];
	[[NXApp delegate] addSoundResource:	EXP3SND];
	[[NXApp delegate] addSoundResource:	BULLET1SND];
	[[NXApp delegate] addSoundResource:	SHIPSND];

	return self;
}

- tile
{
	NXRect r;
	char title[50];
	sprintf(title,"Xoxeroids level %d",level);
	[[gcontentView window] setTitle:title];

	[gcontentView getBounds:&r];
	r.size.height -= 40;
	r.origin.y += 40;
	[abackView setFrame:&r];
	[gcontentView getBounds:&r];
	r.size.height = 40;
	[scoreView setFrame:&r];
	[gcontentView addSubview:abackView];
	[gcontentView addSubview:scoreView];
	return abackView;
}

- gotoLevel:sender
{
	int lvl = [sender intValue];
	if (lvl > 0 && lvl <=2000)
	{
		[actorMgr requestLevel:lvl];
		lives = 20;
	}
	return self;
}

- oneStep
{
	if (timeInMS > scoreTime)
	{
		[scoreView oneStep];
		scoreTime = timeInMS + 600;
	}
	return self;
}

- (int)addToScore:(int)val for:dude gen:(int)age
{
	if (dude == ship)
	{
		score += val;
		if (score >= nextBonus)
		{
			lives++;
			nextBonus += 10000;
		}
	}
	return score;
}

- (int)setScore:(int)val for:dude
{
	score = val;
	return score;
}

- (int) score
{
	return score;
}

- (int) lives
{
	return lives;
}

@end




