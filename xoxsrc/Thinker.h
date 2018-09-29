
#import <AppKit/AppKit.h>

@class GameInfo;
extern NSMutableArray<GameInfo*> *gameList;
extern int gameIndex;

@interface Thinker: NSObject <NSApplicationDelegate>
{
	BOOL timerValid;
    id	backView;
	NSTimer *timer;
	id scenarioBrowser;
	id invisibleInfoBox;
	id nullInfoBox;
	BOOL browserValid;
	NSRect inspectorFrame;
	id bigWindow;
	id littleWindow;
	id gameWindow;
	id progressView;

	id imageNames;
	id imageRequestor;

	id statusText;
	id soundsToCache;
	id soundButton;
}

- appDidInit:sender;
- createTimer;
- removeTimer;
- doOneStepLoop;
- justOneStep;
- oneStep;
- toggleFullScreen:sender;
- setFullScreen:(BOOL)flag;
- toggleUserPause:sender;
- setPauseState:(BOOL)flag;
- newGame:sender;
- addImageResource:(const char *)r for:whom;
- addSoundResource:(int)sound;
- loadResources;

@end

@interface Thinker(thinker2)
- setupGameBrowser;
- getSoundSetting;
- setSound:sender;
- selectGame:sender;
- installGameViewsIntoWindow:w;
- (BOOL)browser:sender columnIsValid:(int)column;
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
