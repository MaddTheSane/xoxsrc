
#import <appkit/appkit.h>

#import "Actor.h"

@interface Cave:Actor
{
	XXLine cave[8];
	Actor *mySmile;
}

@end

@interface Smiley:Actor
{
	int frameDir;
	id myCave;
	int hits;
}

@end

@interface Skull:Actor
{
	int hits;
	unsigned moveChangeTime;
	float velChange;
	unsigned dirUpdate;
}

@end
