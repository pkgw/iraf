#///////////////////////////////////////////////////////////////////////////////
#//
#//  Makefile for the VOTable Interface
#//
#///////////////////////////////////////////////////////////////////////////////

# primary dependencies

NAME       	 = VOTable
VERSION    	 = 1.1
PLATFORM  	:= $(shell uname -s)
PLMACH  	:= $(shell uname -m)
HERE      	:= $(shell /bin/pwd)
BINDIR    	:= ../bin/
LIBDIR    	:= ../lib/
INCDIR    	:= ../include/

# secondary dependencies

LIBBASE		= lib$(NAME)
STATICLIB 	= $(LIBDIR)/$(LIBBASE).a
SHAREDLIB 	= $(LIBDIR)/$(LIBBASE).so.$(VERSION)


# includes, flags and libraries
CC 	  	= gcc
CINCS  	  	= -I$(INCDIR)  -I.
ifeq  ($(PLATFORM), "Darwin")
    ifeq  ($(PLMACH), "x86_64")
	CARCH	= -m64 -mmacosx-version-min=10.5
    else
	CARCH	= -arch i386 -arch ppc -m32 -mmacosx-version-min=10.4
    endif
else
    CARCH	= 
endif

CFLAGS 		:= $(CFLAGS) -DHAVE_CFITSIO $(shell pkg-config --cflags cfitsio)
CLIBS		= -lm -lc $(shell pkg-config --libs cfitsio)



# list of source and include files
SRCS 		= votParse.c votParse_f77.c votParse_spp.c \
		  votExpatCB.c votElement.c votAttr.c votStack.c votHandle.c
OBJS 		= votParse.o votParse_f77.o votParse_spp.o \
		  votExpatCB.o votElement.o votAttr.o votStack.o votHandle.o
INCS 		= votParse.h

ifneq ($(NOVOS),1)
SPP_SRCS	= votUtil_spp.x
SPP_OBJS	= votUtil_spp.o
SPP_INCS 	= votParse_spp.h
endif

INCS_PRIV	= votParseP.h
LIBS		= lib$(NAME).a


all:	.BASE lib apps install

World:	.BASE lib apps install

install: .BASE lib apps
	cp $(LIBS) $(LIBDIR)
	cp $(INCS) $(SPP_INCS) $(INCDIR)

objs:	$(OBJS) $(SPP_OBJS)

clean:
	/bin/rm -f *.o *.a *.e *.so .BASE
	/bin/rm -f SWIG* libvot* php_libvot.h
	/bin/rm -f votParseJava.[co]
	/bin/rm -f votParsePerl.[co]
	/bin/rm -f votParsePython.[co]
	/bin/rm -f votParseTcl.[co]
	/bin/rm -f votParsePhp.[co]
	/bin/rm -f votParseCSharp.[co]
	/bin/rm -f votParseRuby.[co]



####################################
#  LIBVOTABLE Apps
####################################

apps:



####################################
#  LIBVOTABLE dependency libraries.
####################################

.BASE:
ifndef HOST_EXPAT
	(./mkbase $(HERE)/lib$(NAME).a)
endif
	touch .BASE

lib: objs
	ar rv lib$(NAME).a $(OBJS) $(SPP_OBJS)
	rm -f $(OBJS) $(SPP_OBJS)


###############################################################################
#  SPP Utility procedures
###############################################################################

votUtil_spp.o: votUtil_spp.x votParse_spp.h
	xc -d -c -w votUtil_spp.x


###############################################################################
#  SWIG Wrapper code generation
###############################################################################

wrap_code: tcl_wrap py_wrap perl_wrap java_wrap # php_wrap ruby_wrap mono_wrap


tcl_wrap:  votParse.i
	(swig -tcl    -o votParseTcl.c    votParse.i     )
	make tcl_lib

py_wrap:  votParse.i
	(swig -python -o votParsePython.c votParse.i     )
	make python_lib

perl_wrap:  votParse.i
	(swig -perl   -o votParsePerl.c   votParse.i     )
	make perl_lib

java_wrap:  votParse.i
	(swig -java   -o votParseJava.c   votParse.i     )
	make java_lib

php_wrap:  votParse.i
	(swig -php    -o votParsePhp.c    votParse.i     )
	make php_lib

ruby_wrap:  votParse.i
	(swig -ruby   -o votParseRuby.c   votParse.i     )
	#make ruby_lib

mono_wrap:  votParse.i
	(swig -csharp -o votParseCSharp.c votParse.i     )
	#make mono_lib



##############################################################################
#
#  SWIG Wrapper share library builds -- highly platform dependent!!
#
##############################################################################

wrap_libs: wrap_code tcl_lib python_lib perl_lib java_lib 

tcl_lib:  votParse.i
	$(CC) -fPIC -c $(SRCS) votParseTcl.c
	$(CC) -shared $(OBJS) votParseTcl.o -o lib$(NAME).so
	$(RM) votParse_wrap.*


PY_INCS = -I.   -I/usr/include/python2.2 -I/usr/include/python2.3 \
                -I/usr/include/python2.4 -I/usr/include/python2.5

python_lib:  votParse.i
	$(CC) -w -c $(PY_INCS) $(SRCS) votParsePython.c
	ld -shared $(OBJS) votParsePython.o -o _lib$(NAME).so
	$(RM) votParse_wrap.*

perl_lib:  votParse.i
	gcc -c $(SRCS) votParsePerl.c `perl -MExtUtils::Embed -e ccopts`
	ld -G $(OBJS) -o lib$(NAME).so
	$(RM) votParse_wrap.*


JWRAP_FLAGS 	= -I/usr/java/j2sdk/include/ -I/usr/java/j2sdk/include/linux

java_lib:  votParse.i
	gcc -fpic -c $(WRAP_SRCS) votParseJava.c $(JWRAP_FLAGS)
	gcc -shared $(WRAP_OBJS) votParseJava.o -o lib$(NAME).so
	$(RM) votParse_wrap.*



PHP_INCS = -I. -I/usr/include/php -I/usr/local/include/php \
	   -I/usr/local/php -I/usr/include/php/Zend \
	   -I/usr/local/include/php/Zend

php_lib:   votParse.i
	gcc -fpic -c $(PHP_INCS) $(WRAP_SRCS) votParsePhp.c
	gcc -shared $(WRAP_OBJS) votParsePhp.o -o lib$(NAME).so
	$(RM) votParse_wrap.*





###############################################################################
# Leave this stuff alone.
###############################################################################

$(STATICLIB): $(SRCS:%.c=Static/%.o)
	/usr/bin/ar rv $@ $?
Static/%.o: %.c $(INCS)
	$(CC) $(CINCS) $(CFLAGS) -c $< -o $@
Static/%.o: %.x $(SPP_INCS)
	xc -c $< -o $@
Static:
	/bin/mkdir $@
	chmod 777 $@

$(SHAREDLIB): $(SRCS:%.c=Shared/%.o)
	/usr/bin/ld -shared -o $@ $? -lc -ldl
Shared/%.o: %.c $(INCS)
	$(CC) $(CINCS) $(CFLAGS) -fpic -shared -c $< -o $@
Shared:
	/bin/mkdir $@
	chmod 777 $@
