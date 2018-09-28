
#import <AppKit/AppKit.h>
#import "Scenario.h"
#import "KeyTimer.h"

extern int
		HISND,
		EEOOSND;

@interface Xoxeroids:Object <Scenario>
{
	id ship;
	id space;
	int badGuyCount;
	int explosionCount;
	int shipCount;
//	int nextLevel;

	id infoView;
	id scoreView;

	id uselessView;

	unsigned scoreTime;
	int score;
	int oldScore;
	int lives;
	int oldLives;
	int nextBonus;
	int oldBonus;
}

- gotoLevel:sender;
- (int) lives;

@end
