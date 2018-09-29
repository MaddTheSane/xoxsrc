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
- setProgress:(int)p
{
    if ((progress >= min) && (progress <= max)) {
	progress = p;
	[self setNeedsDisplay:YES];
    }
    return self;
}

// manually set the direction of the fill
- setOrientation:(int)val
{
    if ((val == HORIZONTAL) || (val == VERTICAL))
	orientation = val;
    return self;
}

// set the fill color
- setFillColor:(NSColor*)color
{
    fillColor = color;
    return self;
}

- drawSelf:(const NSRect *)rects :(int)c
{
    NSRect r;
    int distance;
	int tmax = max;
	if (tmax == min) tmax++;
    
    PSsetgray(0.667);
    NSRectFill(&frame);
    NXSetColor(fillColor);
    if (orientation == HORIZONTAL) {
	distance = (progress - min) * NX_WIDTH(&frame) / (tmax - min);
	NXSetRect(&r,0,0,distance,NX_HEIGHT(&frame));
    } else {
	distance = (progress - min) * NX_HEIGHT(&frame) / (tmax - min);
	NXSetRect(&r,0,0,NX_WIDTH(&frame),distance);
    }
    NSRectFill(r);
    return self;
}

@end
