
#import "Boink.h"
#import "BackView.h"
#import "ActorMgr.h"
#import "BOBall.h"
#import "BOBrick.h"
#import "SpaceSpinGen.h"
#import "CacheManager.h"
#import "xoxDefs.h"
#import "Thinker.h"

static int whichImage;

@implementation Boink

// invoked only by the actor manager
- _createLevel:(int)lev
{
	int i;
	char str[50];

	[actorMgr newActor:(int)[BOBrick class] for:self tag:0];
	[actorMgr newActor:(int)[BOSkull class] for:self tag:0];
	for (i=0; i<7; i++)
		[actorMgr newActor:(int)[BOBall class] for:self tag:GOOD];
	[[mainView window] setTitle:@"Boink"];

	sprintf(str,"BOtile%02d.tiff",(whichImage++)%6);
	[cacheMgr tileUsing:[[BOBall class] findImageNamed:str]];

	return self;
}

- infoView
{
	return infoView;
}

- didActivate:(Actor *)theActor
{
	return self;
}

- didRetire:(Actor *)theActor
{
	return self;
}

- keyDown:(NXEvent *)theEvent
{
	return self;
}

- keyUp:(NXEvent *)theEvent
{
	return self;
}

- scenarioSelected
{	return self; }

- scenarioDeselected
{	return self; }

- init
{
	char path[256];

	[super init];

	if ([[NXBundle bundleForClass:[self class]]
		getPath:path
		forResource:"boink"
		ofType:"nib"])
	{
		[NXApp loadNibFile:path
			owner:self
			withNames:NO
			fromZone:[self zone]];
	}

	[[NXApp delegate] addImageResource:"BOballs" for: [BOBall class]];

	return self;
}

- (COLLISION_PARADIGM)collisionParadigm
{
	return GOOD_V_EVIL;
}



- (BOOL)newWindowContentSize:(NXSize *)s
{
	int w = s->width,h = s->height;
	w = ((w+50) / 100) * 100;
	h = ((h+50) / 100) * 100;
	if (w < 400) w = 400;
	if (h < 300) h = 300;

	s->width = w;
	s->height = h;
	return YES;
}

@end




