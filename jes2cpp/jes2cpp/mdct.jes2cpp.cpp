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

#include "eel_mdct.h"

/* 
** NOTE: Some of the following functions are based on caller functions from Cockos WDL.
**       So, here is their license as per their request.
*/

/*
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

/*
** This is a version of mdct_func() from Cockos "eel_mdct.h"
** We use a simpler memory manager, so code was taken out.
*/
void js_mdct(CMemory* AMemory, int AIndex, int ALength, BOOL AIsInverse) 
{
  int LBitLen = LengthToBitLen(ALength);
  if (LBitLen >= EEL_DCT_MINBITLEN && LBitLen <= EEL_DCT_MAXBITLEN) 
  {
    static mdct_lookup* mdct_ctxs[EEL_DCT_MAXBITLEN + 1];

    if (!mdct_ctxs[LBitLen]) 
    {
      mdct_ctxs[LBitLen] = (mdct_lookup*) megabuf_mdct_init(ALength);
    }
    Real LBuffer[1 << EEL_DCT_MAXBITLEN];
    if (AIsInverse)
    {
      megabuf_mdct_backward(mdct_ctxs[LBitLen], &(*AMemory)[AIndex], LBuffer);
      megabuf_mdct_apply_window(mdct_ctxs[LBitLen], LBuffer, &(*AMemory)[AIndex]);
    } else {
      megabuf_mdct_apply_window(mdct_ctxs[LBitLen], &(*AMemory)[AIndex], LBuffer);
      megabuf_mdct_forward(mdct_ctxs[LBitLen], LBuffer, &(*AMemory)[AIndex]);
    }
  }
}

/*
**
*/
Real CJes2CppMDCT::FUN(mdct)(Real AIndex, Real ALength) 
{
  js_mdct(&FMemory, REAL2INT(AIndex), REAL2INT(ALength), FALSE);
  return AIndex;
}

/*
**
*/
Real CJes2CppMDCT::FUN(imdct)(Real AIndex, Real ALength) 
{ 
  js_mdct(&FMemory, REAL2INT(AIndex), REAL2INT(ALength), TRUE);
  return AIndex;
} 

#include "eel_mdct.cpp"

