// KeyTimer.h - a keytimer can be used to track the duration a key was down.
// It has to do some guessing, since the event time base can't be related
// back to the system clock...

#import <appkit/appkit.h>
#import "xoxDefs.h"

@interface KeyTimer:Object
{
	int tag;
	BOOL keyDown;
	BOOL beganThisFrame;
	float keyVal;			// how long key down, scaled to 10 fps
	long keyVbl;			// how many vertical blanks key was down
	BOOL downEntireFrame;
	id delegate;
}

- setTag:(int)atag;
- setDelegate:dude;
- keyDownAt:(long)time;
- keyUpAt:(long)time;
- preOneStep;
- postOneStep;
- (float)val;
- cancelAt:(long)time from:sender;

@end







