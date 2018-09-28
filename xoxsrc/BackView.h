
#import <appkit/appkit.h>
#import "xoxDefs.h"

@interface BackView:View
{
}

- newSize;

@end



@interface Window(Sizing)
- sizeWindow:(NXCoord)width :(NXCoord)height byCorner:(int)corner;
@end

@interface View(Sizing)
- sizeTo:(NXCoord)width :(NXCoord)height byWindowCorner:(int)corner;
@end
