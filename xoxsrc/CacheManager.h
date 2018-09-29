
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

- (void)eraseCache;
- (void)newSize:(NSSize)sp;
- (void)oneStep;
- (void)erase:(NSRect)r;
- displayRect:(NSRect *)r;
- (void)draw:(Actor *)sender;
- setBackground:(BOOL)val;
- background;
- (void)tileUsing:theTile;
- (void)retileRect:(NSRect)rp;
- (void)draw;

@end
