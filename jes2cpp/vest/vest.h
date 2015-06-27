/*

VeST - A VST Flat Wrapper (ie: VST without the need for the SDK)

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

#ifndef VEST_H
#define VEST_H

// Include C Headers

#define _USE_MATH_DEFINES

#include <math.h>
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <memory.h>
#include <stdint.h>
#include <stdarg.h>

// Golden ratio
#define M_PHI 1.61803399

// Include C++ Headers

#include <string>
#include <vector>
#include <map>
#include <unordered_map>

#ifdef __GNUC__
#include <sys/time.h>
#include <sys/stat.h>
#include <strings.h>
#include <dirent.h>
#endif // __GNUC__

#ifdef _WIN32
#include <io.h>
#include <windows.h>
#define strcasecmp _stricmp
#define strncasecmp _strnicmp
#endif // _WIN32

// The future supported plugin types are...
// VEST_VST (done)
// VEST_LV1 (done)
// VEST_LV2
// VEST_AU
// VEST_DX

// VeST defaults to VST.
#ifndef VEST_VST
#ifndef VEST_LV1
#ifndef VEST_LV3
#define VEST_VST
#endif // VEST_LV2
#endif // VEST_LV1
#endif // VEST_VST

#ifdef VEST_LV1
#include "ladspa/ladspa.h"
#endif // VEST_LV1

#ifdef VEST_LV2
#include "ladspa/lv2/lv2plug.in/ns/lv2core/lv2.h"
#endif // VEST_LV2

#ifdef VEST_DX
// TODO
#endif // VEST_DX

#ifdef VEST_AU
// TODO
#endif // VEST_AU

#ifdef VEST_IS_DLL
#define VEST_EXPORT __declspec(dllexport)
#else
#define VEST_EXPORT extern
#endif // VEST_IS_DLL

#ifdef _WIN32
#define VEST_CALLBACK CALLBACK
#define VEST_WINAPI WINAPI
#define VEST_HANDLE HANDLE
#define VEST_DECLARE_HANDLE(AName) DECLARE_HANDLE(AName)
#else
#define VEST_CALLBACK
#define VEST_WINAPI
#define VEST_HANDLE void*
#define VEST_DECLARE_HANDLE(AName) typedef struct AName##__ { int FUnused; } *AName
#endif // _WIN32

#define VEST_F double

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

VEST_DECLARE_HANDLE(HVEST);
VEST_DECLARE_HANDLE(HVEST_DATA);
VEST_DECLARE_HANDLE(HVEST_BITMAP);
VEST_DECLARE_HANDLE(HVEST_AEFFECT);
VEST_DECLARE_HANDLE(HVEST_AUDIOMASTER);

typedef void (VEST_CALLBACK TVeST_Nofify)(HVEST AVeST);
typedef bool (VEST_CALLBACK TVeST_GetString)(HVEST AVeST, char* AString);
typedef void (VEST_CALLBACK TVeST_SetString)(HVEST AVeST, char* AString);
typedef int (VEST_CALLBACK TVeST_GetInteger)(HVEST AVeST);
typedef bool (VEST_CALLBACK TVeST_GetCategoryIndexedString)(HVEST AVeST, int ACategory, int AIndex, char* AString);
typedef void (VEST_CALLBACK TVeST_SetIndexedValue)(HVEST AVeST, int AIndex, VEST_F AValue);
typedef VEST_F (VEST_CALLBACK TVeST_GetIndexedValue)(HVEST AVeST, int AIndex);
typedef void (VEST_CALLBACK TVeST_GetIndexedString)(HVEST AVeST, int AIndex, char* AString);
typedef void (VEST_CALLBACK TVeST_ProcessReplacing)(HVEST AVeST, float** AInputs, float** AOutputs, int ASampleFrames);
typedef void (VEST_CALLBACK TVeST_ProcessDoubleReplacing)(HVEST AVeST, double** AInputs, double** AOutputs,
    int ASampleFrames);
typedef void (VEST_CALLBACK TVeST_MouseEvent)(HVEST AVeST, VEST_F AX, VEST_F AY, int AButtons);
typedef void (VEST_CALLBACK TVeST_KeyEvent)(HVEST AVeST, int AChar, int AVirtual, int AModifier);
typedef void (VEST_CALLBACK TVeST_Draw)(HVEST AVeST, VEST_F AWidth, VEST_F AHeight);
typedef int (VEST_CALLBACK TVeST_GetChunk)(HVEST AVeST, void** AData, bool AIsPreset);
typedef int (VEST_CALLBACK TVeST_SetChunk)(HVEST AVeST, void* AData, int ASize, bool AIsPreset);

typedef struct {
  TVeST_Nofify* OnCreate;
  TVeST_Nofify* OnDestroy;
  TVeST_Nofify* OnOpen;
  TVeST_Nofify* OnSuspend;
  TVeST_Nofify* OnResume;
  TVeST_Nofify* OnIdle;
  TVeST_Nofify* OnClose;
  TVeST_Draw* OnDraw;
  TVeST_MouseEvent* OnMouseDown;
  TVeST_MouseEvent* OnMouseUp;
  TVeST_MouseEvent* OnMouseMoved;
  TVeST_KeyEvent* OnKeyDown;
  TVeST_KeyEvent* OnKeyUp;
  TVeST_GetInteger* OnGetVendorVersion;
  TVeST_GetString* OnGetVendorString;
  TVeST_GetString* OnGetProductString;
  TVeST_GetString* OnGetEffectName;
  TVeST_GetString* OnGetProgramName;
  TVeST_SetString* OnSetProgramName;
  TVeST_GetCategoryIndexedString* OnGetProgramNameIndexed;
  TVeST_GetIndexedValue* OnGetParameter;
  TVeST_SetIndexedValue* OnSetParameter;
  TVeST_GetIndexedString* OnGetParameterName;
  TVeST_GetIndexedString* OnGetParameterLabel;
  TVeST_GetIndexedString* OnGetParameterDisplay;
  TVeST_ProcessReplacing* OnProcessReplacing;
  TVeST_ProcessDoubleReplacing* OnProcessDoubleReplacing;
  TVeST_GetChunk* OnGetChunk;
  TVeST_SetChunk* OnSetChunk;
} TVeSTCallBacks;

#define VEST_DRAWMODE_COPY 0
#define VEST_DRAWMODE_ANTIALIAS 3

#define VEST_INIT VEST_EXPORT HVEST VEST_WINAPI VeST_Init(HVEST_DATA AData, TVeSTCallBacks* AVeSTCallBacks, HVEST_AUDIOMASTER AAudioMaster, int AProgramCount, int AParamCount)
#define VEST_GETDATA VEST_EXPORT HVEST_DATA VEST_WINAPI VeST_GetData(HVEST AVeST)
#define VEST_GETNUMINPUTS VEST_EXPORT int VEST_WINAPI VeST_GetNumInputs(HVEST AVeST)
#define VEST_GETNUMOUTPUTS VEST_EXPORT int VEST_WINAPI VeST_GetNumOutputs(HVEST AVeST)
#define VEST_SETNUMINPUTS VEST_EXPORT bool VEST_WINAPI VeST_SetNumInputs(HVEST AVeST, int ACount)
#define VEST_SETNUMOUTPUTS VEST_EXPORT bool VEST_WINAPI VeST_SetNumOutputs(HVEST AVeST, int ACount)
#define VEST_SETUNIQUEID VEST_EXPORT bool VEST_WINAPI VeST_SetUniqueID(HVEST AVeST, int AValue)
#define VEST_GETSAMPLERATE VEST_EXPORT float VEST_WINAPI VeST_GetSampleRate(HVEST AVeST)
#define VEST_GETTEMPO VEST_EXPORT VEST_F VEST_WINAPI VeST_GetTempo(HVEST AVeST)
#define VEST_GETTRANSPORTRECORDING VEST_EXPORT bool VEST_WINAPI VeST_GetTransportRecording(HVEST AVeST)
#define VEST_GETTRANSPORTPLAYING VEST_EXPORT bool VEST_WINAPI VeST_GetTransportPlaying(HVEST AVeST)
#define VEST_GETPPQPOS VEST_EXPORT VEST_F VEST_WINAPI VeST_GetPpqPos(HVEST AVeST)
#define VEST_GETBARSTARTPOS VEST_EXPORT VEST_F VEST_WINAPI VeST_GetBarStartPos(HVEST AVeST)
#define VEST_GETTIMEINFO3 VEST_EXPORT bool VEST_WINAPI VeST_GetTimeInfo3(HVEST AVeST, VEST_F* ATempo, VEST_F* ASigNumerator, VEST_F* ASigDenominator)
#define VEST_GETBLOCKSIZE VEST_EXPORT int VEST_WINAPI VeST_GetBlockSize(HVEST AVeST)
#define VEST_GETHOSTLANGUAGE VEST_EXPORT int VEST_WINAPI VeST_GetHostLanguage(HVEST AVeST)
#define VEST_GETHOSTPRODUCTSTRING VEST_EXPORT bool VEST_WINAPI VeST_GetHostProductString(HVEST AVeST, char* AString)
#define VEST_GETHOSTVENDORSTRING VEST_EXPORT bool VEST_WINAPI VeST_GetHostVendorString(HVEST AVeST, char* AString)
#define VEST_GETHOSTVENDORVERSION VEST_EXPORT int VEST_WINAPI VeST_GetHostVendorVersion(HVEST AVeST)
#define VEST_GETMASTERVERSION VEST_EXPORT int VEST_WINAPI VeST_GetMasterVersion(HVEST AVeST)
#define VEST_GETCURRENTUNIQUEID VEST_EXPORT int VEST_WINAPI VeST_GetCurrentUniqueId(HVEST AVeST)
#define VEST_SETGRAPHICSSIZE VEST_EXPORT bool VEST_WINAPI VeST_SetGraphicsSize(HVEST AVeST, int AWidth, int AHeight)
#define VEST_GETGRAPHICSSIZE VEST_EXPORT bool VEST_WINAPI VeST_GetGraphicsSize(HVEST AVeST, int* AWidth, int* AHeight)
#define VEST_SETINITIALDELAY VEST_EXPORT bool VEST_WINAPI VeST_SetInitialDelay(HVEST AVeST, int ADelay)
#define VEST_SETISSYNTH VEST_EXPORT bool VEST_WINAPI VeST_SetIsSynth(HVEST AVeST, bool AState)
#define VEST_UPDATEDISPLAY VEST_EXPORT bool VEST_WINAPI VeST_UpdateDisplay(HVEST AVeST)
#define VEST_INVALIDATEGRAPHICS VEST_EXPORT bool VEST_WINAPI VeST_InvalidateGraphics(HVEST AVeST)
#define VEST_MIDISEND VEST_EXPORT bool VEST_WINAPI VeST_MidiSend(HVEST AVeST, int ADeltaFrames, int AMidiData0, int AMidiData1, int AMidiData2)
#define VEST_MIDISYSEX VEST_EXPORT bool VEST_WINAPI VeST_MidiSysex(HVEST AVeST, int ADeltaFrames, char* AData, int ALength)
#define VEST_MIDIRECV VEST_EXPORT bool VEST_WINAPI VeST_MidiRecv(HVEST AVeST, int* ADeltaFrames, int* AMidiData0, int* AMidiData1, int* AMidiData2)
#define VEST_SETDRAWMODE VEST_EXPORT bool VEST_WINAPI VeST_SetDrawMode(HVEST AVeST, int AMode)
#define VEST_SETFONTCOLOR VEST_EXPORT bool VEST_WINAPI VeST_SetFontColor(HVEST AVeST, int AR, int AG, int AB, int AA)
#define VEST_SETFILLCOLOR VEST_EXPORT bool VEST_WINAPI VeST_SetFillColor(HVEST AVeST, int AR, int AG, int AB, int AA)
#define VEST_SETFRAMECOLOR VEST_EXPORT bool VEST_WINAPI VeST_SetFrameColor(HVEST AVeST, int AR, int AG, int AB, int AA)
#define VEST_SETFONT VEST_EXPORT bool VEST_WINAPI VeST_SetFont(HVEST AVeST, char* AName, int ASize, int AStyle)
#define VEST_GETFONTSIZE VEST_EXPORT int VEST_WINAPI VeST_GetFontSize(HVEST AVeST)
#define VEST_GETSTRINGWIDTH VEST_EXPORT VEST_F VEST_WINAPI VeST_GetStringWidth(HVEST AVeST, const char* AString)
#define VEST_MOVETO VEST_EXPORT bool VEST_WINAPI VeST_MoveTo(HVEST AVeST, VEST_F AX, VEST_F AY)
#define VEST_LINETO VEST_EXPORT bool VEST_WINAPI VeST_LineTo(HVEST AVeST, VEST_F AX, VEST_F AY)
#define VEST_DRAWRECT VEST_EXPORT bool VEST_WINAPI VeST_DrawRect(HVEST AVeST, VEST_F AX1, VEST_F AY1, VEST_F AX2, VEST_F AY2, int AStyle)
#define VEST_DRAWELLIPSE VEST_EXPORT bool VEST_WINAPI VeST_DrawEllipse(HVEST AVeST, VEST_F AX1, VEST_F AY1, VEST_F AX2, VEST_F AY2, int AStyle)
#define VEST_DRAWPOINT VEST_EXPORT bool VEST_WINAPI VeST_DrawPoint(HVEST AVeST, VEST_F AX, VEST_F AY, int AR, int AG, int AB, int AA)
#define VEST_DRAWSTRING VEST_EXPORT bool VEST_WINAPI VeST_DrawString(HVEST AVeST, const char* AString, VEST_F AX1, VEST_F AY1, VEST_F AX2, VEST_F AY2, bool AIsOpaque, int AAlign)
#define VEST_DRAWSTRINGUTF8_XY VEST_EXPORT bool VEST_WINAPI VeST_DrawStringUTF8_XY(HVEST AVeST, const char* AString, VEST_F AX, VEST_F AY, bool AAntiAlias)
#define VEST_DRAWSTRINGUTF8 VEST_EXPORT bool VEST_WINAPI VeST_DrawStringUTF8(HVEST AVeST, const char* AString, VEST_F AX1, VEST_F AY1, VEST_F AX2, VEST_F AY2, int AAlign, bool AAntiAlias)
#define VEST_GETPOINT VEST_EXPORT bool VEST_WINAPI VeST_GetPoint(HVEST AVeST, VEST_F AX, VEST_F AY, int* AR, int* AG, int* AB, int* AA)
#define VEST_BITMAP_CREATE VEST_EXPORT HVEST_BITMAP VEST_WINAPI VeST_BitmapCreate()
#define VEST_BITMAP_FREE VEST_EXPORT bool VEST_WINAPI VeST_BitmapFree(HVEST_BITMAP ABitmap)
#define VEST_BITMAP_LOADFROMFILE VEST_EXPORT bool VEST_WINAPI VeST_BitmapLoadFromFile(HVEST_BITMAP ABitmap, char* AFileName)
#define VEST_BITMAP_GETWIDTH VEST_EXPORT VEST_F VEST_WINAPI VeST_BitmapGetWidth(HVEST_BITMAP ABitmap)
#define VEST_BITMAP_GETHEIGHT VEST_EXPORT VEST_F VEST_WINAPI VeST_BitmapGetHeight(HVEST_BITMAP ABitmap)
#define VEST_BITMAP_GETTRANSPARENTCOLOR VEST_EXPORT bool VEST_WINAPI VeST_BitmapGetTransparentColor(HVEST_BITMAP ABitmap, int* AR, int* AG, int* AB, int* AA)
#define VEST_BITMAP_SETTRANSPARENTCOLOR VEST_EXPORT bool VEST_WINAPI VeST_BitmapSetTransparentColor(HVEST_BITMAP ABitmap, int AR, int AG, int AB, int AA)
#define VEST_BITMAP_GETNOALPHA VEST_EXPORT bool VEST_WINAPI VeST_BitmapGetNoAlpha(HVEST_BITMAP ABitmap)
#define VEST_BITMAP_SETNOTALPHA VEST_EXPORT bool VEST_WINAPI VeST_BitmapSetNoAlpha(HVEST_BITMAP ABitmap, bool AState)
#define VEST_BITMAP_DRAW VEST_EXPORT bool VEST_WINAPI VeST_BitmapDraw(HVEST_BITMAP ABitmap, HVEST AVeST, VEST_F AX1, VEST_F AY1, VEST_F AX2, VEST_F AY2, VEST_F AX, VEST_F AY)
#define VEST_BITMAP_DRAW_ALPHABLEND VEST_EXPORT bool VEST_WINAPI VeST_BitmapDrawAlphaBlend(HVEST_BITMAP ABitmap, HVEST AVeST, VEST_F AX1, VEST_F AY1, VEST_F AX2, VEST_F AY2, VEST_F AX, VEST_F AY, char AAlpha)
#define VEST_BITMAP_DRAW_TRANSPARENT VEST_EXPORT bool VEST_WINAPI VeST_BitmapDrawTransparent(HVEST_BITMAP ABitmap, HVEST AVeST, VEST_F AX1, VEST_F AY1, VEST_F AX2, VEST_F AY2, VEST_F AX, VEST_F AY)
#define VEST_MASTERIDLE VEST_EXPORT bool VEST_WINAPI VeST_MasterIdle(HVEST AVeST)
#define VEST_PROGRAMSARECHUNKS VEST_EXPORT bool VEST_WINAPI VeST_ProgramsAreChunks(HVEST AVeST, bool AState)

VEST_INIT;
VEST_GETDATA;
VEST_GETNUMINPUTS;
VEST_GETNUMOUTPUTS;
VEST_SETNUMINPUTS;
VEST_SETNUMOUTPUTS;
VEST_SETUNIQUEID;
VEST_GETSAMPLERATE;
VEST_GETTEMPO;
VEST_GETTRANSPORTRECORDING;
VEST_GETTRANSPORTPLAYING;
VEST_GETPPQPOS;
VEST_GETBARSTARTPOS;
VEST_GETTIMEINFO3;
VEST_GETBLOCKSIZE;
VEST_GETHOSTLANGUAGE;
VEST_GETHOSTPRODUCTSTRING;
VEST_GETHOSTVENDORSTRING;
VEST_GETHOSTVENDORVERSION;
VEST_GETMASTERVERSION;
VEST_GETCURRENTUNIQUEID;
VEST_SETGRAPHICSSIZE;
VEST_GETGRAPHICSSIZE;
VEST_SETINITIALDELAY;
VEST_SETISSYNTH;
VEST_UPDATEDISPLAY;
VEST_INVALIDATEGRAPHICS;
VEST_MIDISEND;
VEST_MIDISYSEX;
VEST_MIDIRECV;
VEST_SETFONTCOLOR;
VEST_SETFILLCOLOR;
VEST_SETFRAMECOLOR;
VEST_SETFONT;
VEST_GETFONTSIZE;
VEST_GETSTRINGWIDTH;
VEST_MOVETO;
VEST_LINETO;
VEST_DRAWRECT;
VEST_DRAWELLIPSE;
VEST_DRAWPOINT;
VEST_DRAWSTRING;
VEST_DRAWSTRINGUTF8_XY;
VEST_DRAWSTRINGUTF8;
VEST_BITMAP_CREATE;
VEST_BITMAP_FREE;
VEST_BITMAP_LOADFROMFILE;
VEST_BITMAP_GETWIDTH;
VEST_BITMAP_GETHEIGHT;
VEST_BITMAP_GETTRANSPARENTCOLOR;
VEST_BITMAP_SETTRANSPARENTCOLOR;
VEST_BITMAP_GETNOALPHA;
VEST_BITMAP_SETNOTALPHA;
VEST_BITMAP_DRAW;
VEST_BITMAP_DRAW_ALPHABLEND;
VEST_BITMAP_DRAW_TRANSPARENT;
VEST_MASTERIDLE;
VEST_PROGRAMSARECHUNKS;
VEST_GETPOINT;
VEST_SETDRAWMODE;

// Define entry points for supported plugin types.

#ifdef VEST_VST
VEST_EXPORT HVEST_AEFFECT VEST_WINAPI VeST_GetAEffect(HVEST AVeST);
#endif // VEST_VST

#ifdef VEST_LV1
VEST_EXPORT LADSPA_Descriptor* VEST_WINAPI VeST_GetLADSPA(HVEST AVeST);
#endif // VEST_LV1

#ifdef VEST_LV2
VEST_EXPORT LV2_Descriptor* VEST_WINAPI VeST_GetLADSPA(HVEST AVeST);
#endif // VEST_LV2

#ifdef __cplusplus
}
#endif // __cplusplus

// VST Defines hInstance as an untyped handle.
extern VEST_HANDLE hInstance;

// Useful endian functions.

inline int EndianInt(uint8_t a, uint8_t b, bool ALittleEndian)
{
return ALittleEndian ? (int8_t)b << 8 | a : (int8_t)a << 8 | b;
}

inline int EndianInt(uint8_t a, uint8_t b, uint8_t c, bool ALittleEndian)
{
return ALittleEndian ? (int8_t)c << 16 | b << 8 | a : (int8_t)a << 16 | b << 8 | c;
}

inline int EndianInt(uint8_t a, uint8_t b, uint8_t c, uint8_t d, bool ALittleEndian)
{
return ALittleEndian ? (int8_t)d << 24 | c << 16 | b << 8 | a : (int8_t)a << 24 | b << 16 | c << 8 | d;
}

#define WAVE_RIFF EndianInt('R', 'I', 'F', 'F', true)
#define WAVE_WAVE EndianInt('W', 'A', 'V', 'E', true)
#define WAVE_FMT  EndianInt('f', 'm', 't', ' ', true)
#define WAVE_FACT EndianInt('f', 'a', 'c', 't', true)
#define WAVE_CUE  EndianInt('c', 'u', 'e', ' ', true)
#define WAVE_DATA EndianInt('d', 'a', 't', 'a', true)
#define WAVE_LIST EndianInt('L', 'I', 'S', 'T', true)

// This is the start of a general purpose RIFF parser. The class may change, so
// I wouldn't use it just yet. The code might end up as WAV loading functions in VeST.

class CVeST_RIFF
{
private:

  FILE* FFile;
  unsigned FHead;
  int32_t FName;
  uint32_t FSize;

public:

  CVeST_RIFF()
  {
    FFile = nullptr;
    FName = FSize = FHead = 0;
  }
  uint32_t GetSize()
  {
    return FSize;
  }
  bool IsName(int32_t AName)
  {
    return FName == AName;
  }
  // Opens chunk. Returns true if successful.
  // TODO: There is nothing to prevent reading behond a parent chunk,
  // therefore, we should pass a parent chunk pointer and check its
  // data avaliablity before opening. We should also check if a chunk
  // is larger than the parent, which is a broken file, but we should check.
  bool Open(FILE* AFile)
  {
    Close();
    FFile = AFile;
    FHead = ftell(FFile);
    if (FHead >= 0) {
      FSize = 8; // Header size is 8 bytes.
      if (Read(FName) && Read(FSize)) {
        FHead += 8; // Move head inside chunk.
        return true;
      }
    }
    return false;
  }
  // Opens a chunk and checks name. Returns true if successful.
  bool Open(FILE* AFile, uint32_t AName)
  {
    return Open(AFile) && IsName(AName);
  }
  // Rewinds file position to beginning of chunk.
  void Rewind()
  {
    fseek(FFile, FHead, SEEK_SET);
  }
  // Closes chunk and sets file position to next chunk, ready for opening.
  void Close()
  {
    if (FFile) {
      fseek(FFile, FHead + FSize, SEEK_SET);
      FFile = nullptr;
      FName = FHead = FSize = 0;
    }
  }
  // Returns the number of bytes avaliable. May return a negitive value if file pos is behond chunk end.
  long BytesAvaliable()
  {
    return (FHead + FSize) - ftell(FFile);
  }
  // Reads a variable length block of data from chunk. Returns true if successful.
  bool Read(void* AValue, int ASize)
  {
    return BytesAvaliable() >= ASize && fread(memset(AValue, 0, ASize), ASize, 1, FFile) == 1;
  }
  // Rewinds chunk, and reads entire chunk into a vector. Returns true if successful.
  bool ReadChunk(std::vector<uint8_t>& AData)
  {
    Rewind();
    AData.resize(FSize);
    return Read(&AData[0], AData.size());
  }
  // Reads a signed 16bit int from chunk. Returns true if successful.
  bool Read(int16_t& AValue)
  {
    return Read(&AValue, sizeof(AValue));
  }
  // Reads an unsigned 32bit int from chunk. Returns true if successful.
  bool Read(uint32_t& AValue)
  {
    return Read(&AValue, sizeof(AValue));
  }
  // Reads a signed 32bit int from chunk. Returns true if successful.
  bool Read(int32_t& AValue)
  {
    return Read(&AValue, sizeof(AValue));
  }
};

#endif

