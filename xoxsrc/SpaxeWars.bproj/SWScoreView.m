
#import "SWScoreView.h"

@implementation SWScoreView

- (instancetype)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		self.autoresizesSubviews = YES;
	}
	return self;
}

- (void)drawRect:(NSRect)rects
{
	[NSColor.blackColor set];
	NSRectFill(rects);
}


@end
