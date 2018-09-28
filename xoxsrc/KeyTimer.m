
#import "KeyTimer.h"

@implementation KeyTimer

- setTag:(int)atag
{
	tag = atag;
	return self;
}

- setDelegate:dude
{
	delegate = dude;
	return self;
}

- keyDownAt:(long)time
{
	[delegate cancelAt:time from:self];
	keyDown = YES;
	beganThisFrame = YES;
	keyVbl = time;
	downEntireFrame = NO;
	return self;
}

- keyUpAt:(long)time
{
	keyDown = NO;
	if (beganThisFrame)
	{	float interval = (time-keyVbl);
		if (interval <= 0) interval = 0.5;
		keyVal += interval / 7.0;	// 7 vbl's per "normal" iteration
	}
	else keyVal += timeScale * 0.25;		// guess...
	beganThisFrame = NO;
	downEntireFrame = NO;
	return self;
}

- preOneStep
{
	if (keyDown) 
	{
		if (downEntireFrame) keyVal = timeScale;
		else keyVal += .5 * timeScale;	// beganThisFrame, guess...
		downEntireFrame = YES;			// unless we hear otherwise
	}
	if (keyVal > timeScale) keyVal = timeScale;
	else if (keyVal < 0) keyVal = 0;
	return self;
}

- postOneStep
{
	keyVal = 0;
	beganThisFrame = NO;
	return self;
}

- (float)val
{
	return keyVal;
}

- cancelAt:(long)time from:sender
{
	if (keyDown) [self keyUpAt:time];
	return self;
}

@end

