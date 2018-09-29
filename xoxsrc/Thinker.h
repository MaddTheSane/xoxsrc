
#import <AppKit/AppKit.h>

@class GameInfo;
@class EKProgressView;
@class BackView;
extern NSMutableArray<GameInfo*> *gameList;
extern int gameIndex;

@interface Thinker: NSObject <NSApplicationDelegate, NSWindowDelegate>
{
	BOOL timerValid;
    IBOutlet BackView *backView;
	NSTimer *timer;
	IBOutlet NSBrowser *scenarioBrowser;
	IBOutlet NSBox *invisibleInfoBox;
	IBOutlet NSBox *nullInfoBox;
	BOOL browserValid;
	NSRect inspectorFrame;
	IBOutlet NSWindow *bigWindow;
	IBOutlet NSWindow *littleWindow;
	IBOutlet NSWindow *gameWindow;
	IBOutlet EKProgressView *progressView;

	IBOutlet NSMutableArray<NSString*> *imageNames;
	IBOutlet NSMutableArray *imageRequestor;

	IBOutlet NSTextField *statusText;
	IBOutlet id soundsToCache;
	IBOutlet NSButton *soundButton;
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
- (void)addImageResource:(NSString *)r for:whom;
- (void)addSoundResource:(int)sound;
- (void)loadResources;

@end

@interface Thinker(thinker2) <NSBrowserDelegate>
- setupGameBrowser;
- getSoundSetting;
- (IBAction)setSound:sender;
- (IBAction)selectGame:sender;
- installGameViewsIntoWindow:w;
- (void)loadGamesFrom: (NSString *) dirname;
- getScenario;
- (void)createBigWindowIfNecessary;
- (void)adjustLittleWindowSize;
- (BOOL)bigWindowOK;
@end


@interface NSObject (thinkerAdditions)
- (BOOL) shouldObscureCursor;
@end
