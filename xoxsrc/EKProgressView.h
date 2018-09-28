/*
 * EKProgressView
 * description: a simple "grow bar" view
 * history:
 *	5/15/93 [Erik Kay] - created
 *	6/1/93  [Erik Kay] - added color support
 */

#import <appkit/appkit.h>

#define HORIZONTAL 0
#define VERTICAL 1

@interface EKProgressView:View
{
    int min, max, progress, orientation;
    NXColor fillColor;
}

// set the range of the bar
- setMin:(int)min;
- setMax:(int)max;

// set how far along it is
- setProgress:(int)p;

// set the orientation of the bar (does it upwards, or right?)
- setOrientation:(int)val;

// set the color that the grow bar is being drawn in
- setFillColor:(NXColor)color;

@end
