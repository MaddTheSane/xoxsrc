
#import <appkit/appkit.h>

extern id gameList;
extern int gameIndex;

@interface Thinker:Object
{
	BOOL timerValid;
    id	backView;
	DPSTimedEntry timer;
	id scenarioBrowser;
	id invisibleInfoBox;
	id nullInfoBox;
	BOOL browserValid;
	NXRect inspectorFrame;
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

@interface List (XoxAdditions)
- performInOrder:(SEL)aSelector;
@end

@interface Object (thinkerAdditions)
- (BOOL) shouldObscureCursor;
@end