# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	"imfort.h"

# IMAKWD -- Add a new keyword of type double.

procedure imakwd (im, keyw, dval, comm, ier)

pointer	im			# imfort image descriptor
%       character*(*) keyw
double	dval
%       character*(*) comm
int	ier

pointer	sp, kp, cp
int	errcode()

begin
	call smark (sp)
	call salloc (kp, SZ_KEYWORD, TY_CHAR)
	call salloc (cp, SZ_VALSTR, TY_CHAR)

	call f77upk (keyw, Memc[kp], SZ_KEYWORD)
	call f77upk (comm, Memc[cp], SZ_VALSTR)

	iferr (call imaddd (im, Memc[kp], dval, Memc[cp])) {
	    ier = errcode()
	    call im_seterrop (ier, Memc[kp])
	} else {
	    ier = OK
	    IM_UPDATE(im) = YES
	}

	call sfree (sp)
end
