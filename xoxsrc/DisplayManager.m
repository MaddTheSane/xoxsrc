
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
		elementSize: sizeof(NXRect)
		description: @encode(NXRect)];
	whiteList = [[Storage allocFromZone:[self zone]]
		initCount:8
		elementSize: sizeof(NXRect)
		description: @encode(NXRect)];
	drawList = [[List allocFromZone:[self zone]] init];

	return self;
}

- oneStep
{
	if ([eraseList count])
	{
		PSsetgray(NX_BLACK);
		NXRectFillList(eraseList->dataPtr, eraseList->numElements);
		[eraseList empty];
	}

	[drawList performInOrder:@selector(draw)];
	[drawList empty];

	if ([whiteList count])
	{
		PSsetgray(NX_WHITE);
		NXRectFillList(whiteList->dataPtr, whiteList->numElements);
		[whiteList empty];
	}
	return self;
}

- erase:(NXRect *)r
{
	// it looks best if we erase by drawing from the cache
	[cacheMgr displayRect:r];
	return self;
}

- displayRect:(NXRect *)r
{
	// it looks best if we erase by drawing from the cache
	[cacheMgr displayRect:r];
	return self;
}

- drawWhiteRect:(NXRect *)r
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
