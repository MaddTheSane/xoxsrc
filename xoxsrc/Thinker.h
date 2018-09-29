
#import <AppKit/AppKit.h>

@class GameInfo;
extern NSMutableArray<GameInfo*> *gameList;
extern int gameIndex;

@interface Thinker: NSObject <NSApplicationDelegate>
{
	BOOL timerValid;
    IBOutlet id	backView;
	NSTimer *timer;
	IBOutlet id scenarioBrowser;
	IBOutlet id invisibleInfoBox;
	IBOutlet id nullInfoBox;
	BOOL browserValid;
	NSRect inspectorFrame;
	IBOutlet id bigWindow;
	IBOutlet id littleWindow;
	IBOutlet id gameWindow;
	IBOutlet id progressView;

	id imageNames;
	id imageRequestor;

	IBOutlet id statusText;
	id soundsToCache;
	IBOutlet id soundButton;
}

- (void)createTimer;
- (void)removeTimer;
- (void)doOneStepLoop;
- (void)justOneStep;
- (void)oneStep;
- (IBAction)toggleFullScreen:sender;
- (void)setFullScreen:(BOOL)flag;
- (IBAction)toggleUserPause:sender;
- (void)setPauseState:(BOOL)flag;
- (IBAction)newGame:sender;
- (void)addImageResource:(const char *)r for:whom;
- (void)addSoundResource:(int)sound;
- (void)loadResources;

@end

@interface Thinker(thinker2) <NSBrowserDelegate>
- setupGameBrowser;
- getSoundSetting;
- (IBAction)setSound:sender;
- (IBAction)selectGame:sender;
- installGameViewsIntoWindow:w;
- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- loadGamesFrom: (const char *) dirname;
- getScenario;
- createBigWindowIfNecessary;
- adjustLittleWindowSize;
- (BOOL)bigWindowOK;
@end


@interface NSObject (thinkerAdditions)
- (BOOL) shouldObscureCursor;
@end
