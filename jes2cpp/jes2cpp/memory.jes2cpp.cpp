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

/*
** Note: This has not been fully tested.
*/
Real CJes2CppMemory::FUN(memcpy)(Real ADst, Real ASrc, Real ALength) 
{
  FMemory.Copy(REAL2INT(ADst), REAL2INT(ASrc), REAL2INT(ALength));
  return ADst; 
}

/*
**
*/
Real CJes2CppMemory::FUN(memset)(Real ADst, Real AValue, Real ALength)
{
  FMemory.Set(REAL2INT(ADst), AValue, REAL2INT(ALength));
  return ADst;
}

/*
**
*/
Real CJes2CppMemory::FUN(freembuf)(Real ACount) 
{ 
  return M_NOP; 
} 
