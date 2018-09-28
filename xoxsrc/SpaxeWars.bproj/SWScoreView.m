
#import "SWScoreView.h"

@implementation SWScoreView

- initFrame:(const NSRect *)frameRect
{
	[super initFrame:frameRect];
	[self setAutoresizeSubviews:YES];
	return self;
}

- drawSelf:(const NSRect *)rects :(int)rectCount
{
	PSsetrgbcolor(0,0,0);
	NSRectFill(rects);
	return self;
}


@end
