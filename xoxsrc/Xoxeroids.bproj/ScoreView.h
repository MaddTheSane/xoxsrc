
#import <AppKit/AppKit.h>

@interface ScoreView:View
{
	int oldLevel;
	int score;
	int lives;

	id livesField;
	id levelField;
	id scoreField;
}

- oneStep;

@end
