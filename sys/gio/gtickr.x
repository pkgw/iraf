# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<mach.h>

# GTICK -- Determine the best number and placement of ticks for the interval
# [x1:x2].  If log scaling is in use we try to put the ticks at positions which
# are 1.0 times some power of ten, otherwise we divide the interval an integral
# number of times and place the ticks at the interval boundaries.  The basic
# algorithm is simple, but implementation is tricky due to the quirks of
# floating point computations and the desire to have the algorithm work for all
# X, and all ranges of X.  For example, we might want to plot a large range
# near zero, or a small range where both X1 and X2 have a very large exponent.
#
# N.B.: this is a generic source; it may be preprocessed with the IRAF "generic"
# preprocessor to produce either a single or double precision SPP source file.

procedure gtickr (x1, x2, rough_nticks, logflag, x_tick1, step)

real	x1, x2			# range for which ticks are desired
int	rough_nticks		# approximate number of ticks desired
int	logflag			# nonzero if log scaling in use
real	x_tick1			# x coord of first tick (output)
real	step			# tick spacing along X (output)

real	x, tol
int	ndiv
int	log
#int	nticks
int	expon
real	gt_distance()

begin
	log = logflag
	tol = EPSILONR * 10.0

	# If log, decrease ndiv until an x of 1.0 is obtained.  If an x of 1.0
	# cannot be produced, repeat the calculation once more with ndiv fixed.

	repeat {
	    ndiv = max (1, rough_nticks - 1)

	    repeat {
		if (log == YES)
		    x = 1.0
		else
		    x = abs ((x2 - x1) / ndiv)

		# Scale approximate tick spacing to the range [1-10).  Select
		# a logical tick spacing, given calculated and scaled spacing.

		call fp_normr (x, x, expon)
		if (x < 1.5)
		    x = 1.0
		else if (x < 2.5)
		    x = 2.0
		else if (x < 4.0)
		    x = 2.5
		else if (x < 7.5)
		    x = 5.0
		else {
		    x = 1.0
		    expon = expon + 1
		}

		# Calculate the first tick and the tick increment (step size).
		if (log == YES)
		    step = 1.0
		else
		    step = x * (10.0 ** expon)

		if (gt_distance (x1, step, x_tick1) / step < tol)
		    # x_tick1 = x1
		else if (x1 < x2 && x_tick1 < x1)
		    x_tick1 = x_tick1 + step
		else if (x1 > x2 && x_tick1 > x1)
		    x_tick1 = x_tick1 - step

		if (x1 > x2)
		    step = -step
		ndiv = ndiv - 1

	    } until (abs(abs(x) - 1.0) < tol || log == NO || ndiv == 0)

	    # Terminate if not in log mode, if the tick separation is a power
	    # of ten and there are ndivisions tick marks, or if the tick
	    # separation is one magnitude and there are at least two tick marks
	    # within the range x1:x2.

		#    if (log == NO) {
		#	return
		#    } else if (step == 1.0 || x == 1.0) {
		#	if (step == 1.0)
		#	    nticks = 1
		#	else
		#	    nticks = max (2, rough_nticks - 1)

		#	if (x1 > x2 && x_tick1 + nticks * step >= x2)
		#	    return
		#	else if (x1 < x2 && x_tick1 + nticks * step <= x2)
		#	    return
		#	else
		#	    log = NO
		#    } else
		#	log = NO

	    return
	}
end


# GT_NDIGITS -- Calculate the number of digits of precision needed to label
# ticks in the range x1 to x2 (i.e., if x1=100000 and x2=100001, 7 digits
# will be required, whereas in many cases 1 or 2 is enough).

int procedure gt_ndigits (x1, x2, step)

real	x1, x2			# range covered by numbers
real	step			# tick separation
real	ratio
int	n

begin
	if (x1 == x2)
	    n = 2
	else {
	    ratio = abs ((x1+x2) / (x1-x2)) 
	    n = log10 (max (1.0, ratio)) + 2.0
	}

	return (n)
end


# GT_LINEARITY -- The following function returns a large number if there is
# little difference between a log scale and a linear scale for the range X1
# to X2.  if the linearity of the interval is large, there is no point in
# using a logarithmic scale.

real procedure gt_linearity (x1, x2)

real	x1, x2
real	linearity, difflog
real	elogr()

begin
	if (x1 <= 0 || x2 <= 0)
	    difflog = abs (elogr(x1) - elogr(x2))
	else
	    difflog = abs (log10(x1) - log10(x2))

	if (difflog == 0.0)
	    linearity = 1E10
	else
	    linearity =  1.0 / difflog

	return (linearity)
end


# GT_DISTANCE -- Compute the distance of X from the nearest integral multiple
# of "step".

real procedure gt_distance (x, step, nearest_tick)

real	x			# number to be tested
real	step			# tick separation
real	nearest_tick		# X coord of tick nearest X

real	ltick, rtick, absx
real	fp_fixr()

begin
	absx = abs (x)

	ltick = fp_fixr (absx / step) * step
	rtick = ltick + step

	if (abs(absx - ltick) < abs(rtick - absx)) {
	    if (x < 0)
		nearest_tick = -ltick
	    else
		nearest_tick = ltick
	    return (absx - ltick)

	} else {
	    if (x < 0)
		nearest_tick = -rtick
	    else
		nearest_tick = rtick
	    return (rtick - absx)
	}
end
