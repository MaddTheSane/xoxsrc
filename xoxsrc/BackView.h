
#import <AppKit/AppKit.h>
#import "xoxDefs.h"

@interface BackView: NSView
{
}

- (void)newSize;

@end



@interface NSWindow(Sizing)
- sizeWindow:(NXCoord)width :(NXCoord)height byCorner:(int)corner;
@end

@interface NSView(Sizing)
- sizeTo:(NXCoord)width :(NXCoord)height byWindowCorner:(int)corner;
@end
