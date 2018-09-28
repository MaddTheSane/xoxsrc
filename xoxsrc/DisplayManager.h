
#import <AppKit/AppKit.h>

@interface DisplayManager: NSObject
{
	Storage *eraseList;
	Storage *whiteList;
	List *drawList;
}

- oneStep;
- erase:(NSRect *)r;
- displayRect:(NSRect *)r;
- drawWhiteRect:(NSRect *)r;
- draw:sender;

@end
