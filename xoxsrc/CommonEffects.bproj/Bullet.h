
#import <AppKit/AppKit.h>

#import "Actor.h"

#define BUL_FAST 0
#define BUL_SLOW 1

#define BUL_IMAGE 2

#define BUL_SPIN 0
#define BUL_PLUS 4
#define BUL_RECT 8
#define BUL_CORN 12


@interface Bullet:Actor
{
	float speed;
	unsigned expireTime;
	short min_frame;
	short max_frame;
}

- setBulletImage:(int)tag;

@end
