
// SoundMgr.m
// Port to the new soundkit by Derek B. Clegg for BoinkOut
// Munged again by sam for XoX


#import <AppKit/AppKit.h>
#import "SoundMgr.h"
#import "xoxDefs.h"

@implementation SoundMgr
{
	int currentStream;
	NXSoundOut *device;
	NXPlayStream *streamList[MAX_STREAMS];
	Storage *soundList;
	BOOL glSoundEnabled;
	Storage *currentSounds;		// sounds played this iteration
}

#define str_copy(str)	((str == NULL) ? NULL : NXCopyStringBuffer(str))
#define str_free(str)	{if (str) free(str);}

typedef struct {
	id sound;
	char *name;
	id bundle;
	} SoundInfo;


- init
{
    int k;

    [super init];

    device = [[NXSoundOut allocFromZone:[self zone]] init];
    if (device == nil)
	return nil;

    for (k = 0; k < MAX_STREAMS; k++) {
	streamList[k] = [[NXPlayStream allocFromZone:[self zone]] initOnDevice:device];
	if (streamList[k] == nil)
	    return nil;
    }

//	soundList = [[List allocFromZone:[self zone]] init];

	soundList = [[Storage allocFromZone:[self zone]]
		initCount:8
		elementSize: sizeof(SoundInfo)
		description: @encode(SoundInfo)];

	currentSounds = [[Storage allocFromZone:[self zone]]
		initCount:8
		elementSize: sizeof(int)
		description: @encode(int)];

    return self;
}	

- (Sound *)_loadSound: (const char *)name bundle:bndl
{
	char path[MAXPATHLEN+1];
	id theSound;

	if ([bndl getPath:path forResource:name ofType:"snd"])
	{
		theSound = [[Sound allocFromZone:[self zone]] initFromSoundfile:path];
		[theSound convertToFormat:SND_FORMAT_LINEAR_16
			samplingRate:SND_RATE_LOW
			channelCount:1];
		return theSound;
	}
	return nil;
}

- oneStep
{
	[currentSounds empty];
	return self;
}

// returns a positive int index for the new sound, or -1 on failure
- (int) addSound:(const char *)name sender:whom
{
	int ret;
	SoundInfo si;

	si.sound = nil;
	si.name = str_copy(name);
	si.bundle = [NXBundle bundleForClass:[whom class]];

	ret = [soundList count] + 1;
	[soundList addElement:&si];
	return ret;
}

- (int) addSound:(const char *)name sender:whom cache:(BOOL)cacheit
{
	int ret = [self addSound:name sender:whom];
	if (cacheit) [self cacheSound:ret];
	return ret;
}

- cacheSound:(int)whichSound
{
	SoundInfo *sip;
	whichSound--;	// make it zero based
	sip = soundList->dataPtr;
	if ((sip[whichSound].sound == 0) && sip[whichSound].name)
	{
		sip[whichSound].sound = [self _loadSound:sip[whichSound].name
									bundle:sip[whichSound].bundle];
		str_free(sip[whichSound].name);
		sip[whichSound].name = 0;
	}

	return self;
}

- (NSString*)soundName:(int)whichSound
{
	SoundInfo *sip;
	whichSound--;	// make it zero based
	sip = soundList->dataPtr;
	return sip[whichSound].name;
}

- (BOOL)_enable
{
    int k;
#if 0
    NXSoundOut *soundOut = [[NXSoundOut alloc] init];
    NXSoundParameterTag *encodings;
    unsigned int numEncodings;
    /* see if sound out streams support sound data */
    [soundOut getStreamDataEncodings:&encodings count:&numEncodings];
    if (numEncodings == 0)
	printf("sound out streams do not support sound data\n");
#endif
    for (k = 0; k < MAX_STREAMS; k++)
	if ([streamList[k] activate] != NX_SoundDeviceErrorNone)
	    return NO;
    return YES;
}

- _disable
{
    int k;
    for (k = 0; k < MAX_STREAMS; k++)
	[streamList[k] deactivate];
    return self;
}

- playSound: (int)whichSound at: (float)mix
{
    NXPlayStream *stream;
    Sound *sound;
	int count, i, *intArray;
	SoundInfo *sip;

    if ((!glSoundEnabled) || whichSound <= 0) return nil;

	// is the sound loaded?
	whichSound--;	// make it zero based
	sip = soundList->dataPtr;
	if ((sip[whichSound].sound == 0))
		[self cacheSound:(whichSound+1)];

	// test if we've already played this sound this iteration
	intArray = currentSounds->dataPtr;
	count = [currentSounds count];
	for (i=0; i<count; i++)
	{
		if (whichSound == intArray[i]) return self;
	}
	[currentSounds addElement:&whichSound];


    stream = streamList[currentStream++];
    if (currentStream == MAX_STREAMS)
		currentStream = 0;
    sound = sip[whichSound].sound;

	if (!sound) return nil;

    [stream abort:self];

    [stream setGainLeft: (1-mix) right: mix];

    [stream playBuffer:[sound data]
		size:[sound dataSize]
		tag:0
		channelCount:[sound channelCount]
		samplingRate:[sound samplingRate]];

    return self;
}

- free
{
    int k, count = [soundList count];
	SoundInfo *sip = soundList->dataPtr;

	for (k=0; k<count; k++)
	{
		[sip[k].sound free];
		str_free(sip[k].name);
	}
	[soundList free];
    for (k = 0; k < MAX_STREAMS; k++)
	[streamList[k] free];
    [device free];
    return [super free];
}

- (BOOL)turnSoundOn:sender
{
    if (![self _enable]) {

	if (sender)
	NXRunAlertPanel(NULL,
			NXLocalString("Can't do sound, dude.",
				      NULL, NULL),
			NXLocalString("Bummer", NULL, NULL),
			NULL, NULL);

	glSoundEnabled = NO;
	return NO;
    }
    glSoundEnabled = YES;
    return YES;
}

- turnSoundOff
{
    [self _disable];
    glSoundEnabled = NO;
    return self;
}

- (BOOL)isSoundEnabled
{
	return glSoundEnabled;
}

@end
