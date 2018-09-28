
#import <AppKit/AppKit.h>

#import "Actor.h"

@interface RotBox:Actor
{
	XXLine outline[6];
	Actor *myBuddy;
	Actor *myBall;
}

- buddy;

@end

@interface RotBall:Actor
{
	int kind;
}

@end

