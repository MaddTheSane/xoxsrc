
#import <appkit/appkit.h>

#import "Actor.h"

@interface Eye:Actor
{
	unsigned expireTime;
	int frameCnt;
}
@end

@interface CrabNebula:Actor
{
	float ogx, ogy;
}
@end
