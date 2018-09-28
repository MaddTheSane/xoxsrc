//  BackWindow.m
//
//  You may freely copy, distribute, and reuse the code in this example.
//  NeXT disclaims any warranty of any kind, expressed or  implied, as to its
//  fitness for any particular use.

#import <appkit/appkit.h>
#import "BackWindow.h"


// This class supplies a borderless window as big as the main screen.

@implementation BackWindow

+ getFrameRect:(NXRect *)fRect forContentRect:(const NXRect *)cRect
	 style:(int)aStyle
{
  fRect->origin.x=fRect->origin.y=0;
  [NXApp getScreenSize:&(fRect->size)];
  return self;
}

+ getContentRect:(NXRect *)cRect forFrameRect:(const NXRect *)fRect
	   style:(int)aStyle
{
  cRect->origin.x=cRect->origin.y=0;
  [NXApp getScreenSize:&(cRect->size)];
  return self;
}

+ (NXCoord)minFrameWidth:(const char *)aTitle forStyle:(int)aStyle
	      buttonMask:(int)aMask;
{
  NXSize s;
  [NXApp getScreenSize:&s];
  return s.width;
}


@end
