# IRAF definitions for the UNIX/csh user.  The additional variables iraf$ and
# home$ should be defined in the user's .login file.

setenv MACH 	`$iraf/unix/hlib/irafarch.csh`
setenv IRAFARCH 	`$iraf/unix/hlib/irafarch.csh`

setenv	hostid	unix
setenv	host	${iraf}unix/
setenv	hlib	${iraf}unix/hlib/
setenv	hbin	${iraf}unix/bin.$MACH/
setenv	tmp	/tmp/

# Default to GCC for compilation.
setenv	CC	gcc
setenv	F77	$hlib/f77.sh
setenv	F2C	$host/f2c/src/f2c
setenv	RANLIB	ranlib

switch ($MACH)
case freebsd:
    setenv HSI_CF "-O -DBSD -DPOSIX -w -Wunused -m32"
    setenv HSI_XF "-Inolibc -/DBSD -w -/Wunused -/m32"
    setenv HSI_FF "-O -DBLD_KERNEL -m32"
    setenv HSI_LF "-static -m32 -B/usr/lib32 -L/usr/lib32"
    setenv HSI_F77LIBS ""
    setenv HSI_LFLAGS ""
    setenv HSI_OSLIBS "-lcompat"
    set    mkzflags = "'lflags=-z' -/static"
    breaksw

case macosx:
    setenv CC 	cc
    setenv F2C 	$hbin/f2c.e

    setenv HSI_CF "-O -DMACOSX -w -Wunused -arch ppc -arch i386 -m32 -mmacosx-version-min=10.4"
    setenv HSI_XF "-Inolibc -/DMACOSX -w -/Wunused -/m32 -/arch -//ppc -/arch -//i386 -/mmacosx-version-min=10.4"
    setenv HSI_FF "-O -arch ppc -arch i386 -m32 -DBLD_KERNEL -mmacosx-version-min=10.4"
    setenv HSI_LF "-arch ppc -arch i386 -m32 -mmacosx-version-min=10.4"
    setenv HSI_F77LIBS ""
    setenv HSI_LFLAGS ""
    setenv HSI_OSLIBS ""
    set    mkzflags = "'lflags=-z'"
    breaksw

case macintel:
    setenv XC_CFLAGS "-I${iraf}unix/f2c -Wno-return-type"
    setenv XC_FFLAGS "-I${iraf}unix/f2c"
    setenv HSI_CF "-I${iraf}unix/f2c -g -O2 -I${hlib}libc -DMACOSX -DMACINTEL -DMACH64 -w -Wunused -m64 -DHOST_F2C -DHOST_CURL -DHOST_EXPAT -DHOST_CFITSIO -Wno-return-type"
    setenv HSI_XF "-I${iraf}unix/f2c -g -Inolibc -I${hlib}libc -/DMACOSX -/DMACINTEL -w -/Wunused -/DMACH64 -/m64 -/Wno-return-type"
    setenv HSI_FF "-I${iraf}unix/f2c -g -O -m64 -DMACH64 -DBLD_KERNEL"
    setenv HSI_LF "-m64 -DMACH64"
    setenv HSI_F77LIBS ""
    setenv HSI_LFLAGS ""
    setenv HSI_OSLIBS ""
    set    mkzflags = "'lflags=-z'"
    breaksw

case ipad:
    setenv CC 	cc
    setenv F2C 	$hbin/f2c.e

    setenv XC_CFLAGS	"-I/var/include"
    setenv HSI_CF "-O -I/var/include -DMACOSX -DMACINTEL -DIPAD -w -Wunused"
    setenv HSI_XF "-Inolibc -/DMACOSX -/DMACINTEL -/DIPAD -w -/Wunused"
    setenv HSI_FF "-O -DBLD_KERNEL"
    setenv HSI_LF ""
    setenv HSI_F77LIBS ""
    setenv HSI_LFLAGS ""
    setenv HSI_OSLIBS ""
    set    mkzflags = "'lflags=-z'"
    breaksw

# Add ${iraf}unix/f2c to include since f2c on fedora has a different
# set of include definitions
case linux64:
    setenv XC_CFLAGS "-I${iraf}unix/f2c"
    setenv XC_FFLAGS "-I${iraf}unix/f2c"
    setenv HSI_CF "-I${iraf}unix/f2c -g -O2 -I/usr/include -I${hlib}libc -DLINUX -DREDHAT -DPOSIX -DSYSV -DLINUX64 -DMACH64 -w -m64 -DNOLIBCNAMES -DHOST_F2C -DHOST_CURL -DHOST_EXPAT -DHOST_CFITSIO"
    setenv HSI_XF "-I${iraf}unix/f2c -g -Inolibc -I${hlib}libc -w -/m64 -/Wunused"
    setenv HSI_FF "-I${iraf}unix/f2c -g -m64 -DBLD_KERNEL"
    setenv HSI_LF "-m64 "
    setenv HSI_F77LIBS ""
    setenv HSI_LFLAGS ""
    setenv HSI_OSLIBS ""
    set    mkzflags = "'lflags=-Nxz -/Wl,-Bstatic'"
    breaksw

case linux:
case redhat:
    setenv HSI_CF "-g -O2 -I/usr/include -I${hlib}libc -DLINUX -DREDHAT -DPOSIX -DSYSV -w -m32 -Wunused -DHOST_F2C -DHOST_CURL -DHOST_EXPAT -DHOST_CFITSIO"
    setenv HSI_XF "-Inolibc -I${hlib}libc -w -/Wunused -/m32"
    setenv HSI_FF "-O -DBLD_KERNEL -m32"
    setenv HSI_LF "-m32"
    setenv HSI_F77LIBS ""
    setenv HSI_LFLAGS ""
    setenv HSI_OSLIBS ""
    set    mkzflags = "'lflags=-Nxz -/Wl,-Bstatic'"
    breaksw

case sunos:
    setenv HSI_CF "-O -DSOLARIS -DX86 -DPOSIX -DSYSV -w -Wunused"
    setenv HSI_XF "-Inolibc -w -/Wunused"
    setenv HSI_FF "-O"
    #setenv HSI_LF "-t -Wl,-Bstatic"
    #setenv HSI_LFLAGS "-t -Wl,-Bstatic"
    #setenv HSI_OSLIBS \
    #	"-lsocket -lnsl -lintl -Wl,-Bdynamic -ldl -Wl,-Bstatic -lelf"
    setenv HSI_LF "-t"
    setenv HSI_F77LIBS ""
    setenv HSI_LFLAGS "-t"
    setenv HSI_OSLIBS "-lsocket -lnsl -lintl -ldl -lelf"
    set    mkzflags = "'lflags=-Nxz -/Wl,-Bstatic'"
    breaksw

case cygwin:
    setenv HSI_CF "-O -DCYGWIN -DLINUX -DREDHAT -DPOSIX -DSYSV -w -Wunused"
    setenv HSI_XF "-Inolibc -w -/Wunused -/DCYGWIN"
    setenv HSI_FF "-O"
    #setenv HSI_LF "-Wl,-Bstatic"
    setenv HSI_LF ""
    setenv HSI_F77LIBS ""
    setenv HSI_LFLAGS ""
    setenv HSI_OSLIBS "${iraf}unix/bin.cygwin/libcompat.a"
    set    mkzflags = "'lflags=-Nxz -/Wl,-Bstatic'"
    breaksw

default:
    echo 'Warning in hlib$irafuser.csh: unknown platform '"$MACH"
    exit 1
    breaksw
endsw


# Prepend a user <iraf.h> file to the compile flags in case we don't
# install as root.
#
setenv HSI_CF  "-I${HOME}/.iraf/ $HSI_CF"
setenv HSI_FF  "-I${HOME}/.iraf/ $HSI_FF"
setenv HSI_LF  "-I${HOME}/.iraf/ $HSI_LF"
setenv HSI_XF  "-I${HOME}/.iraf/ $HSI_XF"


# The following determines whether or not the VOS is used for filename mapping.
if (-f ${iraf}lib/libsys.a) then
	setenv	HSI_LIBS\
    "${hbin}libboot.a ${iraf}lib/libsys.a ${iraf}lib/libvops.a ${iraf}unix/f2c/libf2c/libf2c.a ${hbin}libos.a -lm"
else
	setenv	HSI_CF "$HSI_CF -DNOVOS"
	setenv	HSI_LIBS "${hbin}libboot.a ${hbin}libos.a"
endif

setenv HSI_LIBS "$HSI_LIBS $HSI_OSLIBS"

alias	mkiraf	${hlib}mkiraf.csh
alias	mkmlist	${hlib}mkmlist.csh
alias	mkz	${hbin}mkpkg.e "$mkzflags"

alias	edsym	${hbin}edsym.e
alias	generic	${hbin}generic.e
alias	mkpkg	${hbin}mkpkg.e
alias	rmbin	${hbin}rmbin.e
alias	rmfiles	${hbin}rmfiles.e
alias	rtar	${hbin}rtar.e
alias	wtar	${hbin}wtar.e
alias	xc	${hbin}xc.e
alias	xyacc	${hbin}xyacc.e
