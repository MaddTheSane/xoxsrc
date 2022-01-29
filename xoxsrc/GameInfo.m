//
//  GameInfo.m
//
//	a simple storage class that holds all the information Xox needs
//  about each game.  This file contains 2 classes; one for the information
//  on a single module and one for a list to store those GameInfo's



#import "GameInfo.h"
#import <stdlib.h>			// for free() etc
#import <strings.h>			// for strcasecmp()
#import <objc/hashtable.h>		// for NXCopyStringBuffer()

#define str_copy(str)	((str == NULL) ? NULL : NXCopyStringBuffer(str))
#define str_free(str)	{if (str) free(str);}


@implementation GameInfo
- init
{	return [self initWithScenario:nil name:NULL path:NULL];
}

- initWithScenario:aScenario name:(NSString *)aName path:(NSString *)aPath
{
	if (self = [super init]) {
	scenario = aScenario;
	scenarioName = [aName copy];
	path = [aPath copy];
	}
	return self;
}

- (void)setScenario:newScenario
{
	scenario = newScenario;
}

- scenario
{	return scenario;
}

- (int) setLevel:(int)newLevel
{
	int oldLevel = level;
	level = newLevel;
	return oldLevel;
}

- (int)level
{
	return level;
}

- (XoXGameStatus) setStatus:(XoXGameStatus)newStatus
{
	XoXGameStatus oldStatus = gameStatus;
	gameStatus = newStatus;
	return oldStatus;
}

- (XoXGameStatus)status
{
	return gameStatus;
}

@synthesize scenarioName;

@synthesize path;

- (void)appendPath: (NSString *)p
{
	if (altPaths)
	{
		[altPaths addObject:p];
	}
	else altPaths = [NSMutableArray arrayWithObject:p];
}

// if the path is bogus, this will set the path to the next one
// returns self if successful, nil if there is no additional path
- (BOOL)useNextPath
{
	if (altPaths && altPaths.count > 0)
	{
		NSString *p1 = altPaths.firstObject;
		[altPaths removeObjectAtIndex:0];
		path = p1;
		if (altPaths.count == 0) // last one
		{
			altPaths = nil;
		}
		return YES;
	}
	return NO;
}

- (void)discardAltPaths
{
	altPaths = NULL;
}

@end

@implementation GameList

- (NSString *) nameAtIndex:(NSInteger)i
{
	return [[self objectAtIndex: i] scenarioName];
}

- (id)scenarioAtIndex:(NSInteger)i
{
	return [[self objectAtIndex: i] scenario];
}

- (void)sort
{
	[self sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
		return [[obj1 scenarioName] caseInsensitiveCompare:[obj2 scenarioName]];
	}];
}

@end
