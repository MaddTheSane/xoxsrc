
#import <AppKit/AppKit.h>

@interface DisplayManager: NSObject
{
	NSMutableArray *eraseList;
	NSMutableArray *whiteList;
	NSMutableArray *drawList;
}

- (void)oneStep;
- erase:(NSRect *)r;
- displayRect:(NSRect *)r;
- drawWhiteRect:(NSRect *)r;
- draw:sender;

@end
