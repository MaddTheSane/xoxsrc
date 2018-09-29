/*
 * EKProgressView
 * description: a simple "grow bar" view
 * history:
 *	5/15/93 [Erik Kay] - created
 *	6/1/93  [Erik Kay] - added color support
 */

#import <AppKit/AppKit.h>

#define HORIZONTAL 0
#define VERTICAL 1

@interface EKProgressView: NSView
{
	NSInteger min, max, progress;
	int orientation;
    NSColor* fillColor;
}

// set the range of the bar
@property NSInteger minimum;
@property NSInteger maximum;

- setMin:(int)min;
- setMax:(int)max;

//! set how far along it is
@property (nonatomic) NSInteger progress;

// set the orientation of the bar (does it upwards, or right?)
- setOrientation:(int)val;

//! set the color that the grow bar is being drawn in
@property (retain) NSColor *fillColor;

@end
