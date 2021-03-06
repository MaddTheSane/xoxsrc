
#import "ScoreView.h"
#import "xoxDefs.h"
#import "Actor.h"
#import "Xoxeroids.h"

@implementation ScoreView

- initFrame:(const NSRect *)frameRect
{
	[super initFrame:frameRect];
	[self allocateGState];		// For faster lock/unlockFocus
	[self setAutoresizeSubviews:YES];
	return self;
}

- drawSelf:(const NSRect *)rects :(int)rectCount
{
	PSsetrgbcolor(0,0,.2);
	NSRectFill(rects);
	return self;
}

- oneStep
{
	int val;

	if (oldLevel != level)
	{
		[[levelField setIntValue:level] display];
		oldLevel = level;
	}
	if (score != (val = [scenario score]))
	{
		[[scoreField setIntValue:val] display];
		score = val;
	}
	if (lives != (val = [scenario lives]))
	{
		[[livesField setIntValue:val] display];
		lives = val;
	}
	return self;
}

@end
