# Make the first pass (XPP) of the SPP language compiler.

$CC -c $HSI_CF  lexyy.c
$CC -c $HSI_CF	xppmain.c xppcode.c decl.c
$CC $HSI_LF	xppmain.o lexyy.o xppcode.o decl.o $HSI_LIBS -o xpp.e
mv -f		xpp.e ../../../hlib
rm		*.o
