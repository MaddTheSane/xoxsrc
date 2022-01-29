
#import <Foundation/Foundation.h>
#include <CoreGraphics/CGBase.h>

@class BackView;
@class CacheManager;
@class DisplayManager;
@class ActorMgr;
@class SoundMgr;
@protocol Scenario;

extern float randBetween(float a, float b);

extern unsigned timeInMS, lastTimeInMS;
extern NSTimeInterval timeScale;
extern CGFloat maxTimeScale;
extern CGFloat collisionDistance;
extern CGFloat gx, gy;
extern id<Scenario> scenario;
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

typedef NS_ENUM(int, XoXCollisionParadigm) {
    XoXCollisionAllVersusAll,
	XoXCollisionGoodVersusEvil,
	XoXCollisionOther,
};

typedef NS_ENUM(int, XoXAlliance) {
    XoXGood,
    XoXEvil,
    XoXDestroyAll,
    XoXNeutral,
    XoXGoodAndBad
};
// with the XoXCollisionGoodVersusEvil paradigm, 
// XoXDestroyAll is collided against XoXGood and XoXEvil but not other XoXDestroyAll
// XoXGoodAndBad goes both in XoXGood and XoXEvil lists; it will collide twice with
//		XoXDestroyAll...

typedef NS_ENUM(int, XoXGameStatus) {
	XoXGameRunning = 0,
	XoXGamePaused,
	XoXGameDying,
	XoXGameDead,
};

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

typedef struct XXLine {
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
