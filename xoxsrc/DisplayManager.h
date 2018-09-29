
#import <AppKit/AppKit.h>
#import "DrawManager.h"

@interface DisplayManager: NSObject <DrawManager>
{
	NSMutableArray *eraseList;
	NSMutableArray *whiteList;
	NSMutableArray *drawList;
}

- (void)oneStep;
- (void)erase:(NSRect)r;
- (void)displayRect:(NSRect)r;
- (void)drawWhiteRect:(NSRect)r;
- (void)draw:sender;

@end
