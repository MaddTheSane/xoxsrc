//  BackWindow.m
//
//  You may freely copy, distribute, and reuse the code in this example.
//  NeXT disclaims any warranty of any kind, expressed or  implied, as to its
//  fitness for any particular use.

#import <AppKit/AppKit.h>
#import "BackWindow.h"


// This class supplies a borderless window as big as the main screen.

@implementation BackWindow

+ getFrameRect:(NSRect *)fRect forContentRect:(const NSRect *)cRect
	 style:(int)aStyle
{
  fRect->origin.x=fRect->origin.y=0;
  [NSApp getScreenSize:&(fRect->size)];
  return self;
}

+ getContentRect:(NSRect *)cRect forFrameRect:(const NSRect *)fRect
	   style:(int)aStyle
{
  cRect->origin.x=cRect->origin.y=0;
  [NSApp getScreenSize:&(cRect->size)];
  return self;
}

+ (NXCoord)minFrameWidth:(const char *)aTitle forStyle:(int)aStyle
	      buttonMask:(int)aMask;
{
  NSSize s;
  [NSApp getScreenSize:&s];
  return s.width;
}


@end
