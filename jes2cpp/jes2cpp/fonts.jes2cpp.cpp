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

CJes2CppFont::CJes2CppFont() 
{ 
  FSize = M_ZERO;
  FStyle = 0;
}

CJes2CppFonts::CJes2CppFonts()
{
  VAR(gfx_texth$) = M_ZERO;
}

void CJes2CppFonts::SetFont(const String& AName, Real ASize, int AStyle) 
{
  VAR(gfx_texth$) = ASize; 
  // For some reason, VSTGUI doesn't output the same font sizes as REAPER
  ASize *= 0.85; 
  if (!VeST_SetFont(FVeST, (PCHAR)AName.c_str(), REAL2INT(ASize), AStyle))
  {
    VeST_SetFont(FVeST, "verdana", REAL2INT(ASize), AStyle); 
  }
}

Real CJes2CppFonts::FUN(gfx_setfont)(Real AIndex, Real AName, Real ASize, Real AStyle)
{  
  CJes2CppFont* LFont = &FFonts[REAL2INT(AIndex)];
  LFont->FName = GetString(AName);
  LFont->FSize = ASize;
  LFont->FStyle = 0;
  int LStyle = REAL2INT(AStyle);
  if (ContainsByte(LStyle, 'b')) LFont->FStyle |= 1;
  if (ContainsByte(LStyle, 'i')) LFont->FStyle |= 2;
  if (ContainsByte(LStyle, 'u')) LFont->FStyle |= 4;
  return SetFont(LFont->FName, LFont->FSize, LFont->FStyle), M_TRUE;
}

Real CJes2CppFonts::FUN(gfx_setfont)(Real AIndex, Real AName, Real ASize)
{
  return FUN(gfx_setfont)(AIndex, AName, ASize, M_ZERO);
}

Real CJes2CppFonts::FUN(gfx_setfont)(Real AIndex) 
{
  CJes2CppFont* LFont = &FFonts[REAL2INT(AIndex)];
  return SetFont(LFont->FName, LFont->FSize, LFont->FStyle), M_TRUE;
}
