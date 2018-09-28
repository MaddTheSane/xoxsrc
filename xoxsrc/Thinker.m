
#import "Thinker.h"
#import "BackView.h"
#import "DisplayManager.h"
#import "CacheManager.h"
#import "ActorMgr.h"
#import "SoundMgr.h"
#import "Xoxeroids.h"
#import "psfuncts.h"
#import "EKProgressView.h"
#import <drivers/event_status_driver.h>

@implementation Thinker

unsigned timeInMS, lastTimeInMS, obscureTime;
float timeScale;
float maxTimeScale;
float collisionDistance;
id actorMgr, displayMgr, cacheMgr, soundMgr;
id scenario;
id mainView;
id abackView;
id gcontentView;
id gameList;
int gameIndex;
id sceneOneStepper;

BOOL pauseState;
BOOL fullScreen;
BOOL keepLooping;
BOOL obscureMouse;

NSEventHandle eventhandle;
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
    return (curTime.tv_sec) * 1000 + curTime.tv_usec / 1000;
}

NXZone *scenarioZone, *bundleZone;

- init
{
	[super init];
	imageNames = [[List alloc] init];
	imageRequestor = [[List alloc] init];
	soundsToCache = [[Storage allocFromZone:[self zone]]
		initCount:8
		elementSize: sizeof(int)
		description: @encode(int)];
	return self;
}

- appDidInit:sender
{
	NXZone *actorZone, *displayZone;
	id commonBundle;
	char path[1024];

	srandom(time(0));
	timeInMS = lastTimeInMS = currentTimeInMs();

	eventhandle = NXOpenEventStatus();
	oldKeyThreshold = NXKeyRepeatThreshold(eventhandle);
	NXSetKeyRepeatThreshold(eventhandle, 300.0);

	[self createTimer];
	mainView = abackView = backView;
	gameWindow = littleWindow;
	gcontentView = [littleWindow contentView];
	[nullInfoBox getFrame: &inspectorFrame];

	actorZone = NXCreateZone(vm_page_size, vm_page_size, YES);
	displayZone = NXCreateZone(vm_page_size, vm_page_size, YES);
	scenarioZone = NXCreateZone(vm_page_size, vm_page_size, YES);
	bundleZone = NXCreateZone(vm_page_size, vm_page_size, YES);

	actorMgr = [[ActorMgr allocFromZone:actorZone] init];
	displayMgr = [[DisplayManager allocFromZone:displayZone] init];
	cacheMgr = [[CacheManager allocFromZone:displayZone] init];
	[self getSoundSetting];

	[self setupGameBrowser];

	[[NXBundle mainBundle] getPath:path forResource:"CommonEffects" ofType:"XoXo"];
	commonBundle = [[NXBundle allocFromZone:bundleZone] initForDirectory:path];
	[[[commonBundle classNamed:"CommonStuff"] allocFromZone:scenarioZone] init];

	[self selectGame:nil];


	[[invisibleInfoBox window] makeKeyAndOrderFront:self];

	[littleWindow makeFirstResponder:mainView];
	[littleWindow setBackgroundGray:NX_BLACK];
	[littleWindow makeKeyAndOrderFront:self];

	[self newGame:self];

    return self;
}

void timedEntryFunction (DPSTimedEntry timedEntry, double timeNow, void *theObject)
{	[(id)theObject doOneStepLoop];
}

- createTimer
{
	if (!timerValid)
	{
		timerValid = YES;
		timer = DPSAddTimedEntry(0.02, &timedEntryFunction, self, NX_BASETHRESHOLD);
	}
	return self;
}

- removeTimer
{
	if (timerValid) DPSRemoveTimedEntry (timer);
	timerValid = NO;
	return self;
}

- doOneStepLoop
{
    NSEvent dummyEvent, *pEvent;
	
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
	
	return self;

}

- justOneStep
{
	[mainView lockFocus];
//	[self oneStep];
	{	// new behavior to replace onestep above
		[actorMgr makeActorsPerform:@selector(erase)];
		[cacheMgr oneStep];
		[displayMgr oneStep];
	}
	[mainView unlockFocus];
	return self;
}

- oneStep
{
	float tinterval;

	lastTimeInMS = timeInMS;
	timeInMS = currentTimeInMs();
	tinterval = timeInMS - lastTimeInMS;

	if (obscureMouse && (timeInMS > obscureTime))
	{
		PSobscurecursor();
		obscureTime = timeInMS + 5000;
	}

	if (tinterval < 1) tinterval = 1;
	timeScale = tinterval/100;
	if (timeScale > maxTimeScale) timeScale = maxTimeScale;

	[soundMgr oneStep];
	[sceneOneStepper oneStep];		// notify the scenario, if it cares
	[actorMgr oneStep];

	[cacheMgr oneStep];
	[displayMgr oneStep];

	NXPing ();	// Synchronize postscript for smoother animation
	return self;
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

- toggleFullScreen:sender;
{
	[self setFullScreen: !fullScreen];
	return self;
}

- setFullScreen:(BOOL)flag
{
	if (flag)
	{
		NSRect r={{0, 0}};
		if ([self bigWindowOK])
		{
			[NSApp getScreenSize:&(r.size)];
			[self createBigWindowIfNecessary];
			tweakWindow([bigWindow windowNum], 40);

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
	return self;
}

- toggleUserPause:sender
{
	[self setPauseState: (pauseState ^ 1)];
	return self;
}

- setPauseState:(BOOL)flag
{
	if (flag) [self removeTimer];
	else [self createTimer];
	pauseState = flag;
	return self;
}

- appDidHide:sender
{
	[self setPauseState:(pauseState | 2)];
	return self;
}

- appDidUnhide:sender
{
	[self setPauseState:(pauseState & ~2)];
	return self;
}

- appDidBecomeActive:sender
{
	[self setPauseState:(pauseState & ~4)];
	NXSetKeyRepeatThreshold(eventhandle, 300.0);
	return self;
}

- appDidResignActive:sender
{
	[self setPauseState:(pauseState | 4)];
	NXSetKeyRepeatThreshold(eventhandle, oldKeyThreshold);
	return self;
}

- windowDidBecomeKey:sender
{
	if (sender == littleWindow || sender == bigWindow)
		[self setPauseState:(pauseState & ~8)];
	return self;
}

- windowDidResignKey:sender
{
	if (sender == littleWindow || sender == bigWindow)
		[self setPauseState:(pauseState | 8)];
	return self;
}

- windowDidMove:sender
{
	if ((sender == littleWindow) && ([scenario respondsTo:@selector(windowDidMove:)]))
		[scenario windowDidMove:sender];
	return self;
}

- appWillTerminate:sender
{
	NXSetKeyRepeatThreshold(eventhandle, oldKeyThreshold);
	return self;
}

- newGame:sender
{
	[self setPauseState:(pauseState & ~1)];
	[actorMgr setGameStatus:GAME_RUNNING];
	[actorMgr requestLevel:0];
	return self;
}

// Image Loading status stuff was borrowed from Erik Kay, 
// slightly munged for xox by sam
// add an image filename to the image resource list
- addImageResource:(const char *)r for:whom
{
    //! we cheat here a bit and take advantage of the fact that a list just
    //! takes id's which are pointers, and therefore, character pointers work
    //! just fine too.  Probably not the best thing to do...
    [imageNames addObject:(id)NXCopyStringBuffer(r)];
    [imageRequestor addObject:whom];
    return self;
}

- addSoundResource:(int)sound
{
	[soundsToCache addElement:&sound];
	return self;
}

// preload resources for the app

- loadResources
{
	int i, count, progress = 0;
	char *str;
	id whom;
	int soundndx;
    
    // actually load the images
    count = [imageNames count];
    for (i = 0; i < count; i++)
	{
		str = (char *)[imageNames objectAt:i];
		whom = [imageRequestor objectAt:i];
		[[statusText setStringValue:str] display];
		[whom cacheImage:str];
		free(str);
		// update the progress bar
		progress++;
		[progressView setProgress:progress];
		NXPing();
    }

    // convert/cache the sounds
    count = [soundsToCache count];
    for (i = 0; i < count; i++)
	{
		soundndx = *(int *)[soundsToCache elementAt:i];
		str = (char *)[soundMgr soundName:soundndx];
		if (str)
		{
			[[statusText setStringValue:str] display];
			[soundMgr cacheSound:soundndx];
		}
		// update the progress bar
		progress++;
		[progressView setProgress:progress];
		NXPing();
    }

	[imageNames empty];
	[imageRequestor empty];
	[soundsToCache empty];
    
    return self;
}
@end

@implementation List (XoxAdditions)

- performInOrder:(SEL)aSelector
{
    int i, count = numElements;
    for (i=0; i<count; i++)
		[dataPtr[i] perform: aSelector];
    return self;
}

@end
