
#import <AppKit/AppKit.h>
#import "Actor.h"
#import "DrawManager.h"

@interface CacheManager: NSObject <DrawManager>
{
	id cache;
	NSMutableArray<Actor*> *displayList;	// everything needed to construct the cache
	NSMutableArray *drawRectList;		// used to flush the cache
	NSMutableArray *eraseRectList;		// used to erase the cache
	NSImage *virgin;			// virgin background buffer for erasures
	NSImage *tile;				// image used to tile virgin background
}

- (void)eraseCache;
- (void)newSize:(NSSize)sp;
- (void)oneStep;
- (void)erase:(NSRect)r;
- (void)displayRect:(NSRect)r;
- (void)draw:(Actor *)sender;
- (void)setBackground:(BOOL)val;
- (NSImage*)background;
- (void)tileUsing:(NSImage*)theTile;
- (BOOL)retileRect:(NSRect)rp;
- (void)draw;

@end
