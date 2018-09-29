#import <AppKit/AppKit.h>
#import "Thinker.h"
#import "xoxDefs.h"
#import "BackView.h"
#import "Scenario.h"
#import "ActorMgr.h"
#import "GameInfo.h"
#import "BackWindow.h"
#import "CacheManager.h"
#import "EKProgressView.h"
#import "SoundMgr.h"
#include <sys/types.h>
#include <sys/dir.h>

extern id sceneOneStepper;
extern BOOL pauseState;
extern BOOL obscureMouse;

@implementation Thinker(thinker2)

- setupGameBrowser
{
	id theMatrix;
	char buf[MAXPATHLEN];
	const char *ptr;

	strcpy( buf, NXHomeDirectory());
	strcat( buf, "/Library/XoxGames");

	gameList = [[GameList alloc] init];

	[self loadGamesFrom:buf];
	ptr = NXGetDefaultValue([NSApp appName], "altGamePath");
	if (ptr) [self loadGamesFrom:ptr];
	[self loadGamesFrom: [[NSBundle mainBundle] directory]];
	[self loadGamesFrom: "/LocalLibrary/XoxGames"];

	[gameList sort];

	[scenarioBrowser loadColumnZero];
	theMatrix = [scenarioBrowser matrixInColumn:0];
	[theMatrix selectCellAt:gameIndex :0];
	[theMatrix scrollCellToVisible:gameIndex :0];

	return self;
}

- getSoundSetting
{
	soundMgr = [[SoundMgr alloc] init];

	
	if ([NSUserDefaults.standardUserDefaults boolForKey:@"Sound"])
	{
		[soundMgr turnSoundOn:nil];
	}
	
	[soundButton setState:[soundMgr isSoundEnabled]];
	return self;
}

- (IBAction)setSound:sender
{
	if ([soundButton state])
	{	if (![soundMgr turnSoundOn:sender]) [soundButton setState:0];
	}
	else
	{	[soundMgr turnSoundOff];
	}

	if ([soundMgr isSoundEnabled])
		[NSUserDefaults.standardUserDefaults setBool:YES forKey:@"Sound"];
	else [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"Sound"];

}

- (IBAction)selectGame:sender
{
	// sender is the game browser, or nil if sent from within the app
	int i;
	int index = [[scenarioBrowser matrixInColumn:0] selectedRow];
	NSRect f1;
	id inspector;
	GAME_STATUS gs;
	
	if (sender && (index == gameIndex)) return;

	[scenario scenarioDeselected];

	[cacheMgr setBackground:NO];

	gameIndex = index;

	scenario = [self getScenario];

	if (sender) NXWriteDefault([NSApp appName], "whichGame", [gameList nameAt: index]);

	gx = gy = 0;
	maxTimeScale = 1.5;
	collisionDistance = 1.25;
	if ([scenario respondsToSelector:@selector(oneStep)]) sceneOneStepper = scenario;
	else sceneOneStepper = nil;
	if ([scenario respondsToSelector:@selector(shouldObscureCursor)] &&
		![scenario shouldObscureCursor]) obscureMouse = NO;
	else obscureMouse = YES;

	[keyTimerList removeAllObjects];

	inspector = [scenario infoView];
	[inspector getFrame:&f1];
	[invisibleInfoBox setContentView: nullInfoBox];
	[nullInfoBox sizeTo:f1.size.width :f1.size.height byWindowCorner:3];

	[inspector setFrame:&f1];
	[invisibleInfoBox setContentView: inspector];
	[[invisibleInfoBox window] display];

	[self installGameViewsIntoWindow:littleWindow];

	if (i = [[gameList objectAt: gameIndex] level]) [actorMgr requestLevel:i];
	else [actorMgr requestLevel:0];

	[self adjustLittleWindowSize];
	[scenario scenarioSelected];

	[self setPauseState: (pauseState & ~1)];
	gs = [(GameInfo *)[gameList objectAtIndex: gameIndex] status];
	if (gs == GAME_DYING || gs == GAME_DEAD)
		[self newGame:self];
	else [actorMgr setGameStatus:gs];

	[littleWindow display];
	[littleWindow makeKeyAndOrderFront:self];

	if (sender) [self justOneStep];		// yech! I should have a better way to get
										// everything set up...
}

- installGameViewsIntoWindow:w
{
	int i;

	for (i=([[gcontentView subviews] count]-1); i>=0; i--)
	{	[[[gcontentView subviews] objectAtIndex:i] removeFromSuperview];
	}

	gameWindow = w;
	gcontentView = [w contentView];

	if ([scenario respondsToSelector:@selector(tile)])
		mainView = [scenario tile];
	else
	{
		NSRect r;
		[gcontentView getBounds:&r];
		[abackView setFrame:&r];
		[gcontentView addSubview:abackView];
		mainView = abackView;
	}

	[gameWindow makeFirstResponder:mainView];

	return self;
}


- (BOOL)browser:sender isColumnValid:(int)column
{
	return browserValid;
}

- (void)addCellWithString:(NSString *)str atRow:(int)row toMatrix:(NSMatrix*)matrix
{
	id theCell;
	
	[matrix insertRow:row];
	theCell = [matrix cellAtRow:row column:0];
	[theCell setStringValue:str];
	[theCell setLoaded:YES];
	[theCell setLeaf:YES];
}

- (int)browser:sender createRowsForColumn:(int)column inMatrix:(NSMatrix*)matrix
{
	const char *ptr;
	int i;
	
	// this shouldn't happen...
	if (browserValid) return [matrix cellCount];

	for (i = 0; i < [gameList count]; i++)
		[self addCellWithString:NXLocalString([gameList nameAt: i], 0, 0)
			at:(i) toMatrix:matrix];
			
	ptr = NXGetDefaultValue([NSApp appName], "whichGame");
	if (ptr)
	{
	    for (i = 0; i < [gameList count]; i++)
		if (strcmp(ptr, [gameList nameAt: i]) == 0)
		{
		    gameIndex = i;
		    break;
		}
	}
	
	browserValid = YES;
	return [matrix cellCount];
}

//  Dynamically load all object files found in the specified directory
//	if we find a module in several places, we save the additional paths
//	in case they point to modules for different architectures

- (void)loadGamesFrom: (NSString *) dirname
{
    DIR *dir;
    struct direct *de;
    char path[MAXPATHLEN];
    char name[60];
	char *iptr;
	GameInfo *m;
	BOOL validName;


	dir = opendir(dirname.fileSystemRepresentation);
	if (dir == NULL)
	{
		return;
	}

	while ((de = readdir(dir)) != NULL)
	{
		int i, numstrings;
	
		// Ignore '.'-files (not really necessary, I guess)
		if (de->d_name[0] == '.')
			continue;

		validName = NO;
		if (de->d_namlen > 4 && 
				!strcmp(&de->d_name[de->d_namlen-4], ".XoX"))
		{
			validName = YES;
		}

		if (!validName) continue;


		// check if the name matches a module already loaded
		numstrings = [gameList count];
		strcpy(name, de->d_name);

		// Smash out the '.' in "Foo.XoX"
		if (iptr = rindex(name, '.'))
			*iptr = '\0';

		for (i=0; i< numstrings; i++)
		{
			if (!strcmp(name, [gameList nameAt:i]))
			{
				// we already have a module with this name, but will save the path anyway
				validName = NO;
				sprintf(path,"%s/%s.XoX",dirname,name);
				[[gameList objectAt:i] appendPath:path];
				break;
			}
		}
		if (!validName) continue;
		
		sprintf(path,"%s/%s.XoX",dirname,name);
		
		m = [[GameInfo alloc] 
			initWithScenario:NULL name:name path:path];
	    [gameList addObject: m];
	}

    closedir(dir);
}

- getScenario
{
	id progressWin = [progressView window];

	if (![gameList scenarioAt:gameIndex])
	{
		id theClass = nil;
		GameInfo *gi;
		id theScenario = nil;

		gi = [gameList objectAt: gameIndex];

		if ([gi path])	// we have path but no instance, must load class
		{
			char str[80];
			[progressView setProgress:0];
			// fixme - these strings should be localizable...
			sprintf(str,"Loading %s",[gi scenarioName]);
			[[progressView window] setTitle:str];
			[[statusText setStringValue:"loading code"] display];
			[progressWin makeKeyAndOrderFront:self];
			NXPing();

			do
			{
				NXBundle *myBundle = [[NXBundle allocFromZone:bundleZone]
					initForDirectory:[gi path]];

				theClass = [myBundle classNamed:[gi scenarioName]];

				if (theClass)
				{
					theScenario = [[theClass allocFromZone:scenarioZone] init];
				}
				else
				{
					[myBundle free];
				}

			} while ((!theClass) && [gi useNextPath]);

			[gi discardAltPaths];

			[[progressView setMin:0] setMax:[imageNames count] + [soundsToCache count]];
			[progressView setProgress:0];
			[self loadResources];
			[progressWin close];

			if (!theClass)
			{
				NXRunAlertPanel([NSApp appName], NXLocalString(
					"Could not load class: %s",0,0),
					NULL, NULL, NULL, [gi scenarioName]);
			}
		}
		[gi setScenario:theScenario];
	}

	return [gameList scenarioAt:gameIndex];
}

- (void)createBigWindowIfNecessary
{
	if (!bigWindow)
	{
		NSRect r={{0, 0}};
		[NSApp getScreenSize:&(r.size)];

		bigWindow = [[BackWindow allocFromZone:[self zone]]
			initContent:&r style:NX_PLAINSTYLE
			backing:NX_NONRETAINED buttonMask:0 defer:NO];

		[bigWindow setBackgroundGray:NX_BLACK];
		[bigWindow setDelegate:self];
	}
}

// delegate method invoked by window
- windowWillResize:sender toSize:(NSSize *)frameSize
{
	NSRect frm = {0,0,0,0};
	NSRect cnt = {0,0,0,0};

	if (![scenario respondsTo:@selector(newWindowContentSize:)])
		return self;

	frm.size = *frameSize;
	[Window getContentRect:&cnt forFrameRect:&frm style:[sender style]];
	if ([scenario newWindowContentSize:&(cnt.size)])
	{
		[Window getFrameRect:&frm forContentRect:&cnt style:[sender style]];
		*frameSize = frm.size;
	}
	return self;
}

- (void)adjustLittleWindowSize
{
	NSRect contRect;

	if (![scenario respondsToSelector:@selector(newWindowContentSize:)])
		return;

	[[littleWindow contentView] getBounds:&contRect];
	if ([scenario newWindowContentSize:&contRect.size])
	{
		[[littleWindow contentView] sizeTo:contRect.size.width 
			:contRect.size.height byWindowCorner:3];
	}
}

- (BOOL)bigWindowOK
{
	NSSize screenSize;

	if (![scenario respondsTo:@selector(newWindowContentSize:)])
		return YES;

	[NSApp getScreenSize:&screenSize];
	return (![scenario newWindowContentSize:&screenSize]);
}


@end












