#
# Generated by the NeXT Project Builder.
#
# NOTE: Do NOT change this file -- Project Builder maintains it.
#
# Put all of your customizations in files called Makefile.preamble
# and Makefile.postamble (both optional), and Makefile will include them.
#

NAME = Xox

PROJECTVERSION = 2.6
PROJECT_TYPE = Application
LANGUAGE = English

NEXTSTEP_APPICON = xoxicon.tiff
NEXTSTEP_DOCICONS = xoxext.tiff

ICONSECTIONS =	-sectcreate __ICON app xoxicon.tiff \
		-sectcreate __ICON xoxext xoxext.tiff

LOCAL_RESOURCES = Xox.nib

GLOBAL_RESOURCES = funnyFace.tiff funnyFace2.tiff sam.tiff xoxext.tiff

CLASSES = Actor.m ActorMatrix.m ActorMgr.m BackView.m BackWindow.m\
          CacheManager.m collisions.m DisplayManager.m EKProgressView.m\
          GameInfo.m KeyTimer.m SoundMgr.m Think2.m Thinker.m\
          UserPath.m

HFILES = Actor.h ActorMatrix.h ActorMgr.h Asteroid.h BackView.h\
         BackWindow.h CacheManager.h collisions.h DisplayManager.h\
         EKProgressView.h GameInfo.h KeyTimer.h Scenario.h Ship.h\
         SoundMgr.h Thinker.h UserPath.h xoxDefs.h Xoxeroids.h

MFILES = Xox_main.m

PSWFILES = psfuncts.psw

BUNDLES = Xoxeroids.bproj CommonEffects.bproj SpaxeWars.bproj

OTHERSRCS = Makefile Makefile.preamble README.rtf


MAKEFILEDIR = $(NEXT_ROOT)/NextDeveloper/Makefiles/pb_makefiles
CODE_GEN_STYLE = DYNAMIC
MAKEFILE = app.make
NEXTSTEP_INSTALLDIR = $(HOME)/Apps
WINDOWS_INSTALLDIR = $(HOME)/Apps
PDO_UNIX_INSTALLDIR = $(HOME)/Apps
LIBS = -lNeXT_s
DEBUG_LIBS = $(LIBS)
PROF_LIBS = $(LIBS)




include $(MAKEFILEDIR)/platform.make

-include Makefile.preamble

include $(MAKEFILEDIR)/$(MAKEFILE)

-include Makefile.postamble

-include Makefile.dependencies
