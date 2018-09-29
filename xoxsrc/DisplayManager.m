
#import "DisplayManager.h"
#import "CacheManager.h"
#import "Thinker.h"
#import "xoxDefs.h"

@implementation DisplayManager

- init
{
	self = [super init];

	eraseList = [[NSMutableArray alloc]
		init];
	whiteList = [[NSMutableArray alloc]
				 init];
	drawList = [[NSMutableArray alloc]
				init];

	return self;
}

- (void)oneStep
{
	if ([eraseList count])
	{
		[[NSColor blackColor] set];
		NSRectArray rarr = calloc(sizeof(NSRect), eraseList.count);
		
		for (NSInteger i = 0; i < eraseList.count; i++) {
			NSValue *theVal = eraseList[i];
			rarr[i] = theVal.rectValue;
		}
		NSRectFillList(rarr, eraseList.count);
		[eraseList removeAllObjects];
		free(rarr);
	}

	[drawList makeObjectsPerformSelector:@selector(draw)];
	[drawList removeAllObjects];

	if ([whiteList count])
	{
		NSRectArray rarr = calloc(sizeof(NSRect), whiteList.count);
		
		for (NSInteger i = 0; i < whiteList.count; i++) {
			NSValue *theVal = whiteList[i];
			rarr[i] = theVal.rectValue;
		}
		[[NSColor whiteColor] set];
		NSRectFillList(rarr, whiteList.count);
		[whiteList removeAllObjects];
		free(rarr);
	}
}

- (void)erase:(NSRect)r
{
	// it looks best if we erase by drawing from the cache
	[cacheMgr displayRect:r];
}

- (void)displayRect:(NSRect)r
{
	// it looks best if we erase by drawing from the cache
	[cacheMgr displayRect:r];
}

- (void)drawWhiteRect:(NSRect)r
{
	[whiteList addObject:[NSValue valueWithRect:r]];
}

- (void)draw:sender;
{
	[drawList addObject:sender];
}


@end
