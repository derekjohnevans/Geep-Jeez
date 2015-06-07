/*
  WDL - eel.h
  Copyright (C) 2006 and later Cockos Incorporated

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/

#ifndef _EEL_H_
#define _EEL_H_

//#include <malloc.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#define PI 3.1415926535897932384626433832795

#ifndef EEL_F
#define EEL_F float
#define WDL_FFT_REALSIZE 4
#endif

#define EEL_DCT_MINBITLEN 5
#define EEL_DCT_MAXBITLEN 12
#define EEL_FFT_MINBITLEN 4
#define EEL_FFT_MAXBITLEN 15

#endif

