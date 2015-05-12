(*

Jes2Cpp - Jesusonic Script to C++ Transpiler

Created by Geep Software

Author:   Derek John Evans (derek.john.evans@hotmail.com)
Website:  http://www.wascal.net/music/

Copyright (C) 2015 Derek John Evans

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*)

unit Jes2CppEelConstants;

{$MODE DELPHI}

interface


const

  // Basic Math Functions

  SEelFnAbs = 'abs';
  SEelFnACos = 'acos';
  SEelFnASin = 'asin';
  SEelFnATan = 'atan';
  SEelFnATan2 = 'atan2';
  SEelFnCeil = 'ceil';
  SEelFnCos = 'cos';
  SEelFnExp = 'exp';
  SEelFnFloor = 'floor';
  SEelFnInvSqrt = 'invsqrt';
  SEelFnLog = 'log';
  SEelFnLog10 = 'log10';
  SEelFnMax = 'max';
  SEelFnMin = 'min';
  SEelFnPow = 'pow';
  SEelFnRand = 'rand';
  SEelFnSign = 'sign';
  SEelFnSin = 'sin';
  SEelFnSliderChange = 'sliderchange';
  SEelFnSpl = 'spl';
  SEelFnSqr = 'sqr';
  SEelFnSqrt = 'sqrt';
  SEelFnTan = 'tan';

  // Graphics Functions

  SEelFnGfxBlit = 'gfx_blit';
  SEelFnGfxBlitExt = 'gfx_blitext';
  SEelFnGfxBlurTo = 'gfx_blurto';
  SEelFnGfxCircle = 'gfx_circle';
  SEelFnGfxDrawChar = 'gfx_drawchar';
  SEelFnGfxDrawNumber = 'gfx_drawnumber';
  SEelFnGfxDrawStr = 'gfx_drawstr';
  SEelFnGfxGetImgDim = 'gfx_getimgdim';
  SEelFnGfxGetPixel = 'gfx_getpixel';
  SEelFnGfxGradRect = 'gfx_gradrect';
  SEelFnGfxLine = 'gfx_line';
  SEelFnGfxLineTo = 'gfx_lineto';
  SEelFnGfxLoadImg = 'gfx_loadimg';
  SEelFnGfxMeasureStr = 'gfx_measurestr';
  SEelFnGfxPrintF = 'gfx_printf';
  SEelFnGfxRectTo = 'gfx_rectto';
  SEelFnGfxRoundRect = 'gfx_roundrect';
  SEelFnGfxSetFont = 'gfx_setfont';
  SEelFnGfxSetPixel = 'gfx_setpixel';

  // Midi Functions (TODO: midisyx)

  SEelFnMidiSend = 'midisend';
  SEelFnMidiRecv = 'midirecv';
  //AddSystemFunction('midisyx', ['offset', 'index', 'len']);

  // MDCT Functions

  SEelFnMdct = 'mdct';
  SEelFnMdctI = 'imdct';

  // FFT Functions

  SEelFnFft = 'fft';
  SEelFnFftI = 'ifft';
  SEelFnFftPermute = 'fft_permute';
  SEelFnFftPermuteI = 'fft_ipermute';
  SEelFnFftConvolve = 'convolve_c';

  // Memory Functions

  SEelFnMemCpy = 'memcpy';
  SEelFnMemSet = 'memset';
  SEelFnFreeMBuf = 'freembuf';

  // File Functions

  SEelFnFileOpen = 'file_open';
  SEelFnFileClose = 'file_close';
  SEelFnFileRewind = 'file_rewind';
  SEelFnFileVar = 'file_var';
  SEelFnFileMem = 'file_mem';
  SEelFnFileAvail = 'file_avail';
  SEelFnFileRiff = 'file_riff';
  SEelFnFileText = 'file_text';
  SEelFnFileString = 'file_string';

  // Time Functions

  SEelFnTime = 'time';

  // String Functions

  SEelFnStrLen = 'strlen';
  SEelFnStrCpy = 'strcpy';
  SEelFnStrCat = 'strcat';
  SEelFnStrCmp = 'strcmp';
  SEelFnStrICmp = 'stricmp';
  SEelFnStrNCmp = 'strncmp';
  SEelFnStrNICmp = 'strnicmp';
  SEelFnStrNCpy = 'strncpy';
  SEelFnStrNCat = 'strncat';
  SEelFnStrCpyFromSlider = 'strcpy_fromslider';
  SEelFnStrCpySubStr = 'strcpy_substr';
  SEelFnStrGetChar = 'str_getchar';
  SEelFnMatch = 'match';

  SEelFnSPrintF = 'sprintf';

const

  FpA = 'a';
  FpAlias = 'alias';
  FpB = 'b';
  FpChannelCount = 'channelcount';
  FpChar = 'char';
  FpCoordList = 'coordinatelist';
  FpDst = 'dst';
  FpFile = 'file';
  FpFileName = 'filename';
  FpFill = 'fill';
  FpFmt = 'fmt';
  FpFont = 'font';
  FpG = 'g';
  FpH = 'height';
  FpHaystack = 'haystack';
  FpImage = 'image';
  FpIndex = 'index';
  FpLength = 'length';
  FpMsg1 = 'msg1';
  FpMsg2 = 'msg2';
  FpN = 'number';
  FpName = 'name';
  FpNeedle = 'needle';
  FpNumDigits = 'ndigits';
  FpOffset = 'offset';
  FpR = 'r';
  FpRadius = 'radius';
  FpRotation = 'rotation';
  FpSampleRate = 'samplerate';
  FpScale = 'scale';
  FpSize = 'size';
  FpSlider = 'slider';
  FpSrc = 'src';
  FpStr = 'str';
  FpStr1 = 'str1';
  FpStr2 = 'str2';
  FpStyle = 'style';
  FpTimeStamp = 'timestamp';
  FpV = 'v';
  FpVar = 'variable';
  FpW = 'width';
  FpX = 'x';
  FpY = 'y';

implementation

end.

