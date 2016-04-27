#! /bin/bash
#
# Derived from the build.sh developed by "joequant",
# https://github.com/joequant/iraf/blob/linux-build/build.sh

if [ $# -ne 2 ] ; then
    echo >&2 "usage: $0 <iraf-architecture-name> <install-prefix>"
    exit 1
fi

set -x
export IRAFARCH="$1"
prefix="$2"
export iraf=$(pwd)/
export host=${iraf}unix/
export hlib=${host}hlib/
export PATH=$PATH:${host}"bin/"
export pkglibs=${iraf}noao/lib/,${host}hlib/libc/,${host}bin/
export HOST_CURL=1
export HOST_READLINE=1
export HOST_EXPAT=1
export HOST_CFITSIO=1
export F2C=${host}f2c/src/f2c
cat >build_settings.sh <<EOF
export IRAFARCH="$IRAFARCH"
export iraf="$iraf"
export host="$host"
export hlib="$hlib"
export PATH="$PATH"
export pkglibs="$pkglibs"
export HOST_CURL="$HOST_CURL"
export HOST_READLINE="$HOST_READLINE"
export HOST_EXPAT="$HOST_EXPAT"
export HOST_CFITSIO="$HOST_CFITSIO"
export F2C="$F2C"
echo you may wish to alter \\\$NOVOS or \\\$pkglibs
EOF

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

find . -name "*.a" | xargs rm -f

cp unix/boot/spp/xc.c unix/boot/spp/xc.c.orig
ldflag=$(echo $(pkg-config --libs-only-L cfitsio)) # nesting to remove trailing spaces
sed -e "s|@F2C_LIB@|${host}f2c/libf2c/libf2c.a|g" \
   <unix/boot/spp/xc.c.orig >unix/boot/spp/xc.c

cp ${host}hlib/mkiraf.csh ${host}hlib/mkiraf.csh.orig
sed -e "s|/iraf/iraf|$prefix|g" \
   <${host}hlib/mkiraf.csh.orig >${host}hlib/mkiraf.csh

(cd unix/f2c/src && make -f makefile.u)
(cd unix/f2c/libf2c && make -f makefile.u)
cp unix/f2c/libf2c/f2c.h unix/hlib/libc/
cp unix/f2c/libf2c/f2c.h unix/hlib/

${iraf}util/mkarch $IRAFARCH

export NOVOS=1
pushd vendor/voclient
make fresh_libvo
cp libvo/libVO.a ${iraf}lib
popd

${iraf}util/mksysnovos

# We now need to rebuild libVO because of libvotable/votUtil_spp.x, which it
# wasn't possible to compile until we built the "xc" tool.

unset NOVOS
export pkglibs=${iraf}noao/lib/,${host}bin/,${host}hlib/
pushd vendor/voclient
make fresh_libvo
cp libvo/libVO.a ${iraf}lib
popd

export pkglibs=${iraf}noao/lib/,${host}bin/,${host}hlib/libc/
${iraf}util/mksysvos

cp ${host}bin/*.a ${iraf}lib
rm pkg/utilities/nttools/xx_nttools.e

pushd vendor/x11iraf
mkdir -p bin.unknownarch lib.unknownarch
ln -s bin.unknownarch bin
ln -s lib.unknownarch lib
make World PREFIX="$prefix"
popd

export PATH=$PATH:"${host}bin/"
${iraf}util/mksysgen
