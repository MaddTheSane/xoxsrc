
#import <AppKit/AppKit.h>

@interface DisplayManager:Object
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
