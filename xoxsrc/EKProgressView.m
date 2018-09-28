/*
 * EKProgressView
 * description: a simple "grow bar" view
 * history:
 *	5/15/93 [Erik Kay] - created
 *	6/1/93  [Erik Kay] - added color support
 */

#import "EKProgressView.h"

@implementation EKProgressView

- initFrame:(const NXRect *)f
{
    [super initFrame:f];

    // by default, if it's wider than high, then it fills to the right
    // otherwise it fills upwards
    if (NX_WIDTH(f) > NX_HEIGHT(f))
    	orientation = HORIZONTAL;
    else
	orientation = VERTICAL;
    // set the fill color based on the window depth limit
    switch ([Window defaultDepthLimit]) {
	case NX_TwentyFourBitRGBDepth:
	case NX_TwelveBitRGBDepth:
	    fillColor = NXConvertRGBToColor(0.467,0,0.067);
	    break;
	default: // gray scale
	    fillColor = NXConvertGrayToColor(0.333);
	    break;
    }
    min = 0; max = 100; progress = 0;
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
	[self display];
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
- setFillColor:(NXColor)color
{
    fillColor = color;
    return self;
}

- drawSelf:(const NXRect *)rects :(int)c
{
    NXRect r;
    int distance;
	int tmax = max;
	if (tmax == min) tmax++;
    
    PSsetgray(0.667);
    NXRectFill(&frame);
    NXSetColor(fillColor);
    if (orientation == HORIZONTAL) {
	distance = (progress - min) * NX_WIDTH(&frame) / (tmax - min);
	NXSetRect(&r,0,0,distance,NX_HEIGHT(&frame));
    } else {
	distance = (progress - min) * NX_HEIGHT(&frame) / (tmax - min);
	NXSetRect(&r,0,0,NX_WIDTH(&frame),distance);
    }
    NXRectFill(&r);
    return self;
}

@end
