#import <AppKit/AppKit.h>
#import <objc/Object.h>
#import <soundkit/soundkit.h>

#define MAX_STREAMS 8

@interface SoundMgr: NSObject
{
	int currentStream;
	NXSoundOut *device;
	NXPlayStream *streamList[MAX_STREAMS];
	Storage *soundList;
	BOOL glSoundEnabled;
	Storage *currentSounds;		// sounds played this iteration
}

- oneStep;
- (int) addSound:(const char *)name sender:whom;
- (int) addSound:(const char *)name sender:whom cache:(BOOL)cacheit;
- cacheSound:(int)whichSound;
- (char *)soundName:(int)whichSound;
- playSound: (int)whichSound at: (float)mix;
- free;
- (BOOL)turnSoundOn:sender;
- turnSoundOff;
- (BOOL)isSoundEnabled;

@end
