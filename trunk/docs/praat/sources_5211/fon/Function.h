/* Function.h
 *
 * Copyright (C) 1992-2008 Paul Boersma
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * pb 2008/09/22
 */

#ifndef _Function_h_
#define _Function_h_

/* Function inherits from Data */
#ifndef _Data_h_
	#include "Data.h"
#endif

#define Function_members  Data_members \
	double xmin, xmax;
#define Function_methods  Data_methods \
	int domainQuantity; \
	int (*getMinimumUnit) (void *klas, long ilevel); \
	int (*getMaximumUnit) (void *klas, long ilevel); \
	const wchar_t * (*getUnitText) (void *klas, long ilevel, int unit, unsigned long flags); \
	int (*isUnitLogarithmic) (void *klas, long ilevel, int unit); \
	double (*convertStandardToSpecialUnit) (void *klas, double value, long ilevel, int unit); \
	double (*convertSpecialToStandardUnit) (void *klas, double value, long ilevel, int unit); \
	void (*shiftX) (I, double xfrom, double xto); \
	void (*scaleX) (I, double xminfrom, double xmaxfrom, double xminto, double xmaxto);
class_create (Function, Data);

/*
	An object of type Function represents a function f (x, ...) on the domain [xmin, xmax] * ....
	Class invariants:
		xmax >= xmin;
		xmin, xmax are constant;
*/

int Function_init (I, double xmin, double xmax);
/*
	Preconditions:
		xmin <= xmax;
	Postconditions:
		result -> xmin == xmin;
		result -> xmax == xmax;
*/

int ClassFunction_getDomainQuantity (I);   // as input for MelderQuantity_getXXX

/*
 * A function value is often expressed in some unit, such as:
 * Pa, Hz, dB, sones.
 * In the following, 'ilevel' is for multidimensional functions; it could be the row number of a matrix,
 * or pitch height (Hz) vs. pitch strength (dimensionless), and so on.
 * 'unit' is enumerated type that has to be defined in the header files of the descendant class,
 * starting from 0, which should be the default unit; e.g. for pitch: 0 = Hz, 1 = logHz, 2 = semitones, 3 = mel.
 */
int ClassFunction_getMinimumUnit (void *klas, long ilevel);
int ClassFunction_getMaximumUnit (void *klas, long ilevel);

#define Function_UNIT_TEXT_SHORT            0x00000001
#define Function_UNIT_TEXT_GRAPHICAL        0x00000002
#define Function_UNIT_TEXT_MENU             0x00000004
const wchar_t * ClassFunction_getUnitText (void *klas, long ilevel, int unit, unsigned long flags);

int ClassFunction_isUnitLogarithmic (void *klas, long ilevel, int unit);

double ClassFunction_convertStandardToSpecialUnit (void *klas, double value, long ilevel, int unit);
double ClassFunction_convertSpecialToStandardUnit (void *klas, double value, long ilevel, int unit);
double ClassFunction_convertToNonlogarithmic (void *klas, double value, long ilevel, int unit);

/* The domain of a function can be changed by windowing. */
/* Here follow some window functions. */

#define Function_RECTANGULAR  0
#define Function_TRIANGULAR  1
#define Function_PARABOLIC  2
#define Function_HANNING  3
#define Function_HAMMING  4
#define Function_POTTER  5
#define Function_KAISER12  6
#define Function_KAISER20  7
#define Function_GAUSSIAN  8

double Function_window (double tim, int windowType);
/*
	Return value:
		a number between 0 and 1, zero outside the "domain":
		domain [-0.5, 0.5]: rectangular, triangular, parabolic, hanning, hamming;
		domain [-0.77, 0.77]: potter, kaiser12;
		domain [-1, 1]: kaiser20;
		domain [-inf, +inf]: gaussian.
		Rectangular: 1;
		Triangular ("Parzen"): 1 - tim / 0.5
		Parabolic ("Welch"): 1 - (tim / 0.5) ^ 2
		Hanning (raised cosine): 0.5 + 0.5 * cos (2 * pi * tim)
		Hamming (raised cosine): 0.54 + 0.46 * cos (2 * pi * tim)
		Gaussian: exp (- (pi * tim) ^ 2)
		Kaiser12: besselI0 (12 * sqrt (1 - (tim / 0.77) ^ 2)) / besselI0 (12)
		Kaiser20: besselI0 (20.24 * sqrt (1 - tim ^ 2)) / besselI0 (20.24)
	Usage:
		the preferred window for almost every application is Kaiser20;
		its only shortcoming is the usual double computation time.
	Properties:
		Highest sidelobe:
			Rectangular: -10 dB
			Hanning: -30 dB
			Hamming: -40 dB
			Potter, Kaiser12: -90 dB
			Kaiser20: -180 dB
			Gaussian: -inf dB
		Height at 'tim' is +0.5 or -0.5 (limit from below):
			Rectangular: 1
			Triangular, Parabolic, Hanning: 0
			Hamming: 0.08
			Gaussian: 0.085
			Kaiser20: 0.0715
			Potter: ...
		Area:
			Rectangular: 1
			Parabolic: 2/3
			Gaussian: 1 / sqrt (pi)
			Kaiser20: 0.9813318115591122859 / sqrt (pi)
			Hamming: 0.54
			Triangular, Hanning: 1/2
		Bandwidth (-20 dB):
			...
*/

/*
 * Procedures to adapt a range to the extent of the function domain.
 */
void Function_unidirectionalAutowindow (I, double *xmin, double *xmax);
void Function_bidirectionalAutowindow (I, double *x1, double *x2);
int Function_intersectRangeWithDomain (I, double *x1, double *x2);

void Function_shiftXBy (I, double shift);
void Function_shiftXTo (I, double xfrom, double xto);
void Function_scaleXBy (I, double factor);
void Function_scaleXTo (I, double xminto, double xmaxto);

/* End of file Function.h */
#endif
