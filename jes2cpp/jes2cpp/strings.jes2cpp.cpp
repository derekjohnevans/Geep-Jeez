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

#include <stdarg.h>

void CJes2CppStrings::ClearStrings()
{
  FStringMap.Clear();
  FStringConstantKey = STRING_CONSTANT;
  FStringVerdana = STR("verdana"); 
  VAR(str_count$) = (Real)FStringMap.Count();
}

void CJes2CppStrings::VPrintF(PCHAR AString, PCHAR AFormat, va_list AArgs)
{ 
  while (*AFormat)
  {
    if (*AFormat == '%') 
    { 
      CHAR LChar, LBuffer[256];  
      PCHAR LFormat = LBuffer;
      do LChar = *LFormat++ = *AFormat++; while (LChar && !isalpha(LChar));
      *LFormat = 0;
      switch (LChar)
      {
        case 'f': sprintf(AString, LBuffer, va_arg(AArgs, DOUBLE)); AString = strchr(AString, 0); break;
        case 'd': sprintf(AString, LBuffer, REAL2INT(va_arg(AArgs, DOUBLE))); AString = strchr(AString, 0); break;
        case 's': sprintf(AString, LBuffer, GetCStr(va_arg(AArgs, DOUBLE))); AString = strchr(AString, 0); break;
      }
    } else {
      *AString++ = *AFormat++; 
    }
  }
  *AString = 0;
}

Real CJes2CppStrings::FUN(strlen)(Real AStr)
{
  return GetString(AStr).length();
}

Real CJes2CppStrings::FUN(strcpy)(Real ADst, Real ASrc)
{
  return GetString(ADst) = GetString(ASrc), ADst;
}

Real CJes2CppStrings::FUN(strcpy_from)(Real ADst, Real ASrc, Real AIndex)
{
  return GetString(ADst) = GetString(ASrc).substr(REAL2INT(AIndex)), ADst;
}

Real CJes2CppStrings::FUN(strcpy_substr)(Real ADst, Real ASrc, Real AIndex, Real ALength)
{
  return GetString(ADst) = GetString(ASrc).substr(REAL2INT(AIndex), REAL2INT(ALength)), ADst; 
}

Real CJes2CppStrings::FUN(strcpy_substr)(Real ADst, Real ASrc, Real AIndex)
{
  return GetString(ADst) = GetString(ASrc).substr(REAL2INT(AIndex)), ADst; 
}

Real CJes2CppStrings::FUN(strcat)(Real AStr1, Real AStr2)
{
  return GetString(AStr1) = GetString(AStr1) + GetString(AStr2), AStr1;
}

Real CJes2CppStrings::FUN(strncpy)(Real ADst, Real ASrc, Real ALength)
{
  return GetString(ADst) = GetString(ASrc).substr(0, REAL2INT(ALength)), ADst;
}

Real CJes2CppStrings::FUN(strcmp)(Real AStr1, Real AStr2)
{
  return strcmp(GetCStr(AStr1), GetCStr(AStr2)); 
}

Real CJes2CppStrings::FUN(stricmp)(Real AStr1, Real AStr2)
{
  return stricmp(GetCStr(AStr1), GetCStr(AStr2)); 
}

Real CJes2CppStrings::FUN(strncmp)(Real AStr1, Real AStr2, Real ALength)
{
  return strncmp(GetCStr(AStr1), GetCStr(AStr2), REAL2INT(ALength)); 
}

Real CJes2CppStrings::FUN(strnicmp)(Real AStr1, Real AStr2, Real ALength)
{
  return strnicmp(GetCStr(AStr1), GetCStr(AStr2), REAL2INT(ALength)); 
}

Real CJes2CppStrings::FUN(str_getchar)(Real AStr, Real AIndex)
{
  int LIndex = REAL2INT(AIndex);  
  String& LString = GetString(AStr); 
  return LString[LIndex < 0 ? LString.length() + LIndex : LIndex];
}

Real CJes2CppStrings::FUN(str_setchar)(Real AStr, Real AIndex, Real AValue)
{
  int LIndex = REAL2INT(AIndex);  
  String& LString = GetString(AStr);
  if (LIndex >= (int)LString.length())
  {
    LString += REAL2INT(AValue);
  } else {
    LString[LIndex < 0 ? LString.length() + LIndex : LIndex] = REAL2INT(AValue);
  }
  return AStr;  
}

Real CJes2CppStrings::FUN(sprintf)(Real AStr, Real AFormat, ...)
{
  char LStr[512]; 
  va_list LArgs;
  va_start(LArgs, AFormat);
  VPrintF(LStr, GetCStr(AFormat), LArgs);
  va_end(LArgs);
  GetString(AStr) = LStr;
  return AStr; 
}

// Not implemented yet
Real CJes2CppStrings::FUN(strcpy_fromslider)(Real& AStr, Real& ASlider)
{
  return M_NOP;
}

// Not implemented yet
Real CJes2CppStrings::FUN(match)(Real ANeedle, Real AHaystack, ...)
{
  return M_NOP;
}






