#///////////////////////////////////////////////////////////////////////////////
#//
#//  Makefile for the VO Uber-library
#//
#///////////////////////////////////////////////////////////////////////////////

# primary dependencies

NAME       	 = VO
VERSION    	 = 1.0
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
CINCS           = -I$(INCDIR)  -I.

CLIBS		= -lm -lc -lcurl -lpthread
CARCH		= -m64 -mmacosx-version-min=10.5


# list of source and include files
SRCS 		= 
OBJS 		= 
INCS 		= 
LIBS		=
APPS		=


all:	lib

World:	lib

install: all
	mv lib$(NAME).a $(LIBDIR)

objs:	$(OBJS) $(INCS)

clean:
	/bin/rm -f *.o *.a *.e *.so .BASE



####################################
#  Apps
####################################

zztest: zztest.o $(OBJS)
	$(CC) $(CFLAGS) -o zztest zztest.o $(LFLAGS) $(LIBS)



####################################
#  LIBVO dependency libraries.
####################################

lib:
	rm -f *.o
	for l in VOTable VOClient samp xmlrpc xmlrpc_client xmlrpc_server xmlrpc_server_abyss \
	         xmlrpc_abyss xmlrpc_util xmlrpc_xmlparse xmlrpc_xmltok xrpc ; do \
	  ar x ../lib/lib$${l}.a ; \
	done && \
	chmod 644 *.o && \
	ar rv libVO.a *.o && \
	cp libVO.a ../lib/ && \
	rm -f *.o __*



###############################################################################
# Leave this stuff alone.
###############################################################################

$(STATICLIB): $(SRCS:%.c=Static/%.o)
	/usr/bin/ar r $@ $?
Static/%.o: %.c $(INCS)
	$(CC) $(CINCS) $(CFLAGS) -c $< -o $@
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
