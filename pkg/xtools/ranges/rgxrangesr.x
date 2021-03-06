# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<error.h>
include	<ctype.h>
include	<pkg/rg.h>

define	NRGS	10		# Allocation size

# RG_XRANGES -- Parse a range string corrsponding to a real set of values.
# Return a pointer to the ranges.

pointer procedure rg_xrangesr (rstr, rvals, npts)

char	rstr[ARB]		# Range string
real	rvals[npts]		# Range values (sorted)
int	npts			# Number of range values
pointer	rg			# Range pointer

int	i, fd, strlen(), open(), getline()
pointer	sp, str, ptr
errchk	open, rg_xaddr

begin
	# Check for valid arguments
	if (npts < 1)
	    call error (0, "No data points for range determination")

	call smark (sp)
	call salloc (str, max (strlen (rstr), SZ_LINE), TY_CHAR)
	call calloc (rg, LEN_RG, TY_STRUCT)

	i = 1
	while (rstr[i] != EOS) {

	    # Find beginning and end of a range and copy it to the work string
	    while (IS_WHITE(rstr[i]) || rstr[i]==',' || rstr[i]=='\n')
	        i = i + 1
	    if (rstr[i] == EOS)
		break

	    ptr = str
	    while (!(IS_WHITE(rstr[i]) || rstr[i]==',' || rstr[i]=='\n' ||
		rstr[i]==EOS)) {
		Memc[ptr] = rstr[i]
	        i = i + 1
		ptr = ptr + 1
	    }
	    Memc[ptr] = EOS

	    # Add range(s)
	    iferr {
		if (Memc[str] == '@') {
		    fd = open (Memc[str+1], READ_ONLY, TEXT_FILE)
		    while (getline (fd, Memc[str]) != EOF) {
			iferr (call rg_xaddr (rg, Memc[str], rvals, npts))
			    call erract (EA_WARN)
		    }
		    call close (fd)
		} else
		    call rg_xaddr (rg, Memc[str], rvals, npts)
	    } then
		call erract (EA_WARN)
	}

	call sfree (sp)
	return (rg)
end


# RG_XADD -- Add a range

procedure rg_xaddr (rg, rstr, rvals, npts)

pointer	rg			# Range descriptor
char	rstr[ARB]		# Range string
real	rvals[npts]		# Range values (sorted)
int	npts			# Number of range values

int	i, j, k, nrgs, strlen(), ctor()
real	rval1, rval2, a1, b1, a2, b2
pointer	sp, str, ptr

begin
	call smark (sp)
	call salloc (str, strlen (rstr), TY_CHAR)

	i = 1
	while (rstr[i] != EOS) {

	    # Find beginning and end of a range and copy it to the work string
	    while (IS_WHITE(rstr[i]) || rstr[i]==',' || rstr[i]=='\n')
	        i = i + 1
	    if (rstr[i] == EOS)
		break

	    ptr = str
	    while (!(IS_WHITE(rstr[i]) || rstr[i]==',' || rstr[i]=='\n' ||
		rstr[i]==EOS)) {
		if (rstr[i] == ':')
		    Memc[ptr] = ' '
		else
		    Memc[ptr] = rstr[i]
	        i = i + 1
		ptr = ptr + 1
	    }
	    Memc[ptr] = EOS

	    # Parse range
	    if (Memc[str] == '@')
		call error (1, "Cannot nest @files")
	    else if (Memc[str] == '*') {
		rval1 = rvals[1]
		rval2 = rvals[npts]
	    } else {
		# Get range
		j = 1
		if (ctor (Memc[str], j, rval1) == 0)
		    call error (1, "Range syntax error")
		rval2 = rval1
		if (ctor (Memc[str], j, rval2) == 0)
		    ;
	    }

	    # Check limits and find indices into rval array
	    a1 = min (rval1, rval2)
	    b1 = max (rval1, rval2)
	    a2 = min (rvals[1], rvals[npts])
	    b2 = max (rvals[1], rvals[npts])
	    if ((b1 >= a2) && (a1 <= b2)) {
		a1 = max (a2, min (b2, a1))
		b1 = max (a2, min (b2, b1))
		if (rvals[1] <= rvals[npts]) {
		    for (k = 1; (k <= npts) && (rvals[k] < a1); k = k + 1)
			;
		    for (j = k; (j <= npts) && (rvals[j] <= b1); j = j + 1)
			;
		    j = j - 1
		} else {
		    for (k = 1; (k <= npts) && (rvals[k] > b1); k = k + 1)
			;
		    for (j = k; (j <= npts) && (rvals[j] >= a1); j = j + 1)
			;
		    j = j - 1
		}

		# Add range
		if (k <= j) {
		    nrgs = RG_NRGS(rg)
		    if (mod (nrgs, NRGS) == 0)
			call realloc (rg, LEN_RG+2*(nrgs+NRGS), TY_STRUCT)
		    nrgs = nrgs + 1
		    RG_NRGS(rg) = nrgs
		    RG_X1(rg, nrgs) = k
		    RG_X2(rg, nrgs) = j
		    RG_NPTS(rg) = RG_NPTS(rg) +
			RG_X1(rg, nrgs) - RG_X2(rg, nrgs) + 1
		}
	    }
	}

	call sfree (sp)
end
