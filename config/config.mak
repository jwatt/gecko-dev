# The contents of this file are subject to the Netscape Public License
# Version 1.0 (the "NPL"); you may not use this file except in
# compliance with the NPL.  You may obtain a copy of the NPL at
# http://www.mozilla.org/NPL/
#
# Software distributed under the NPL is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the NPL
# for the specific language governing rights and limitations under the
# NPL.
#
# The Initial Developer of this code under the NPL is Netscape
# Communications Corporation.  Portions created by Netscape are
# Copyright (C) 1998 Netscape Communications Corporation.  All Rights
# Reserved.

!if !defined(CONFIG_CONFIG_MAK)
CONFIG_CONFIG_MAK=1

#//------------------------------------------------------------------------
#//
#// Define public make variables:
#//
#//    OBJDIR  - Specifies the location of intermediate files (ie. objs...)
#//              Currently, the names are WINxx_O.OBJ or WINxx_D.OBJ for
#//              optimized and debug builds respectively.
#//
#//    DIST    - Specifies the location of the distribution directory where
#//              all targets are delivered.
#//
#//    CFGFILE - Specifies the name of the temporary configuration file 
#//              containing the arguments to the current command.
#//
#//    INCS    - Default include paths.
#//
#//    CFLAGS  - Default compiler options.
#//
#//    LFLAGS  - Default linker options.
#//
#//------------------------------------------------------------------------



#//-----------------------------------------------------------------------
#//
#// Detect WinNT vs. Win9x and set WINOS appropriately.
#//
#// Set WINOS in your environment to avoid the timewasting uname call
#//
#//-----------------------------------------------------------------------
!if !defined(WINOS)
!if [$(MOZ_TOOLS)\bin\uname > osuname.inc]
!endif
WINOS=\
!include "osuname.inc"
WINOS=$(WINOS: =)^

!if [del osuname.inc]
!endif
!endif



#//-----------------------------------------------------------------------
#//
#// DIST DEFINITION
#//
#//-----------------------------------------------------------------------

XPDIST=$(DEPTH)\dist
PUBLIC=$(XPDIST)\include

!ifdef NGLAYOUT_BUILD_PREFIX
DIST_PREFIX=NGL
!else
!ifdef MOZ_NAV_BUILD_PREFIX
DIST_PREFIX=NAV
!else
DIST_PREFIX=WIN
!endif
!endif

!ifndef MOZ_DEBUG
OBJDIR=$(DIST_PREFIX)$(MOZ_BITS)$(OBJTYPE)_O.OBJ
JAVA_OPTIMIZER = -O
!ifdef NO_CAFE
JAVAC_OPTIMIZER =
!else
#JAVAC_OPTIMIZER= -O -noinline
JAVAC_OPTIMIZER =
!endif
!else
OBJDIR=$(DIST_PREFIX)$(MOZ_BITS)$(OBJTYPE)_D.OBJ
JAVA_OPTIMIZER = -g
JAVAC_OPTIMIZER = -g
!endif

#//
#// DIST DEFINES SHOULD NEVER BE COMPONENT SPECIFIC.
#//
!ifndef MOZ_DEBUG
DIST=$(XPDIST)\$(DIST_PREFIX)$(MOZ_BITS)_O.OBJ
!else
DIST=$(XPDIST)\$(DIST_PREFIX)$(MOZ_BITS)_D.OBJ
!endif

# This will always give the location of NGLayout's dist, even if "NGLAYOUT_BUILD_PREFIX" is not defined.
!if defined(MOZ_NGLAYOUT)
!ifndef MOZ_DEBUG
NGLAYOUT_DIST=$(XPDIST)\NGL$(MOZ_BITS)_O.OBJ
!else
NGLAYOUT_DIST=$(XPDIST)\NGL$(MOZ_BITS)_D.OBJ
!endif
!endif



#//-----------------------------------------------------------------------
#//
#// Basic configuration settings
#//
#//-----------------------------------------------------------------------

CFGFILE=$(OBJDIR)\cmd.cfg

INCS=$(INCS) -I$(PUBLIC) -I$(DIST)\include -I$(DEPTH)\include

!if "$(MOZ_BITS)" == "16"
CFLAGS=$(MOZ_JAVA_FLAG) -DLAYERS -DEDITOR $(OS_CFLAGS) $(MOZ_CFLAGS)
!else
CFLAGS=$(MOZ_JAVA_FLAG) -DLAYERS $(OS_CFLAGS) $(MOZ_CFLAGS)
!endif

LFLAGS=$(OS_LFLAGS) $(LLFLAGS) $(MOZ_LFLAGS)

# This compiles in heap dumping utilities and other good stuff 
# for developers -- maybe we only want it in for a special SDK 
# nspr/java runtime(?):
!if "$(MOZ_BITS)"=="32" || defined(MOZ_DEBUG)
CFLAGS = $(CFLAGS) -DDEVELOPER_DEBUG
!endif

!ifdef MOZ_BSCFILE
CFLAGS = $(CFLAGS) -FR
!endif



#//-----------------------------------------------------------------------
#//
#// feature-specific configuration settings
#//
#//-----------------------------------------------------------------------

# Crash-reporting system.  http://www.fullcirclesoftware.com
!ifdef MOZ_FULLCIRCLE
CFLAGS=$(CFLAGS) -DMOZ_FULLCIRCLE
!endif

# For modular netlib support.
CFLAGS=$(CFLAGS) -DNS_MT_SUPPORTED -DNETLIB_THREAD -DNS_NET_FILE

# Defines for cookie management feature...
CFLAGS=$(CFLAGS) -DCookieManagement

# Defines for single signon and client wallet features...
!ifndef MOZ_NO_WALLET_HACK
CFLAGS=$(CFLAGS) -DSingleSignon -DClientWallet
!endif

# TODO Cleanup later -Gagan
!ifdef NU_CACHE 
CFLAGS=$(CFLAGS) -DNU_CACHE
!endif

# always need these:
CFLAGS = $(CFLAGS) -DNETSCAPE

# Specify that we are building a client.
# This will instruct the cross platform libraries to
# include all the client specific cruft.
!if defined(SERVER_BUILD)
CFLAGS = $(CFLAGS) -DSERVER_BUILD
!elseif defined(LIVEWIRE)
CFLAGS = $(CFLAGS) -DLIVEWIRE
!else
CFLAGS = $(CFLAGS) -DMOZILLA_CLIENT
!endif

# need this everywhere jsapi.h might be included
CFLAGS=$(CFLAGS) -DJS_THREADSAFE

!if "$(STAND_ALONE_JAVA)" == "1"
CFLAGS=$(CFLAGS) -DSTAND_ALONE_JAVA
!endif

NECKO=1
CFLAGS=$(CFLAGS) -DNECKO

# XXX We need to remove this before we ship.
# This causes a static linkage between the webshell
# and xpfe.f
DETECT_WEBSHELL_LEAKS=1
CFLAGS=$(CFLAGS) -DDETECT_WEBSHELL_LEAKS

!ifndef MOZ_JAVA
MOZ_OJI = 1             # on by default now
!endif

!ifdef MOZ_LIBTEST
MOZ_LIBTEST = 1
CFLAGS=$(CFLAGS) -DLAYPROBE_API
!endif

!ifdef MOZ_JAVA
MOZ_JAVA_FLAG=-DJAVA
!ifdef MOZ_OJI
!error You can't define both MOZ_JAVA and MOZ_OJI anymore. 
!endif
JAVA_OR_OJI = 1
JAVA_OR_NSJVM = 1
!endif

!ifdef NSJVM
JAVA_OR_NSJVM = 1
AWT_11 = 1              # always build awt 1.1 with nsjvm now
!endif

!ifdef MOZ_OJI
CFLAGS=$(CFLAGS) -DOJI
JAVA_OR_OJI=1
!endif

!ifdef SMART_MAIL
CFLAGS=$(CFLAGS) -DSMART_MAIL
!endif

!ifdef MOZ_TRACE_XPCOM_REFCNT
CFLAGS=$(CFLAGS) -DMOZ_TRACE_XPCOM_REFCNT
!endif

!ifdef MOZ_SMOOTH_PROGRESS
CFLAGS=$(CFLAGS) -DSMOOTH_PROGRESS
!endif

!if defined(USE_STRING2)
CFLAGS = $(CFLAGS) -DUSE_STRING2
!endif



#//-----------------------------------------------------------------------
#//
#// build tools
#//
#//-----------------------------------------------------------------------

NMAKE=nmake -nologo -$(MAKEFLAGS)

# use whatever perl is in the path. we don't need to hardcode it
# unless, of course it exists in the hardcoded places
!if exist($(MOZ_TOOLS)\perl5\bin\perl.exe)
PERL = $(MOZ_TOOLS)\perl5\bin\perl.exe
!elseif exist($(MOZ_TOOLS)\perl5\perl.exe)
PERL = $(MOZ_TOOLS)\perl5\perl.exe
!else
PERL = perl.exe
!endif

#if MOZILLA_OFFICIAL is set, then define splitsym
!if defined (MOZILLA_OFFICIAL)
SPLITSYM = $(MOZ_TOOLS)\bin\splitsym
!endif

# use find
FIND = $(MOZ_TOOLS)\bin\find.exe

MASM = $(MOZ_TOOLS)\bin\ml.exe

!if "$(WINOS)" == "WIN95"
MKDIR = $(DEPTH)\config\w95mkdir
QUIET =
!else
MKDIR = mkdir
QUIET=@
!endif



#//------------------------------------------------------------------------
#//
#// Include the OS dependent configuration information
#//
#//------------------------------------------------------------------------
include <$(DEPTH)/config/WIN$(MOZ_BITS)>

!ifdef MOZ_DEBUG
!ifdef USERNAME
CFLAGS = $(CFLAGS) -DDEBUG_$(USERNAME)
!endif
!if defined(GLOWCODE) && defined(GLOWPROF) && "$(MOZ_BITS)"=="32"
CFLAGS = $(CFLAGS) -Gh
!endif
!endif


#//------------------------------------------------------------------------
#//
#// Define the global make commands.
#//
#//    MAKE_INSTALL  - Copy a target to the distribution directory.
#//
#//    MAKE_OBJDIRS  - Create an object directory (if necessary).
#//
#//     MAKE_MANGLE   - Convert all long filenames into 8.3 names
#//
#//     MAKE_UNMANGLE - Restore all long filenames
#//
#//------------------------------------------------------------------------
!if !defined(MOZ_SRC)
#enable builds on any drive if defined.
MOZ_SRC=y:
!endif
MAKE_INSTALL=$(QUIET)$(DEPTH)\config\makecopy.exe
MAKE_MANGLE=$(DEPTH)\config\mangle.exe
MAKE_UNMANGLE=if exist unmangle.bat call unmangle.bat

!if defined(MOZ_PURIFY)
# add #line directive to header files for purify
MKCPYFLAGS= -i
!endif


#//------------------------------------------------------------------------
#//
#// Common Libraries
#//
#//------------------------------------------------------------------------
LIBNSPR=$(DIST)\lib\nspr3.lib $(DIST)\lib\plds3.lib $(DIST)\lib\plc3.lib

NSPRDIR = nsprpub
CFLAGS = $(CFLAGS) -DNSPR20

LIBJPEG=$(DIST)\lib\jpeg$(MOZ_BITS)$(VERSION_NUMBER).lib



#//------------------------------------------------------------------------
#//
#// Windows-Specific Java Stuff
#//
#// (Is this used anymore? Even if it is should it be in config.mak?)
#//
#//------------------------------------------------------------------------

PATH_SEPARATOR = ;

!ifndef JAVA_HOME
JAVA_HOME=$(JDKHOME)
!endif

# where the bytecode will go
!if "$(AWT_11)" == "1"
JAVA_DESTPATH = $(MOZ_SRC)\mozilla\dist\classes11
!else
JAVA_DESTPATH = $(MOZ_SRC)\mozilla\dist\classes
!endif

# where the source are
DEFAULT_JAVA_SOURCEPATH = $(MOZ_SRC)\mozilla\sun-java\classsrc
!ifndef JAVA_SOURCEPATH
!if "$(AWT_11)" == "1"
JAVA_SOURCEPATH = $(MOZ_SRC)\mozilla\sun-java\classsrc11;$(DEFAULT_JAVA_SOURCEPATH)
!else
JAVA_SOURCEPATH = $(DEFAULT_JAVA_SOURCEPATH)
!endif
!endif

JAVA_PROG=$(MOZ_TOOLS)\bin\java.exe
#JAVA_PROG=$(DIST)\bin\java

JAVAC_ZIP=$(JAVA_HOME)\lib\classes.zip

ZIP_PROG = $(MOZ_TOOLS)\bin\zip
UNZIP_PROG = $(MOZ_TOOLS)\bin\unzip
ZIP_COMPR = 9
ZIP_FLAGS = -$(ZIP_COMPR)r

CFLAGS = $(CFLAGS) -DOS_HAS_DLL

DLL_SUFFIX	= dll
LIB_SUFFIX	= lib

!if "$(STAND_ALONE_JAVA)" == "1"
STAND_ALONE_JAVA_DLL_SUFFIX=s
!else
STAND_ALONE_JAVA_DLL_SUFFIX=
!endif

MOD_JRT=jrt$(MOZ_BITS)$(VERSION_NUMBER)
MOD_MM =mm$(MOZ_BITS)$(VERSION_NUMBER)
MOD_AWT=awt$(MOZ_BITS)$(VERSION_NUMBER)
MOD_AWTS=awt$(MOZ_BITS)$(VERSION_NUMBER)$(STAND_ALONE_JAVA_DLL_SUFFIX)
MOD_JIT=jit$(MOZ_BITS)$(VERSION_NUMBER)
MOD_JSJ=jsj$(MOZ_BITS)$(VERSION_NUMBER)
MOD_NET=net$(MOZ_BITS)$(VERSION_NUMBER)
MOD_JBN=jbn$(MOZ_BITS)$(VERSION_NUMBER)
MOD_NSC=nsc$(MOZ_BITS)$(VERSION_NUMBER)
MOD_JPW=jpw$(MOZ_BITS)$(VERSION_NUMBER)
MOD_JDB=jdb$(MOZ_BITS)$(VERSION_NUMBER)
MOD_ZPW=zpw$(MOZ_BITS)$(VERSION_NUMBER)
MOD_CON=con$(MOZ_BITS)$(VERSION_NUMBER)
MOD_NPJ=npj$(MOZ_BITS)$(VERSION_NUMBER)

JRTDLL=$(MOD_JRT).$(DLL_SUFFIX)
MMDLL =$(MOD_MM).$(DLL_SUFFIX)
AWTDLL=$(MOD_AWT).$(DLL_SUFFIX)
AWTSDLL=$(MOD_AWT)$(STAND_ALONE_JAVA_DLL_SUFFIX).$(DLL_SUFFIX)
JITDLL=$(MOD_JIT).$(DLL_SUFFIX)
JSJDLL=$(MOD_JSJ).$(DLL_SUFFIX)
NETDLL=$(MOD_NET).$(DLL_SUFFIX)
JBNDLL=$(MOD_JBN).$(DLL_SUFFIX)
NSCDLL=$(MOD_NSC).$(DLL_SUFFIX)
JPWDLL=$(MOD_JPW).$(DLL_SUFFIX)
JDBDLL=$(MOD_JDB).$(DLL_SUFFIX)
ZPWDLL=$(MOD_ZPW).$(DLL_SUFFIX)
CONDLL=$(MOD_CON).$(DLL_SUFFIX)
NPJDLL=$(MOD_NPJ).$(DLL_SUFFIX)

AWTLIB=$(DIST)\lib\$(MOD_AWT).$(LIB_SUFFIX)

######################################################################

include <$(DEPTH)/config/common.mk>

JAVA_DEFINES =			   \
	-DJAR_NAME=\"$(JAR_NAME)\" \
	-DJRTDLL=\"$(JRTDLL)\"	   \
	-DMMDLL=\"$(MMDLL)\"	   \
	-DAWTDLL=\"$(AWTDLL)\"	   \
	-DAWTSDLL=\"$(AWTSDLL)\"   \
	-DJSJDLL=\"$(JSJDLL)\"	   \
	-DJITDLL=\"$(JITDLL)\"     \
	-DNETDLL=\"$(NETDLL)\"     \
	-DJBNDLL=\"$(JBNDLL)\"     \
	-DNSCDLL=\"$(NSCDLL)\"     \
	-DJDBDLL=\"$(JDBDLL)\"	   \
	-DJPWDLL=\"$(JPWDLL)\"     \
	-DZPWDLL=\"$(ZPWDLL)\"     \
	-DCONDLL=\"$(CONDLL)\"
!if "$(MOZ_BITS)" == "16"

# Override JAVA_DEFINES to make command line short for win16.
# Put any new defines into javadefs.h in ns/sun-java/include.
# This is to shorten the command line in order not to break Win16.

JAVA_DEFINES = -DJAR_NAME=\"$(JAR_NAME)\" -DMOZ_BITS=\"$(MOZ_BITS)\" -DVERSION_NUMBER=\"$(VERSION_NUMBER)\" -DDLL_SUFFIX=\".$(DLL_SUFFIX)\"   

!endif

!if "$(AWT_11)" == "1"
JAVA_DEFINES = $(JAVA_DEFINES) -DAWT_11
!else
JAVA_DEFINES = $(JAVA_DEFINES) -DAWT_102
!endif


#JAVA_CLASSPATH = $(JAVA_CLASSPATH:/=\)
JMCSRCDIR = $(JMCSRCDIR:/=\)
JAVA_BOOT_CLASSPATH = $(JAVA_BOOT_CLASSPATH:/=\)


########
#   Get the cwd to prepend to all compiled source
#       files.  Will allow debugger to automatically find sources
#       instead of asking for the path info.
#   Win16 will break if enabled, guess we continue to live in pain
#       therein.
########
!if "$(MOZ_BITS)" == "32"
CURDIR=$(MAKEDIR)^\
!endif

XPIDL_PROG=$(DIST)\bin\xpidl.exe
XPTLINK_PROG=$(DIST)\bin\xpt_link.exe

# XXX If you change this name, be _sure_ to update rules.mak;
# specifically, the rules that compute XPIDL_HEADERS and
# XPIDL_TYPELIBS. 'nmake' is too dumb to allow recursive macro
# substitution.

XPIDL_GEN_DIR=.\_xpidlgen

!endif # CONFIG_CONFIG_MAK

