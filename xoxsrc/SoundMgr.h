#import <AppKit/AppKit.h>
#include <CoreAudio/CoreAudio.h>

#define MAX_STREAMS 8

@interface SoundMgr: NSObject

- oneStep;
- (int) addSound:(NSString *)name sender:whom;
- (int) addSound:(NSString *)name sender:whom cache:(BOOL)cacheit;
- cacheSound:(int)whichSound;
- (NSString *)soundName:(int)whichSound;
- playSound: (int)whichSound at: (float)mix;
- free;
- (BOOL)turnSoundOn:sender;
- turnSoundOff;
- (BOOL)isSoundEnabled;

@end
