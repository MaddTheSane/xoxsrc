#import <AppKit/AppKit.h>
#include <CoreAudio/CoreAudio.h>

#define MAX_STREAMS 8

@interface SoundMgr: NSObject

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
