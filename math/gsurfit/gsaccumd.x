# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include <math/gsurfit.h>
include "dgsurfitdef.h"

# GSACCUM -- Procedure to add a point to the normal equations.
# The inner products of the basis functions are calculated and
# accumulated into the GS_NCOEFF(sf) ** 2 matrix MATRIX.
# The main diagonal of the matrix is stored in the first row of
# MATRIX followed by the remaining non-zero diagonals.
# The inner product
# of the basis functions and the data ordinates are stored in the
# NCOEFF(sf)-vector VECTOR.

procedure dgsaccum (sf, x, y, z, w, wtflag)

pointer	sf		# surface descriptor
double	x		# x value
double	y		# y value
double	z		# z value
double	w		# weight
int	wtflag		# type of weighting

bool	refsub
int	ii, j, k, l
int	maxorder, xorder, xxorder, xindex, yindex, ntimes
pointer	sp, vzptr, mzptr, xbptr, ybptr
double	x1, y1, z1, byw, bw

begin
	# increment the number of points
	GS_NPTS(sf) = GS_NPTS(sf) + 1

	# remove basis functions calculated by any previous gsrefit call
	if (GS_XBASIS(sf) != NULL || GS_YBASIS(sf) != NULL) {

	    if (GS_XBASIS(sf) != NULL)
	        call mfree (GS_XBASIS(sf), TY_DOUBLE)
	    GS_XBASIS(sf) = NULL
	    if (GS_YBASIS(sf) != NULL)
	        call mfree (GS_YBASIS(sf), TY_DOUBLE)
	    GS_YBASIS(sf) = NULL
	    if (GS_WZ(sf) != NULL)
	        call mfree (GS_WZ(sf), TY_DOUBLE)
	    GS_WZ(sf) = NULL

	}

	# calculate weight
	switch (wtflag) {
	case WTS_UNIFORM:
	    w = 1.0d0
	case WTS_USER:
	    # user supplied weights
	default:
	    w = 1.0d0
	}

	# allocate space for the basis functions
	call smark (sp)
	call salloc (GS_XBASIS(sf), GS_XORDER(sf), TY_DOUBLE)
	call salloc (GS_YBASIS(sf), GS_YORDER(sf), TY_DOUBLE)

	# subtract reference value
	refsub = !(IS_INDEFD(GS_XREF(sf)) || IS_INDEFD(GS_YREF(sf)) ||
	    IS_INDEFD(GS_ZREF(sf)))
	if (refsub) {
	    x1 = x - GS_XREF(sf)
	    y1 = y - GS_YREF(sf)
	    z1 = z - GS_ZREF(sf)
	} else {
	    x1 = x
	    y1 = y
	    z1 = z
	}

	# calculate the non-zero basis functions
	switch (GS_TYPE(sf)) {
	case GS_LEGENDRE:
	    call dgs_b1leg (x1, GS_XORDER(sf), GS_XMAXMIN(sf),
		GS_XRANGE(sf), XBASIS(GS_XBASIS(sf)))
	    call dgs_b1leg (y1, GS_YORDER(sf), GS_YMAXMIN(sf),
		GS_YRANGE(sf), YBASIS(GS_YBASIS(sf)))
	case GS_CHEBYSHEV:
	    call dgs_b1cheb (x1, GS_XORDER(sf), GS_XMAXMIN(sf),
		GS_XRANGE(sf), XBASIS(GS_XBASIS(sf)))
	    call dgs_b1cheb (y1, GS_YORDER(sf), GS_YMAXMIN(sf),
		GS_YRANGE(sf), YBASIS(GS_YBASIS(sf)))
	case GS_POLYNOMIAL:
	    call dgs_b1pol (x1, GS_XORDER(sf), GS_XMAXMIN(sf),
		GS_XRANGE(sf), XBASIS(GS_XBASIS(sf)))
	    call dgs_b1pol (y1, GS_YORDER(sf), GS_YMAXMIN(sf),
		GS_YRANGE(sf), YBASIS(GS_YBASIS(sf)))
	default:
	    call error (0, "GSACCUM: Unkown surface type.")
	}

	# one index the pointers
	vzptr = GS_VECTOR(sf) - 1
	mzptr = GS_MATRIX(sf) - 1
	xbptr = GS_XBASIS(sf) - 1
	ybptr = GS_YBASIS(sf) - 1


	switch (GS_TYPE(sf)) {

	case GS_LEGENDRE, GS_CHEBYSHEV, GS_POLYNOMIAL:

	    maxorder = max (GS_XORDER(sf) + 1, GS_YORDER(sf) + 1)
	    xorder = GS_XORDER(sf)
	    ntimes = 0

	    do l = 1, GS_YORDER(sf) {
		byw = w * YBASIS(ybptr+l)
	        do k = 1, xorder {
	            bw = byw * XBASIS(xbptr+k)
	            VECTOR(vzptr+k) = VECTOR(vzptr+k) + bw * z
	            ii = 1
		    xindex = k
		    yindex = l
		    xxorder = xorder
		    do j = k + ntimes, GS_NCOEFF(sf) {
		        MATRIX(mzptr+ii) = MATRIX(mzptr+ii) + bw *
			    XBASIS(xbptr+xindex) * YBASIS(ybptr+yindex)	
			if (mod (xindex, xxorder) == 0) {
			    xindex = 1
			    yindex = yindex + 1
			    switch (GS_XTERMS(sf)) {
			    case GS_XNONE:
				xxorder = 1
			    case GS_XHALF:
				if ((yindex + GS_XORDER(sf)) > maxorder)
				    xxorder = xxorder - 1
			    default:
				;
			    }
			} else
			    xindex = xindex + 1
		        ii = ii + 1
		    }
		    mzptr = mzptr + GS_NCOEFF(sf)
	        }

		vzptr = vzptr + xorder
		ntimes = ntimes + xorder
		switch (GS_XTERMS(sf)) {
		case GS_XNONE:
		    xorder = 1
		case GS_XHALF:
		    if ((l + GS_XORDER(sf) + 1) > maxorder)
		        xorder = xorder - 1
		default:
		    ;
		}
	    }

	default:
	    call error (0, "GSACCUM: Unknown surface type.")
	}

	# release the space
	call sfree (sp)
	GS_XBASIS(sf) = NULL
	GS_YBASIS(sf) = NULL
end
