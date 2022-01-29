
#import "SWSun.h"

@implementation SWSun


- activate:sender :(int)tag
{
	NSSize tsize = {24,24};
	NSSize t2 = {12, 12};

	[super activate:sender :tag];

	[self reinitWithImage:"sun"
		frameSize:&tsize
		numFrames:6
		shape: CIRCLE
		alliance: XoXDestroyAll
		radius: 8
		buffered: YES
		x: 0
		y: 0
		theta: 0
		vel: 0
		interval: 50
		distToCorner: &t2];

	return self;
}

- performCollisionWith:(Actor *) dude
{
	// don't go away
	return self;
}

@end
