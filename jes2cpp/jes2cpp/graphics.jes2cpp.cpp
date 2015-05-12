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

CJes2CppImage::CJes2CppImage()
{
  FBitmap = NULL;
  FWidth = FHeight = 0;
}

CJes2CppImage::~CJes2CppImage()
{
  Clear();
}

void CJes2CppImage::Clear()
{
  if (FBitmap) 
  {
    VeST_BitmapFree(FBitmap);
    FBitmap = NULL;    
  }
  FWidth = FHeight = 0;
}

bool CJes2CppImage::LoadFromFile(const String& AFileName)
{
  Clear();
  FBitmap = VeST_BitmapCreate();  
  if (VeST_BitmapLoadFromFile(FBitmap, (PCHAR)FileNameResolve(AFileName).c_str()))
  {   
    FWidth = VeST_BitmapGetWidth(FBitmap);
    FHeight = VeST_BitmapGetHeight(FBitmap);
    return TRUE;
  } else {
    GeepError("Unable to load: " + FileNameResolve(AFileName));
  }
  return FALSE;
}

CJes2CppGraphics::CJes2CppGraphics() 
{
  VAR(gfx_rate$) = VAR(gfx_clear$) = VAR(gfx_r$) = VAR(gfx_g$) = VAR(gfx_b$) = VAR(gfx_a$) = VAR(gfx_x$) = VAR(gfx_y$) = VAR(gfx_w$) = VAR(gfx_h$) = VAR(gfx_texth$) = 0;
}

void CJes2CppGraphics::SetFillColor()
{
  VeST_SetFillColor(FVeST, REAL2PEN(VAR(gfx_r$)), REAL2PEN(VAR(gfx_g$)), REAL2PEN(VAR(gfx_b$)), REAL2PEN(VAR(gfx_a$))); 
}

void CJes2CppGraphics::SetFrameColor()
{
  VeST_SetFrameColor(FVeST, REAL2PEN(VAR(gfx_r$)), REAL2PEN(VAR(gfx_g$)), REAL2PEN(VAR(gfx_b$)), REAL2PEN(VAR(gfx_a$))); 
}

void CJes2CppGraphics::SetFontColor()
{
  VeST_SetFontColor(FVeST, REAL2PEN(VAR(gfx_r$)), REAL2PEN(VAR(gfx_g$)), REAL2PEN(VAR(gfx_b$)), REAL2PEN(VAR(gfx_a$))); 
}

void CJes2CppGraphics::_DrawString(PCHAR AString)
{
  SetFontColor();
  int LX1 = REAL2INT(VAR(gfx_x$));
  int LY1 = REAL2INT(VAR(gfx_y$));
  int LX2 = LX1 + VeST_GetStringWidth(FVeST, AString);
  int LY2 = LY1 + REAL2INT(VAR(gfx_texth$));
  //VeST_DrawStringUTF8_XY(FVeST, AString, REAL2INT(fgfx_x), REAL2INT(fgfx_y + FFontSize), TRUE);
  VeST_DrawString(FVeST, AString, LX1, LY1, LX2, LY2, FALSE, 0); 
  VAR(gfx_x$) = LX2;
}

void CJes2CppGraphics::DrawRoundRect(int AX1, int AY1, int AX2, int AY2, int AR) 
{
  double LAngle = 0, LStep = M_PI / 20;
  VeST_MoveTo(FVeST, AX1 + AR, AY1); 
  VeST_LineTo(FVeST, AX2 - AR, AY1); 
  for (; LAngle <= M_PI * 0.5; LAngle += LStep) VeST_LineTo(FVeST, (int)((AX2 - AR) + sin(LAngle) * AR), (int)((AY1 + AR) - cos(LAngle) * AR));
  VeST_LineTo(FVeST, AX2, AY2 - AR); 
  for (; LAngle <= M_PI * 1.0; LAngle += LStep) VeST_LineTo(FVeST, (int)((AX2 - AR) + sin(LAngle) * AR), (int)((AY2 - AR) - cos(LAngle) * AR));
  VeST_LineTo(FVeST, AX1 + AR, AY2);
  for (; LAngle <= M_PI * 1.5; LAngle += LStep) VeST_LineTo(FVeST, (int)((AX1 + AR) + sin(LAngle) * AR), (int)((AY2 - AR) - cos(LAngle) * AR));
  VeST_LineTo(FVeST, AX1, AY1 + AR);
  for (; LAngle <= M_PI * 2.0; LAngle += LStep) VeST_LineTo(FVeST, (int)((AX1 + AR) + sin(LAngle) * AR), (int)((AY1 + AR) - cos(LAngle) * AR));
}

void CJes2CppGraphics::DrawGradRect(
  int AX1, int AY1, int AX2, int AY2,
  int AIR, int AIG, int AIB, int AIA,
  int AR1, int AG1, int AB1, int AA1,
  int AR2, int AG2, int AB2, int AA2)
{
  AX2 -= 1;
  for (int LY = AY1; LY < AY2; LY++)
  {
    VeST_SetFrameColor(FVeST, AIR >> 16, AIG >> 16, AIB >> 16, 255);
    VeST_MoveTo(FVeST, AX1, LY);
    VeST_LineTo(FVeST, AX2, LY);
    AIR += AR2;
    AIG += AG2;
    AIB += AB2;
  }
}

Real CJes2CppGraphics::FUN(gfx_setpixel)(Real AR, Real AG, Real AB)
{
  VeST_DrawPoint(FVeST, REAL2INT(VAR(gfx_x$)), REAL2INT(VAR(gfx_y$)), REAL2PEN(AR), REAL2PEN(AG), REAL2PEN(AB), 255);
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_circle)(Real AX, Real AY, Real AR, Real AFill) 
{
  if (IF(AFill))
  {
    SetFillColor();
    VeST_DrawEllipse(FVeST, REAL2INT(AX - AR), REAL2INT(AY - AR), REAL2INT(AX + AR) - 1, REAL2INT(AY + AR) - 1, 1);
  } else {
    SetFrameColor();
    VeST_DrawEllipse(FVeST, REAL2INT(AX - AR), REAL2INT(AY - AR), REAL2INT(AX + AR) - 1, REAL2INT(AY + AR) - 1, 0);
  }
  VAR(gfx_x$) = AX; 
  VAR(gfx_y$) = AY;
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_drawstr)(Real AString)
{
  _DrawString(GetCStr(AString));
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_gradrect)(
    Real AX, Real AY, Real AW, Real AH,
    Real AR, Real AG, Real AB, Real AA,
    Real AR1, Real AG1, Real AB1, Real AA1,
    Real AR2, Real AG2, Real AB2, Real AA2)
{
  DrawGradRect(
    REAL2INT(AX), REAL2INT(AY), REAL2INT(AX + AW), REAL2INT(AY + AH), 
    REAL2FIXED(AR * 255), REAL2FIXED(AG * 255), REAL2FIXED(AB * 255), REAL2FIXED(AA * 255),
    REAL2FIXED(AR1 * 255), REAL2FIXED(AG1 * 255), REAL2FIXED(AB1 * 255), REAL2FIXED(AA1 * 255),
    REAL2FIXED(AR2 * 255), REAL2FIXED(AG2 * 255), REAL2FIXED(AB2 * 255), REAL2FIXED(AA2 * 255));
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_lineto)(Real AX, Real AY, Real AFlags)
{
  SetFrameColor();
  VeST_MoveTo(FVeST, REAL2INT(VAR(gfx_x$)), REAL2INT(VAR(gfx_y$)));
  VeST_LineTo(FVeST, REAL2INT(VAR(gfx_x$) = AX), REAL2INT(VAR(gfx_y$) = AY));
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_lineto)(Real AX, Real AY)
{
  return FUN(gfx_lineto)(AX, AY, 0);
}

Real CJes2CppGraphics::FUN(gfx_line)(Real AX1, Real AY1, Real AX2, Real AY2) 
{
  SetFrameColor();
  VeST_MoveTo(FVeST, REAL2INT(AX1), REAL2INT(AY1));
  VeST_LineTo(FVeST, REAL2INT(VAR(gfx_x$) = AX2), REAL2INT(VAR(gfx_y$) = AY2));
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_measurestr)(Real AString, Real &AW, Real &AH) 
{
  AW = (Real) VeST_GetStringWidth(FVeST, GetCStr(AString));
  AH = VAR(gfx_texth$);
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_rectto)(Real AX, Real AY) 
{
  SetFillColor();
  VeST_DrawRect(FVeST, REAL2INT(VAR(gfx_x$)), REAL2INT(VAR(gfx_y$)), REAL2INT(AX), REAL2INT(AY), 1);
  VAR(gfx_x$) = AX; 
  VAR(gfx_y$) = AY;
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_roundrect)(Real AX, Real AY, Real AW, Real AH, Real AR) 
{
  SetFrameColor();
  DrawRoundRect(REAL2INT(AX), REAL2INT(AY), REAL2INT(AX + AW), REAL2INT(AY + AH), REAL2INT(AR));
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_drawnumber)(Real ANumber, Real ADigitCount)
{
  ShortString LString;
  sprintf(LString, "%.*f", REAL2INT(ADigitCount), ANumber);
  _DrawString(LString);
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_drawchar)(Real AChar)
{
  ShortString LString;
  sprintf(LString, "%c", REAL2INT(AChar));
  _DrawString(LString);
  return M_NOP;
}

CJes2CppImage* CJes2CppGraphics::GetImage(Real AIndex)
{
  int LIndex = REAL2INT(AIndex);
  if (!FImages[LIndex].FBitmap) 
  {
    FImages[LIndex].LoadFromFile(GetFileName(LIndex));  
  }
  return &FImages[LIndex];
}

Real CJes2CppGraphics::FUN(gfx_setimgdim)(Real AIndex, Real AWidth, Real AHeight)
{
  CJes2CppImage* LImage = GetImage(AIndex);  
  LImage->Clear();
  LImage->FWidth = REAL2INT(AWidth);
  LImage->FHeight = REAL2INT(AHeight);
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_getimgdim)(Real AIndex, Real& AWidth, Real& AHeight)
{
  CJes2CppImage* LImage = GetImage(AIndex);  
  AWidth = LImage->FWidth;
  AHeight = LImage->FHeight;
  return M_NOP;
}

Real CJes2CppGraphics::FUN(gfx_loadimg)(Real AIndex, Real AFileName)
{
  return FImages[REAL2INT(AIndex)].LoadFromFile(GetFileName(REAL2INT(AFileName))) ? AIndex : M_ERROR;
}

Real CJes2CppGraphics::FUN(gfx_blit)(Real AIndex, Real AScale, Real ARotation, Real AX1, Real AY1, Real AW1, Real AH1, Real AX2, Real AY2, Real AW2, Real AH2)
{
  return FUN(gfx_blit)(AIndex, AScale, ARotation, AX1, AY1, AW1, AH1, AX2, AY2); 
}

Real CJes2CppGraphics::FUN(gfx_blit)(Real AIndex, Real AScale, Real ARotation, Real AX1, Real AY1, Real AW1, Real AH1, Real AX2, Real AY2)
{
  int LX = REAL2INT(AX1), LY = REAL2INT(AY1), LX1 = REAL2INT(AX2), LY1 = REAL2INT(AY2), LX2 = REAL2INT(AX2 + AW1), LY2 = REAL2INT(AY2 + AH1);   
  CJes2CppImage* LImage = GetImage(AIndex);
  if (!VeST_BitmapDraw(LImage->FBitmap, FVeST, LX1, LY1, LX2, LY2, LX, LY))
  {
    VeST_SetFillColor(FVeST, 255, 0, 0, 255);
    VeST_DrawRect(FVeST,  LX1, LY1, LX2, LY2, 1);
    VeST_SetFontColor(FVeST, 255, 255, 0, 255);
    VeST_DrawString(FVeST, (char*)"ERROR", LX1, LY1, LX2, LY2, FALSE, 1);
  }
  return M_NOP;  
}

Real CJes2CppGraphics::FUN(gfx_blit)(Real AIndex, Real AScale, Real ARotation, Real AX1, Real AY1, Real AW1, Real AH1)
{
  return FUN(gfx_blit)(AIndex, AScale, ARotation, AX1, AY1, AW1, AH1, VAR(gfx_x$), VAR(gfx_y$));
}

Real CJes2CppGraphics::FUN(gfx_blit)(Real AIndex, Real AScale, Real ARotation, Real AX1, Real AY1)
{
  CJes2CppImage* LImage = GetImage(AIndex);
  return FUN(gfx_blit)(AIndex, AScale, ARotation, AX1, AY1,  LImage->FWidth, LImage->FHeight);
}

Real CJes2CppGraphics::FUN(gfx_blit)(Real AIndex, Real AScale, Real ARotation)
{
  return FUN(gfx_blit)(AIndex, AScale, ARotation, 0, 0); 
}

Real CJes2CppGraphics::FUN(gfx_blitext)(Real AIndex, Real AList, Real ARotation)
{
  return FUN(gfx_blit)(AIndex, 1, ARotation, MEM(AList, 0), MEM(AList, 1), MEM(AList, 2), MEM(AList, 3), MEM(AList, 4), MEM(AList, 5));  
}

Real CJes2CppGraphics::FUN(gfx_printf)(Real AFormat, ...)
{
  char LStr[512]; 
  va_list LArgs;
  va_start(LArgs, AFormat);
  VPrintF(LStr, GetCStr(AFormat), LArgs);
  va_end(LArgs);
  _DrawString(LStr);
  return M_NOP;   
};


