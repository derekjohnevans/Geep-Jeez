/*

Jes2Cpp - Jesus Sonic Script to C++ Transpiler

Created by Geep Software

Author:   Derek John Evans (derek.john.evans@hotmail.com)
Website:  http://www.wascal.net/music/

Copyright (C) 2015 Derek John Evans

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/  

#include "jes2cpp.h"

#include "eel_fft.h"

/*
** This is based on eel_convolve_c() from Cockos "eel_fft.h"
** Again, we use a simple memory manager, so a lot of code was taken out. The key
** issue here is, we need to allocate twice as much memory as requested.
*/
void js_convolve_c(CMemory* AMemory, int ADst, int ASrc, int ALength) 
{ 
  ALength *= 2;
  WDL_fft_complexmul((WDL_FFT_COMPLEX*) &(*AMemory)[ADst], (WDL_FFT_COMPLEX*) &(*AMemory)[ASrc], (ALength / 2) & ~1);
} 

/*
** This is based on fft_func() from "eel_fft.h".
** This is a gateway for the functions fft(), ifft(), fft_permute() & fft_ipermute().
*/
void js_fft(CMemory* AMemory, int AIndex, int ALength, int ADir)
{
  int LBitLen = LengthToBitLen(ALength);
  if (LBitLen >= EEL_FFT_MINBITLEN && LBitLen <= EEL_FFT_MAXBITLEN) 
  {
    FFT(LBitLen, &(*AMemory)[AIndex], ADir);
  }
}

/*
**
*/
Real CJes2CppFFT::FUN(fft)(Real AIndex, Real ALength) 
{ 
  js_fft(&FMemory, REAL2INT(AIndex), REAL2INT(ALength), DIR_FFT); 
  return AIndex;
}

/*
**
*/
Real CJes2CppFFT::FUN(ifft)(Real AIndex, Real ASize) 
{ 
  js_fft(&FMemory, REAL2INT(AIndex), REAL2INT(ASize), DIR_IFFT); 
  return AIndex;
}

/*
**
*/
Real CJes2CppFFT::FUN(fft_permute)(Real AIndex, Real ALength) 
{ 
  js_fft(&FMemory, REAL2INT(AIndex), REAL2INT(ALength), DIR_PERMUTE); 
  return AIndex;
} 

/*
**
*/
Real CJes2CppFFT::FUN(fft_ipermute)(Real AIndex, Real ALength) 
{ 
  js_fft(&FMemory, REAL2INT(AIndex), REAL2INT(ALength), DIR_IPERMUTE);
  return AIndex;
} 

/*
**
*/
Real CJes2CppFFT::FUN(convolve_c)(Real ADst, Real ASrc, Real ALength) 
{
  js_convolve_c(&FMemory, REAL2INT(ADst), REAL2INT(ASrc), REAL2INT(ALength));
  return ADst;
}

#include "eel_fft.cpp"
#include "fft.c"
