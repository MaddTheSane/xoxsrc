
#import <AppKit/NSApplication.h>


void main(int argc, char *argv[])
{
    
    [Application new];
    if ([NSApp loadNibSection:"Xox.nib" owner:NSApp withNames:NO])
	    [NSApp run];
	    
    [NSApp free];
    exit(0);
}
