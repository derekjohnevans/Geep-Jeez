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

#include "jes2cpp/memory.jes2cpp.cpp"
#include "jes2cpp/midi.jes2cpp.cpp"
#include "jes2cpp/parameter.jes2cpp.cpp"
#include "jes2cpp/description.jes2cpp.cpp"
#include "jes2cpp/stream.jes2cpp.cpp"
#include "jes2cpp/files.jes2cpp.cpp"
#include "jes2cpp/mdct.jes2cpp.cpp"
#include "jes2cpp/fft.jes2cpp.cpp"
#include "jes2cpp/time.jes2cpp.cpp"
#include "jes2cpp/sliders.jes2cpp.cpp"
#include "jes2cpp/strings.jes2cpp.cpp"
#include "jes2cpp/fonts.jes2cpp.cpp"
#include "jes2cpp/graphics.jes2cpp.cpp"

String FileNameResolve(const String& AFileName)
{
  return GetCurrentModulePath() + ExcludeLeadingPathDelimiter(AFileName);
}

TJes2Cpp::TJes2Cpp()
{  
  VAR(num_ch$) = M_ZERO;
  VAR(pdc_delay$) = M_ZERO;
  VAR(samplesblock$) = M_ZERO;
  VAR(srate$) = M_ZERO;
  VAR(tempo$) = M_ZERO;
  VAR(ts_num$) = M_ZERO;
  VAR(ts_denom$) = M_ZERO;
  VAR(trigger$) = M_ZERO;
  VAR(beat_position$) = M_ZERO;
  VAR(play_state$) = M_ZERO;
  FClockUpdate = FClockInvalidate = clock();

  EEL_fft_register();

#ifndef _JES2CPP_NO_BASS_
  BASS_Init(-1, 44100, 0, 0, NULL);
#endif
}

TJes2Cpp::~TJes2Cpp()
{
#ifndef _JES2CPP_NO_BASS_
  BASS_Free();
#endif
}

void TJes2Cpp::DoOpen()
{
  ClearStrings();
}

void TJes2Cpp::DoResume()
{
  Real LSampleRate = VeST_GetSampleRate(FVeST);
  if (LSampleRate != VAR(srate$)) 
  {
    VAR(srate$) = LSampleRate;
    DoOpen();
  }
  VAR(num_ch$) = VeST_GetNumInputs(FVeST);
  VAR(tempo$) = (Real)VeST_GetTempo(FVeST);
  VAR(samplesblock$) = (Real)VeST_GetBlockSize(FVeST);  
  DoInit();
  DoSlider();
}

void TJes2Cpp::DoClose() { }
void TJes2Cpp::DoSuspend() { }
void TJes2Cpp::DoInit() { }
void TJes2Cpp::DoSlider() { }
void TJes2Cpp::DoSample() { }

void TJes2Cpp::DoBlock() 
{
  VAR(beat_position$) =  VeST_GetPpqPos(FVeST);
  // Note: We dont seem to get DoIdle events when not in graphics mode,
  // which is odd, so I handle non-gfx GUI updating here. I dont like it
  // but, until I find a better solution....
  if ((clock() - FClockUpdate) > (CLOCKS_PER_SEC / 2))
  {
    DOUBLE tempo, ts_num, ts_denom;
    // We must copy to locals to support 32bit float VST's.
    VeST_GetTimeInfo3(FVeST, &tempo, &ts_num,  &ts_denom);
    VAR(tempo$) = tempo;
    VAR(ts_num$) = ts_num;
    VAR(ts_denom$) = ts_denom;
    // Currently doesn't support pause since it seems to be host dependent.
    VAR(play_state$) = (VeST_GetTransportPlaying(FVeST)?1:0)|(VeST_GetTransportRecording(FVeST)?4:0); 
    VeST_SetInitialDelay(FVeST, (int)VAR(pdc_delay$));
    if (FUpdateDisplay)
    {
      FUpdateDisplay = FALSE;
      VeST_UpdateDisplay(FVeST);
    }
    FClockUpdate = clock();
  } 
}

void TJes2Cpp::DoSample(FLOAT** AInputs, FLOAT** AOutputs, int ASampleFrames)
{
  DoBlock();
  int LInputs = VeST_GetNumInputs(FVeST);
  for (int LSampleFrame = 0; LSampleFrame < ASampleFrames; LSampleFrame++)
  {
    for (int LChannel = LInputs; LChannel-- > 0;) VAR(spl$)[LChannel] = AInputs[LChannel][LSampleFrame];
    DoSample();
    for (int LChannel = LInputs; LChannel-- > 0;) AOutputs[LChannel][LSampleFrame] = (FLOAT)VAR(spl$)[LChannel];
  }
}

void TJes2Cpp::DoSample(DOUBLE** AInputs, DOUBLE** AOutputs, int ASampleFrames)
{
  DoBlock();
  int LInputs = VeST_GetNumInputs(FVeST);
  for (int LSampleFrame = 0; LSampleFrame < ASampleFrames; LSampleFrame++)
  {
    for (int LChannel = LInputs; LChannel-- > 0;) VAR(spl$)[LChannel] = AInputs[LChannel][LSampleFrame];
    DoSample();
    for (int LChannel = LInputs; LChannel-- > 0;) AOutputs[LChannel][LSampleFrame] = VAR(spl$)[LChannel];
  }
}

void TJes2Cpp::DoGfx() 
{
  int LWidth, LHeight;
  if (VeST_GetGraphicsSize(FVeST, &LWidth, &LHeight))
  {
    VAR(gfx_w$) = (Real)LWidth;
    VAR(gfx_h$) = (Real)LHeight;
  }
  VAR(gfx_x$) = VAR(gfx_y$) = 0;
  VAR(gfx_r$) = VAR(gfx_g$) = VAR(gfx_b$) = VAR(gfx_a$) = 1;
  VAR(gfx_rate$) = GFX_RATE;
  FUN(gfx_setfont)(0, FStringVerdana, 18);
}

void TJes2Cpp::DoIdle()
{
  if (VAR(gfx_rate$) > 0)
  {
    if ((clock() - FClockInvalidate) > (CLOCKS_PER_SEC / VAR(gfx_rate$)))
    {
      VeST_InvalidateGraphics(FVeST);
      FClockInvalidate = clock();
    }
  }
}

void TJes2Cpp::DoSerialize()
{
}

void TJes2Cpp::SaveToChunk()
{
/*
  FFiles[0].Close();
  FFiles[0].FMode = FILE_WRITE;
  DoSerialize();
  FFiles[0].FStream.SaveToChunk(FVeST);
  FFiles[0].Close();
*/
}

void TJes2Cpp::LoadFromChunk()
{
/*
  FFiles[0].Close();
  FFiles[0].FMode = FILE_READ;
  FFiles[0].FStream.LoadFromChunk(FVeST);
  DoSerialize();
  FFiles[0].Close();
*/
}





