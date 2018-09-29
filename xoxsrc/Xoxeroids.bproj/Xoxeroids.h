
#import <AppKit/AppKit.h>
#import "Scenario.h"
#import "KeyTimer.h"

extern int
		HISND,
		EEOOSND;

@interface Xoxeroids: NSObject <Scenario>
{
	id ship;
	id space;
	int badGuyCount;
	int explosionCount;
	int shipCount;
//	int nextLevel;

	IBOutlet id infoView;
	IBOutlet id scoreView;

	IBOutlet id uselessView;

	unsigned scoreTime;
	int score;
	int oldScore;
	int lives;
	int oldLives;
	int nextBonus;
	int oldBonus;
}

- (IBAction)gotoLevel:sender;
- (int) lives;

@end
