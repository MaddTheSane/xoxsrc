
#import <appkit/Application.h>


void main(int argc, char *argv[])
{
    
    [Application new];
    if ([NXApp loadNibSection:"Xox.nib" owner:NXApp withNames:NO])
	    [NXApp run];
	    
    [NXApp free];
    exit(0);
}
