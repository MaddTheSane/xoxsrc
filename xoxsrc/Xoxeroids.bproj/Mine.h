
#import <appkit/appkit.h>

#import "Actor.h"

@interface Mine:Actor
{
	id goodMine;
	id badMine;
	int mineState;
	int frameDir;
}

- (int) mineType;

@end
