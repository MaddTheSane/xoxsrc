
#import "CommonStuff.h"
#import "Bullet.h"
#import "Explosion.h"
#import "Shield.h"
#import "Ship.h"
#import "SpaceGen.h"
#import "SpaceSpinGen.h"
#import "SoundMgr.h"

int xx_bullet, xx_explosion, xx_shield, xx_space, xx_spacespin;

@implementation CommonStuff

- init
{
	[super init];
	xx_bullet = (int)[Bullet class];
	xx_explosion = (int)[Explosion class];
	xx_shield = (int)[Shield class];
	xx_space = (int)[SpaceGen class];
	xx_spacespin = (int)[SpaceSpinGen class];

	BULLET1SND = [soundMgr addSound:"sndBullet1" sender:self];
	BULLET2SND = [soundMgr addSound:"sndBullet2" sender:self];
	EXP1SND = [soundMgr addSound:"sndExplosion1" sender:self];
	EXP2SND = [soundMgr addSound:"sndExplosion2" sender:self];
	EXP3SND = [soundMgr addSound:"sndExplosion3" sender:self];
	SHIPSND = [soundMgr addSound:"sndShip" sender:self];
	WARPSND = [soundMgr addSound:"sndWarp" sender:self];
	FUTILITYSND = [soundMgr addSound:"sndFutility" sender:self];

	return self;
}

@end
