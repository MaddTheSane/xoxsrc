
#include <CoreGraphics/CGBase.h>

@class BackView;
@class CacheManager;
@class DisplayManager;
@class ActorMgr;
@class SoundMgr;

extern float randBetween(float a, float b);

extern unsigned timeInMS, lastTimeInMS;
extern NSTimeInterval timeScale;
extern CGFloat maxTimeScale;
extern CGFloat collisionDistance;
extern CGFloat gx, gy;
extern id scenario;
extern ActorMgr *actorMgr;
extern CacheManager *cacheMgr;
extern DisplayManager *displayMgr;
extern SoundMgr *soundMgr;
extern id mainView;		//!< whatever the windows main view is
extern BackView *abackView;	//!< an available BackView; use but don't reassign
extern NSView *gcontentView;
extern id keyTimerList;
extern CGFloat xOffset, yOffset;
extern int level;
extern NSRect screenRect;

typedef enum {
	NOSHAPE,
	RECTCIRC,
	RECT,
	RECTARRAY,
	CIRCLE,
	LINEARRAY,
	} COLLISION_SHAPE;

typedef enum {
	ALL_V_ALL,
	GOOD_V_EVIL,
	COLL_OTHER,
	} COLLISION_PARADIGM;

typedef enum {GOOD, EVIL, DESTROYALL, NEUTRAL, GOODNBAD} ALLIANCE;
// with the GOOD_V_EVIL paradigm, 
// DESTROYALL is collided against GOOD and EVIL but not other DESTROYALL
// GOODNBAD goes both in GOOD and EVIL lists; it will collide twice with
//		DESTROYALL...

typedef enum {
	GAME_RUNNING = 0,
	GAME_PAUSED,
	GAME_DYING,
	GAME_DEAD,
	} GAME_STATUS;

// tiers could be used to determine which objects go in front of others;
// I currently don't do this since proper sorting is expensive and/or tricky
typedef enum {
	FARBACKT= -20,
	BACKT= -10,
	NORMALT= 0,
	SHIPT= 10,
	TOPT= 20
	} TIER;

typedef enum {LEFT= 1, STRAIGHT=0, RIGHT= -1} ROTATION;

#define PI (3.141592653589)

typedef struct {
    CGFloat x1,y1,x2,y2;
} XXLine;

typedef enum {
	ACTORSRECT,
	ACTORSCIRC,
	XRECT,
	XLINE,
	} COLLISION_REASON;

extern int xx_bullet, xx_explosion, xx_shield, xx_space, xx_spacespin;
extern int xx_asteroid, xx_base, xx_cannon, xx_cannonball, xx_eye;
extern int xx_mine, xx_minefragment, xx_rocket;
extern int xx_swbullet, xx_swship, xx_swspace;

extern int
		BULLET1SND, 
		BULLET2SND, 
		EXP1SND, 
		EXP2SND, 
		EXP3SND, 
		SHIPSND, 
		WARPSND,
		FUTILITYSND;
