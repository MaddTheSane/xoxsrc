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

- (void)setupGameBrowser
{
	NSMatrix *theMatrix;
	char buf[MAXPATHLEN];
	const char *ptr;

	strcpy( buf, NXHomeDirectory());
	strcat( buf, "/Library/XoxGames");

	gameList = [[GameList alloc] init];

	[self loadGamesFrom:buf];
	ptr = NXGetDefaultValue([NSApp appName], "altGamePath");
	if (ptr) [self loadGamesFrom:ptr];
	[self loadGamesFrom: [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]];
	[self loadGamesFrom: @"/LocalLibrary/XoxGames"];

	[gameList sort];

	[scenarioBrowser loadColumnZero];
	theMatrix = [scenarioBrowser matrixInColumn:0];
	[theMatrix selectCellAtRow:gameIndex column:0];
	[theMatrix scrollCellToVisibleAtRow:gameIndex column:0];
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
	NSInteger index = [[scenarioBrowser matrixInColumn:0] selectedRow];
	NSRect f1;
	id inspector;
	XoXGameStatus gs;
	
	if (sender && (index == gameIndex)) return;

	[scenario scenarioDeselected];

	[cacheMgr setBackground:NO];

	gameIndex = index;

	scenario = [self getScenario];

	if (sender) [NSUserDefaults.standardUserDefaults setObject:[gameList nameAtIndex: index] forKey:@"whichGame"];

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

	[inspector setFrame:f1];
	[invisibleInfoBox setContentView: inspector];
	[[invisibleInfoBox window] display];

	[self installGameViewsIntoWindow:littleWindow];

	if (i = [[gameList objectAtIndex: gameIndex] level]) [actorMgr requestLevel:i];
	else [actorMgr requestLevel:0];

	[self adjustLittleWindowSize];
	[scenario scenarioSelected];

	[self setPauseState: (pauseState & ~1)];
	gs = [(GameInfo *)[gameList objectAtIndex: gameIndex] status];
	if (gs == XoXGameDying || gs == XoXGameDead)
		[self newGame:self];
	else [actorMgr setGameStatus:gs];

	[littleWindow display];
	[littleWindow makeKeyAndOrderFront:self];

	if (sender) [self justOneStep];		// yech! I should have a better way to get
										// everything set up...
}

- installGameViewsIntoWindow:w
{
	NSInteger i;

	for (i=([[gcontentView subviews] count]-1); i>=0; i--)
	{	[[[gcontentView subviews] objectAtIndex:i] removeFromSuperview];
	}

	gameWindow = w;
	gcontentView = [w contentView];

	if ([scenario respondsToSelector:@selector(tile)])
		mainView = [(id<Scenario>)scenario tile];
	else
	{
		NSRect r;
		r = [gcontentView bounds];
		[abackView setFrame:r];
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

- (NSInteger)browser:(NSBrowser *)sender createRowsForColumn:(NSInteger)column inMatrix:(NSMatrix*)matrix
{
	NSString *ptr;
	int i;
	
	// this shouldn't happen...
	if (browserValid) return [matrix cells].count;

	for (i = 0; i < [gameList count]; i++)
		[self addCellWithString:NXLocalString([gameList nameAt: i], 0, 0)
			at:(i) toMatrix:matrix];
			
	ptr = [NSUserDefaults.standardUserDefaults stringForKey:@"whichGame"];
	if (ptr) {
		for (i = 0; i < [gameList count]; i++) {
			if ([ptr isEqualToString:[gameList nameAtIndex: i]]) {
				gameIndex = i;
				break;
			}
		}
	}
	
	browserValid = YES;
	return [matrix cells].count;
}

//  Dynamically load all object files found in the specified directory
//	if we find a module in several places, we save the additional paths
//	in case they point to modules for different architectures

- (void)loadGamesFrom: (NSString *) dirname
{
    DIR *dir;
    struct direct *de;
    NSString *path;
    NSString *name;
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
		name = @(de->d_name);

		// Smash out the '.' in "Foo.XoX"
		if (iptr = rindex(name, '.'))
			*iptr = '\0';

		for (i=0; i< numstrings; i++)
		{
			if (!strcmp(name, [gameList nameAtIndex:i]))
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

	if (![gameList scenarioAtIndex:gameIndex])
	{
		id theClass = nil;
		GameInfo *gi;
		id theScenario = nil;

		gi = [gameList objectAtIndex: gameIndex];

		if ([gi path])	// we have path but no instance, must load class
		{
			NSString *str;
			[progressView setProgress:0];
			// fixme - these strings should be localizable...
			str = [NSString stringWithFormat:@"Loading %@", [gi scenarioName]];
			[[progressView window] setTitle:str];
			[statusText setStringValue:@"loading code"];
			[progressWin makeKeyAndOrderFront:self];
			//NXPing();

			do
			{
				NSBundle *myBundle = [[NSBundle alloc]
					initWithPath:[gi path]];

				theClass = [myBundle classNamed:[gi scenarioName]];

				if (theClass)
				{
					theScenario = [[theClass alloc] init];
				}
				else
				{
					myBundle = nil;
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

	return [gameList scenarioAtIndex:gameIndex];
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
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
	NSRect frm = {0,0,0,0};
	NSRect cnt = {0,0,0,0};

	if (![scenario respondsTo:@selector(newWindowContentSize:)])
		return self;

	frm.size = frameSize;
	[Window getContentRect:&cnt forFrameRect:&frm style:[sender style]];
	if ([scenario newWindowContentSize:&(cnt.size)])
	{
		[Window getFrameRect:&frm forContentRect:&cnt style:[sender style]];
		frameSize = frm.size;
	}
	return frameSize;
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












