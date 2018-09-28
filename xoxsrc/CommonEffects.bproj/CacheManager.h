
#import <appkit/appkit.h>
#import "Actor.h"

@interface CacheManager:Object
{
	id cache;
	List *displayList;			// everything needed to construct the cache
	Storage *drawRectList;		// used to flush the cache
	Storage *eraseRectList;		// used to erase the cache
	NXImage *virgin;			// virgin background buffer for erasures
	NXImage *tile;				// image used to tile virgin background
}

- eraseCache;
- newSize:(NXSize *)sp;
- oneStep;
- erase:(NXRect *)r;
- displayRect:(NXRect *)r;
- draw:(Actor *)sender;
- setBackground:(BOOL)val;
- background;
- tileUsing:theTile;
- retileRect:(NXRect *)rp;
- draw;

@end
