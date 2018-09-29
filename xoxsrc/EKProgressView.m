/*
 * EKProgressView
 * description: a simple "grow bar" view
 * history:
 *	5/15/93 [Erik Kay] - created
 *	6/1/93  [Erik Kay] - added color support
 */

#import "EKProgressView.h"

@implementation EKProgressView

- (instancetype)initWithFrame:(NSRect)f
{
    if (self = [super initWithFrame:f]) {

    // by default, if it's wider than high, then it fills to the right
    // otherwise it fills upwards
    if (NSWidth(f) > NSHeight(f))
    	orientation = HORIZONTAL;
    else
	orientation = VERTICAL;
    // set the fill color based on the window depth limit
		fillColor = [NSColor colorWithCalibratedRed:0.467 green:0 blue:0.067 alpha:1];

    min = 0; max = 100; progress = 0;
	}
    return self;
}

@synthesize minimum=min;
@synthesize maximum=max;
// set the range
- setMin:(int)m
{
    min = m;
    return self;
}

- setMax:(int)m
{
    max = m;
    return self;
}

// set how far the progress bar is
@synthesize progress;
- (void)setProgress:(NSInteger)p
{
    if ((progress >= min) && (progress <= max)) {
	progress = p;
	[self setNeedsDisplay:YES];
    }
}

// manually set the direction of the fill
- setOrientation:(int)val
{
    if ((val == HORIZONTAL) || (val == VERTICAL))
	orientation = val;
    return self;
}

@synthesize fillColor;

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect r;
    NSInteger distance;
	NSInteger tmax = max;
	if (tmax == min) tmax++;
	
	[[NSColor darkGrayColor] set];
    NSRectFill(self.frame);
	[fillColor set];
    if (orientation == HORIZONTAL) {
	distance = (progress - min) * NSWidth(self.frame) / (tmax - min);
		r = NSMakeRect(0, 0, distance, NSHeight(self.frame));
    } else {
	distance = (progress - min) * NSHeight(self.frame) / (tmax - min);
		r = NSMakeRect(0, 0, NSWidth(self.frame), distance);
    }
    NSRectFill(r);
}

@end
