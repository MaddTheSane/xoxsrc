
#include <sys/time.h>
#import "Thinker.h"
#import "BackView.h"
#import "DisplayManager.h"
#import "CacheManager.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Xoxeroids.h"
#import "EKProgressView.h"

@implementation Thinker

unsigned timeInMS, lastTimeInMS, obscureTime;
NSTimeInterval timeScale;
CGFloat maxTimeScale;
CGFloat collisionDistance;
ActorMgr *actorMgr;
DisplayManager *displayMgr;
CacheManager *cacheMgr;
SoundMgr *soundMgr;
__kindof id<Scenario> scenario;
id mainView;
BackView *abackView;
id gcontentView;
GameList *gameList;
int gameIndex;
id sceneOneStepper;

BOOL pauseState;
BOOL fullScreen;
BOOL keepLooping;
BOOL obscureMouse;

NXEventHandle eventhandle;
double oldKeyThreshold;

int		BULLET1SND, 
		BULLET2SND, 
		EXP1SND, 
		EXP2SND, 
		EXP3SND, 
		SHIPSND, 
		WARPSND,
		FUTILITYSND;

static unsigned currentTimeInMs()
{
    struct timeval curTime;
    gettimeofday (&curTime, NULL);
    return (unsigned)((curTime.tv_sec) * 1000 + curTime.tv_usec / 1000);
}

- init
{
	if (self = [super init]) {
	imageNames = [[NSMutableArray alloc] init];
	imageRequestor = [[NSMutableArray alloc] init];
	soundsToCache = [[NSMutableArray alloc] init];
	}
	return self;
}
id commonStuff = nil;

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSBundle *commonBundle;
	NSString *path;

	srandom(time(0) & 0x7fffffff);
	timeInMS = lastTimeInMS = currentTimeInMs();

	eventhandle = NXOpenEventStatus();
	oldKeyThreshold = NXKeyRepeatThreshold(eventhandle);
	NXSetKeyRepeatThreshold(eventhandle, 300.0);

	[self createTimer];
	mainView = abackView = backView;
	gameWindow = littleWindow;
	gcontentView = [littleWindow contentView];
	inspectorFrame = [nullInfoBox frame];

	actorMgr = [[ActorMgr alloc] init];
	displayMgr = [[DisplayManager alloc] init];
	cacheMgr = [[CacheManager alloc] init];
	[self getSoundSetting];

	[self setupGameBrowser];

	path = [[NSBundle mainBundle] pathForResource:@"CommonEffects" ofType:@"XoXo"];
	commonBundle = [[NSBundle alloc] initWithPath:path];
	commonStuff = [[[commonBundle classNamed:@"CommonStuff"] alloc] init];

	[self selectGame:nil];


	[[invisibleInfoBox window] makeKeyAndOrderFront:self];

	[littleWindow makeFirstResponder:mainView];
	[littleWindow setBackgroundColor:[NSColor blackColor]];
	[littleWindow makeKeyAndOrderFront:self];

	[self newGame:self];
}

//void timedEntryFunction (DPSTimedEntry timedEntry, double timeNow, void *theObject)
//{	[(id)theObject doOneStepLoop];
//}

- (void)createTimer
{
	if (!timerValid)
	{
		timerValid = YES;
		timer = DPSAddTimedEntry(0.02, &timedEntryFunction, self, NX_BASETHRESHOLD);
	}
}

- (void)removeTimer
{
	if (timerValid) [timer invalidate];
	timer = nil;
	timerValid = NO;
}

- (void)doOneStepLoop
{
    NSEvent *dummyEvent, *pEvent;
	
	[mainView lockFocus];

	keepLooping = YES;

	do {

		[self oneStep];

		while ([NSApp peekNextEvent:NX_ALLEVENTS into:&dummyEvent 
				waitFor:0 threshold:NX_BASETHRESHOLD])
		{
			if ((dummyEvent.type & (NX_KEYDOWNMASK|NX_KEYUPMASK)) && 
				(!(dummyEvent.flags & NX_COMMANDMASK)))
			{
				// if it's a key event other than a command key, we save
				// ourselves the overhead of a focus change

				pEvent = [NSApp getNextEvent: NX_ALLEVENTS 
						waitFor:0 threshold:NX_BASETHRESHOLD];
				[NSApp sendEvent: pEvent];
			}
			else
			{
				keepLooping = NO;
				break;
			}
		}

	   } while (timerValid && keepLooping);

	[mainView unlockFocus];
}

- (void)justOneStep
{
	[mainView lockFocus];
//	[self oneStep];
	{	// new behavior to replace onestep above
		[actorMgr makeActorsPerform:@selector(erase)];
		[cacheMgr oneStep];
		[displayMgr oneStep];
	}
	[mainView unlockFocus];
}

- (void)oneStep
{
	float tinterval;

	lastTimeInMS = timeInMS;
	timeInMS = currentTimeInMs();
	tinterval = timeInMS - lastTimeInMS;

	if (obscureMouse && (timeInMS > obscureTime))
	{
		[NSCursor hide];
		obscureTime = timeInMS + 5000;
	}

	if (tinterval < 1) tinterval = 1;
	timeScale = tinterval/100;
	if (timeScale > maxTimeScale) timeScale = maxTimeScale;

	[soundMgr oneStep];
	[(id<DrawManager>)sceneOneStepper oneStep];		// notify the scenario, if it cares
	[actorMgr oneStep];

	[cacheMgr oneStep];
	[displayMgr oneStep];

	NXPing ();	// Synchronize postscript for smoother animation
}

// This should return a float between 0 and 1
float frandom()
{
	float val = (random() & 0x7fffffff);
	val /= 0x7fffffff;
	return val;
}

float randBetween(float a, float b)
{
	float val, scale, t;

	if (a > b)
	{	t = a; a = b; b = t;
	}
	
	scale = (b-a);
	val = scale * frandom();
	return (a + val);
}

- (IBAction)toggleFullScreen:sender;
{
	[self setFullScreen: !fullScreen];
}

- (void)setFullScreen:(BOOL)flag
{
	if (flag)
	{
		NSRect r={{0, 0}};
		if ([self bigWindowOK])
		{
			[NSApp getScreenSize:&(r.size)];
			[self createBigWindowIfNecessary];
			tweakWindow([bigWindow windowNumber], 40);

			[self installGameViewsIntoWindow:bigWindow];

			[bigWindow placeWindow:&r];
			[bigWindow makeKeyAndOrderFront:self];
			[bigWindow display];
		}
		else flag = NO;
	}
	else
	{
		[bigWindow orderOut:self];
		[self installGameViewsIntoWindow:littleWindow];
		[littleWindow makeKeyAndOrderFront:self];
		[littleWindow display];
	}
	fullScreen = flag;
}

- (IBAction)toggleUserPause:sender
{
	[self setPauseState: (pauseState ^ 1)];
}

- (void)setPauseState:(BOOL)flag
{
	if (flag) [self removeTimer];
	else [self createTimer];
	pauseState = flag;
}

- (void)applicationDidHide:(NSNotification *)notification
{
	[self setPauseState:(pauseState | 2)];
}

- (void)applicationDidUnhide:(NSNotification *)notification
{
	[self setPauseState:(pauseState & ~2)];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	[self setPauseState:(pauseState & ~4)];
	NXSetKeyRepeatThreshold(eventhandle, 300.0);
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
	[self setPauseState:(pauseState | 4)];
	NXSetKeyRepeatThreshold(eventhandle, oldKeyThreshold);
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	if (notification.object == littleWindow || notification.object == bigWindow)
		[self setPauseState:(pauseState & ~8)];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
	if (notification.object == littleWindow || notification.object == bigWindow)
		[self setPauseState:(pauseState | 8)];
}

- (void)windowDidMove:(NSNotification *)notification
{
	if ((notification.object == littleWindow) && ([scenario respondsToSelector:@selector(windowDidMove:)]))
		[scenario windowDidMove:notification];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	NXSetKeyRepeatThreshold(eventhandle, oldKeyThreshold);
}

- (IBAction)newGame:sender
{
	[self setPauseState:(pauseState & ~1)];
	[actorMgr setGameStatus:GAME_RUNNING];
	[actorMgr requestLevel:0];
}

// Image Loading status stuff was borrowed from Erik Kay, 
// slightly munged for xox by sam
// add an image filename to the image resource list
- (void)addImageResource:(NSString *)r for:whom
{
    //! we cheat here a bit and take advantage of the fact that a list just
    //! takes id's which are pointers, and therefore, character pointers work
    //! just fine too.  Probably not the best thing to do...
    [imageNames addObject:r];
    [imageRequestor addObject:whom];
}

- (void)addSoundResource:(int)sound
{
	[soundsToCache addObject:@(sound)];
}

// preload resources for the app

- (void)loadResources
{
	NSInteger i, count, progress = 0;
	NSString *str;
	id whom;
	int soundndx;
    
    // actually load the images
    count = [imageNames count];
    for (i = 0; i < count; i++)
	{
		str = [imageNames objectAtIndex:i];
		whom = [imageRequestor objectAtIndex:i];
		[statusText setStringValue:str];
		[whom cacheImage:str];
		// update the progress bar
		progress++;
		[progressView setProgress:progress];
		//NXPing();
    }

    // convert/cache the sounds
    count = [soundsToCache count];
    for (i = 0; i < count; i++)
	{
		soundndx = *(int *)[soundsToCache elementAtIndex:i];
		str = [soundMgr soundName:soundndx];
		if (str)
		{
			[statusText setStringValue:str];
			[soundMgr cacheSound:soundndx];
		}
		// update the progress bar
		progress++;
		[progressView setProgress:progress];
		//NXPing();
    }

	[imageNames removeAllObjects];
	[imageRequestor removeAllObjects];
	[soundsToCache removeAllObjects];
}
@end
