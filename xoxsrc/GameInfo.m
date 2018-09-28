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

- setScenario:newScenario
{
	id oldScenario = scenario;
	scenario = newScenario;
	return oldScenario;
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

- (GAME_STATUS) setStatus:(GAME_STATUS)newStatus
{
	GAME_STATUS oldStatus = gameStatus;
	gameStatus = newStatus;
	return oldStatus;
}

- (GAME_STATUS)status
{
	return gameStatus;
}

@synthesize scenarioName;

@synthesize path;

- appendPath: (const char *)p
{
	if (altPaths)
	{
		altPaths = realloc(altPaths,strlen(altPaths)+strlen(p)+2);
		strcat(altPaths,"\t");
		strcat(altPaths,p);
	}
	else altPaths = str_copy(p);
	return self;
}

// if the path is bogus, this will set the path to the next one
// returns self if successful, nil if there is no additional path
- useNextPath
{
	char *p1, *p2;

	if (altPaths)
	{
		p1 = p2 = altPaths;
		while (*p1 && *p1 != '\t') p1++;
		if (*p1 == '\t')
		{
			*p1=0;
			path = realloc(path,strlen(p1)+1);
			strcpy(path,p1);
			while (*p2++ = *p1++);
			altPaths = realloc(altPaths,strlen(altPaths)+1);
		}
		else		// last one
		{
			str_free(path);
			path = altPaths;
			altPaths = NULL;
		}
		return self;
	}
	return nil;
}

- discardAltPaths
{
	str_free(altPaths);
	altPaths = NULL;
	return self;
}

@end

@implementation GameList

- (const char *) nameAt: (int) i
{
	return [[self objectAt: i] scenarioName];
}

- scenarioAt: (int) i
{
	return [[self objectAt: i] scenario];
}

static int docompare(const void *x, const void *y)
{
	return strcasecmp([(id)(*(GameInfo **)x) scenarioName], [(id)(*(GameInfo **)y) scenarioName]);
}

- sort
{
	qsort((GameInfo **)dataPtr, numElements, sizeof(id), docompare);
	return self;
}

@end
