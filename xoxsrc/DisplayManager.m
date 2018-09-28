
#import "DisplayManager.h"
#import "CacheManager.h"
#import "Thinker.h"
#import "xoxDefs.h"

@implementation DisplayManager

- init
{
	[super init];

	eraseList = [[Storage allocFromZone:[self zone]]
		initCount:8
		elementSize: sizeof(NSRect)
		description: @encode(NSRect)];
	whiteList = [[Storage allocFromZone:[self zone]]
		initCount:8
		elementSize: sizeof(NSRect)
		description: @encode(NSRect)];
	drawList = [[List allocFromZone:[self zone]] init];

	return self;
}

- oneStep
{
	if ([eraseList count])
	{
		PSsetgray(NX_BLACK);
		NSRectFillList(eraseList->dataPtr, eraseList->numElements);
		[eraseList empty];
	}

	[drawList performInOrder:@selector(draw)];
	[drawList empty];

	if ([whiteList count])
	{
		PSsetgray(NX_WHITE);
		NSRectFillList(whiteList->dataPtr, whiteList->numElements);
		[whiteList empty];
	}
	return self;
}

- erase:(NSRect *)r
{
	// it looks best if we erase by drawing from the cache
	[cacheMgr displayRect:r];
	return self;
}

- displayRect:(NSRect *)r
{
	// it looks best if we erase by drawing from the cache
	[cacheMgr displayRect:r];
	return self;
}

- drawWhiteRect:(NSRect *)r
{
	[whiteList addElement:r];
	return self;
}

- draw:sender;
{
	[drawList addObject:sender];
	return self;
}


@end
