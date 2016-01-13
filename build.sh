#! /bin/bash
#
# Derived from the build.sh developed by "joequant",
# https://github.com/joequant/iraf/blob/linux-build/build.sh

if [ $# -ne 1 ] ; then
    echo >&2 "usage: $0 <iraf-architecture-name>"
    exit 1
fi

set -x
export IRAFARCH="$1"
export iraf=$(pwd)/
export host=${iraf}unix/
export hlib=${host}hlib/
export PATH=$PATH:${host}"/bin/"
export pkglibs=${iraf}noao/lib/,${host}hlib/libc/,${host}bin/
export HOST_CURL=1
export HOST_READLINE=1
export HOST_EXPAT=1
export HOST_CFITSIO=1
export F2C=${host}f2c/src/f2c

rm -rf vo/votools/.old
rm -rf vo/votools/.url*
rm -f  ${host}bin/*
rm -rf ${host}bin.*/*
rm -f  ${host}bin
ln -sf bin.${IRAFARCH} bin

pushd ${host}hlib
ln -sf mach$(getconf LONG_BIT).h mach.h
ln -sf iraf$(getconf LONG_BIT).h iraf.h
popd

find -name "*.a" | xargs rm -f

cp unix/boot/spp/xc.c unix/boot/spp/xc.c.orig
ldflag=$(echo $(pkg-config --libs-only-L cfitsio)) # nesting to remove trailing spaces
sed -e "s|@F2C_LIB@|${host}f2c/libf2c/libf2c.a|g" \
   <unix/boot/spp/xc.c.orig >unix/boot/spp/xc.c

(cd unix/f2c/src && make -f makefile.u)
(cd unix/f2c/libf2c && make -f makefile.u)
cp unix/f2c/libf2c/f2c.h unix/hlib/libc/
cp unix/f2c/libf2c/f2c.h unix/hlib/
export F2C=$(pwd)/unix/f2c/src/f2c

${iraf}util/mkarch $IRAFARCH

export NOVOS=1
pushd vendor/voclient
make fresh_libvo
cp libvo/libVO.a ${iraf}lib
popd

${iraf}util/mksysnovos

unset NOVOS
export pkglibs=${iraf}noao/lib/,${host}bin/,${host}hlib/
pushd vendor/voclient
make fresh_libvo
cp libvo/libVO.a ${iraf}lib
popd

export pkglibs=${iraf}noao/lib/,${host}bin/,${host}hlib/libc/
${iraf}util/mksysvos
sed -i ${host}hlib/mkiraf.csh -e s!/iraf/iraf!%{_libdir}/iraf!g
cp ${host}bin/*.a ${iraf}lib
rm pkg/utilities/nttools/xx_nttools.e

cd %{_builddir}/x11-iraf
rm ximtool/clients/x_ism.o
xmkmf

export PATH=$PATH:"${host}bin/"
${iraf}util/mksysgen
