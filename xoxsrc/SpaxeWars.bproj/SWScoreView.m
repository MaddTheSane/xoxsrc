
#import "SWScoreView.h"

@implementation SWScoreView

- initFrame:(const NXRect *)frameRect
{
	[super initFrame:frameRect];
	[self setAutoresizeSubviews:YES];
	return self;
}

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	PSsetrgbcolor(0,0,0);
	NXRectFill(rects);
	return self;
}


@end
