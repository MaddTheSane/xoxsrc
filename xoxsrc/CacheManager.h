
#import <AppKit/AppKit.h>
#import "Actor.h"

@interface CacheManager: NSObject
{
	id cache;
	NSMutableArray *displayList;			// everything needed to construct the cache
	NSMutableArray *drawRectList;		// used to flush the cache
	NSMutableArray *eraseRectList;		// used to erase the cache
	NSImage *virgin;			// virgin background buffer for erasures
	NSImage *tile;				// image used to tile virgin background
}

- eraseCache;
- newSize:(NSSize *)sp;
- oneStep;
- erase:(NSRect *)r;
- displayRect:(NSRect *)r;
- draw:(Actor *)sender;
- setBackground:(BOOL)val;
- background;
- tileUsing:theTile;
- retileRect:(NSRect *)rp;
- draw;

@end
