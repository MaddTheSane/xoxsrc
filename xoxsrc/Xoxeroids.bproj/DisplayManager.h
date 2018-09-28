
#import <appkit/appkit.h>

@interface DisplayManager:Object
{
	Storage *eraseList;
	Storage *whiteList;
	List *drawList;
}

- oneStep;
- erase:(NXRect *)r;
- displayRect:(NXRect *)r;
- drawWhiteRect:(NXRect *)r;
- draw:sender;

@end
