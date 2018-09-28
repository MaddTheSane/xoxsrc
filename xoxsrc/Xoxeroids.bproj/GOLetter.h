
#import <AppKit/AppKit.h>

#import "Actor.h"

@interface GOLetter:Actor
{
	float destx, desty;
}

+ gameOver:sender;

@end

@interface Object (gameOverNotifications)
- gameOverComplete;
@end
