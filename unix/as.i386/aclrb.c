/* Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
 */

#define import_spp
#define import_knames
#include <iraf.h>

/* ACLRB -- Clear a block of memory.
 * [Specially optimized for Sun/IRAF].
 */
ACLRB (a, n)
XCHAR	*a;
XINT	*n;
{
	bzero ((char *)a, *n);
}
