
#import "BackView.h"
#import "Ship.h"
#import "Thinker.h"
#import "CacheManager.h"
#import "ActorMgr.h"

float xOffset, yOffset;
NXRect screenRect;

@implementation BackView

- initFrame:(const NXRect *)frameRect
{
	[super initFrame:frameRect];
	[self allocateGState];		// For faster lock/unlockFocus
	[self newSize];
	return self;
}

- sizeTo:(NXCoord)width :(NXCoord)height
{
	[super sizeTo:width :height];
	[self newSize];
	return self;
}

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	NXRect t = {0,0,1,1};
	PSsetrgbcolor(1,0,0);
	NXRectFill(&t);	//yucky trick for window depth promotion!
	PSsetgray(NX_BLACK); NXRectFill(rects);
	[(CacheManager *)cacheMgr draw];
	[(ActorMgr *)actorMgr draw];
	return self;
}

- keyDown:(NXEvent *)theEvent
{
//	switch(theEvent->data.key.charCode)
	{
//		default:
			[scenario keyDown:theEvent];
//			break;
	}
	return self;
}

- keyUp:(NXEvent *)theEvent
{
	[scenario keyUp:theEvent];
	return self;
}

- newSize
{
	xOffset = bounds.size.width/2;
	yOffset = bounds.size.height/2;

	screenRect = bounds;

	[cacheMgr newSize:&bounds.size];
	if ([scenario respondsTo:@selector(newSize:)])
		[scenario newSize:&bounds.size];

	return self;
}

- (BOOL) acceptsFirstResponder
{	return YES;
}

@end


@implementation Window(Sizing)

#define CORNER_UPPER_LEFT	0
#define CORNER_LOWER_LEFT	1
#define CORNER_UPPER_RIGHT	2
#define CORNER_LOWER_RIGHT	3

// Keep 'a' between x and y
#define CLAMP(a,x,y) (MAX((x), MIN((y), (a))))

/******************************************************************************
	This Method resizes the receiving window as if it was dragged with the given corner. This method is useful when you want the window to resize by a corner other that the default upper right.
******************************************************************************/
- sizeWindow:(NXCoord)width :(NXCoord)height byCorner:(int)corner
{
	NXRect newFrame;
	NXSize minSize, maxSize;

	// Clamp width and height to their respective minimum and maximum values
	[self getMinSize:&minSize]; [self getMaxSize:&maxSize];
	width = CLAMP(width, minSize.width, maxSize.width);
	height = CLAMP(height, minSize.height, maxSize.height);

	// Set newFrame from the old frame and the new sizes
	NXSetRect(&newFrame, NX_X(&frame), NX_Y(&frame), width, height);

	// Move the respective corner by the amount of growth and set newFrame
	switch(corner) {
		case CORNER_UPPER_LEFT:
			NX_X(&newFrame) -= width - NX_WIDTH(&frame);
			break;
		case CORNER_LOWER_LEFT:
			NX_X(&newFrame) -= width - NX_WIDTH(&frame);
			NX_Y(&newFrame) -= height - NX_HEIGHT(&frame);
			break;
		case CORNER_UPPER_RIGHT:
			break;
		case CORNER_LOWER_RIGHT:
			NX_Y(&newFrame) -= height - NX_HEIGHT(&frame);
			break;
	}
	[self placeWindowAndDisplay:&newFrame];
	return self;
}
@end

@implementation View(Sizing)

/******************************************************************************
	This Method resizes the receiving view to the given width and height by resizing the window by the appropriate amount with respect to autosizing. This method is useful for those occasions when you know what size a view should be, but don't know how big to make the window to hold it. If you ask for a new width, it assumes the view is width sizable. The same goes for height. If the hierarchy contains a ClipView (ie, in a ScrollView) it assumes that you want the ClipView's subview to be fully exposed. The window size will not exceed the set maximum.
******************************************************************************/
- sizeTo:(NXCoord)width :(NXCoord)height byWindowCorner:(int)corner
{
	int autosizing = [self autosizing];
	float widthGrowth = width - NX_WIDTH(&bounds);
	float heightGrowth = height - NX_HEIGHT(&bounds);
	float stretchingWidth = NX_WIDTH(&bounds);
	float stretchingHeight = NX_HEIGHT(&bounds);
	float newSuperWidth, newSuperHeight;
	NXRect superFrame;

	// If we are a contentView we simply need to grow window by our growth
	if(self==[window contentView]) {
		[window getFrame:&superFrame];
		[window sizeWindow:NX_WIDTH(&superFrame) + widthGrowth
			:NX_HEIGHT(&superFrame) + heightGrowth byCorner:corner];
	}
	else {
		[superview getFrame:&superFrame];

		// Add margins to stretching lengths if they have been turned on in IB
		if(autosizing & NX_MINXMARGINSIZABLE) stretchingWidth += NX_X(&frame);
		if(autosizing & NX_MAXXMARGINSIZABLE)
			stretchingWidth += NX_WIDTH(&superFrame) - NX_MAXX(&frame);
		if(autosizing & NX_MINYMARGINSIZABLE)
			stretchingHeight += NX_Y(&frame);
		if(autosizing & NX_MAXYMARGINSIZABLE)
			stretchingHeight += NX_HEIGHT(&superFrame) - NX_MAXY(&frame);

		// Add growth times a ratio of stetching length::view length to Super
		newSuperWidth = NX_WIDTH(&superFrame) +
			widthGrowth*stretchingWidth/NX_WIDTH(&bounds);
		newSuperHeight = NX_HEIGHT(&superFrame) +
			heightGrowth*stretchingHeight/NX_HEIGHT(&bounds);

		// Resize the Superview
		[superview sizeTo:newSuperWidth :newSuperHeight 
			byWindowCorner:corner];
		
		// If we are a ClipView, bring the docview up to size
		if([self isKindOf:[ClipView class]]) 
			[[(ClipView *)self docView] sizeTo:width :height];
	}
	return self;
}
