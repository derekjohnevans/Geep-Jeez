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
#endif

#ifdef _WIN32
#include <io.h>
#include <windows.h>
#define strcasecmp _stricmp
#define strncasecmp _strnicmp
#endif

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
#endif

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
#endif

#ifdef __cplusplus
extern "C" {
#endif

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
typedef void (VEST_CALLBACK TVeST_SetIndexedDouble)(HVEST AVeST, int AIndex, double AValue);
typedef double (VEST_CALLBACK TVeST_GetIndexedDouble)(HVEST AVeST, int AIndex);
typedef void (VEST_CALLBACK TVeST_GetIndexedString)(HVEST AVeST, int AIndex, char* AString);
typedef void (VEST_CALLBACK TVeST_ProcessReplacing)(HVEST AVeST, float** AInputs, float** AOutputs, int ASampleFrames);
typedef void (VEST_CALLBACK TVeST_ProcessDoubleReplacing)(HVEST AVeST, double** AInputs, double** AOutputs,
    int ASampleFrames);
typedef void (VEST_CALLBACK TVeST_MouseEvent)(HVEST AVeST, double AX, double AY, int AButtons);
typedef void (VEST_CALLBACK TVeST_KeyEvent)(HVEST AVeST, int AChar, int AVirtual, int AModifier);
typedef void (VEST_CALLBACK TVeST_Draw)(HVEST AVeST, double AWidth, double AHeight);
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
  TVeST_GetIndexedDouble* OnGetParameter;
  TVeST_SetIndexedDouble* OnSetParameter;
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
#define VEST_GETTEMPO VEST_EXPORT double VEST_WINAPI VeST_GetTempo(HVEST AVeST)
#define VEST_GETTRANSPORTRECORDING VEST_EXPORT bool VEST_WINAPI VeST_GetTransportRecording(HVEST AVeST)
#define VEST_GETTRANSPORTPLAYING VEST_EXPORT bool VEST_WINAPI VeST_GetTransportPlaying(HVEST AVeST)
#define VEST_GETPPQPOS VEST_EXPORT double VEST_WINAPI VeST_GetPpqPos(HVEST AVeST)
#define VEST_GETBARSTARTPOS VEST_EXPORT double VEST_WINAPI VeST_GetBarStartPos(HVEST AVeST)
#define VEST_GETTIMEINFO3 VEST_EXPORT bool VEST_WINAPI VeST_GetTimeInfo3(HVEST AVeST, double* ATempo, double* ASigNumerator, double* ASigDenominator)
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
#define VEST_GETSTRINGWIDTH VEST_EXPORT double VEST_WINAPI VeST_GetStringWidth(HVEST AVeST, const char* AString)
#define VEST_MOVETO VEST_EXPORT bool VEST_WINAPI VeST_MoveTo(HVEST AVeST, double AX, double AY)
#define VEST_LINETO VEST_EXPORT bool VEST_WINAPI VeST_LineTo(HVEST AVeST, double AX, double AY)
#define VEST_DRAWRECT VEST_EXPORT bool VEST_WINAPI VeST_DrawRect(HVEST AVeST, double AX1, double AY1, double AX2, double AY2, int AStyle)
#define VEST_DRAWELLIPSE VEST_EXPORT bool VEST_WINAPI VeST_DrawEllipse(HVEST AVeST, double AX1, double AY1, double AX2, double AY2, int AStyle)
#define VEST_DRAWPOINT VEST_EXPORT bool VEST_WINAPI VeST_DrawPoint(HVEST AVeST, double AX, double AY, int AR, int AG, int AB, int AA)
#define VEST_DRAWSTRING VEST_EXPORT bool VEST_WINAPI VeST_DrawString(HVEST AVeST, const char* AString, double AX1, double AY1, double AX2, double AY2, bool AIsOpaque, int AAlign)
#define VEST_DRAWSTRINGUTF8_XY VEST_EXPORT bool VEST_WINAPI VeST_DrawStringUTF8_XY(HVEST AVeST, const char* AString, double AX, double AY, bool AAntiAlias)
#define VEST_DRAWSTRINGUTF8 VEST_EXPORT bool VEST_WINAPI VeST_DrawStringUTF8(HVEST AVeST, const char* AString, double AX1, double AY1, double AX2, double AY2, int AAlign, bool AAntiAlias)
#define VEST_GETPOINT VEST_EXPORT bool VEST_WINAPI VeST_GetPoint(HVEST AVeST, double AX, double AY, int* AR, int* AG, int* AB, int* AA)
#define VEST_BITMAP_CREATE VEST_EXPORT HVEST_BITMAP VEST_WINAPI VeST_BitmapCreate()
#define VEST_BITMAP_FREE VEST_EXPORT bool VEST_WINAPI VeST_BitmapFree(HVEST_BITMAP ABitmap)
#define VEST_BITMAP_LOADFROMFILE VEST_EXPORT bool VEST_WINAPI VeST_BitmapLoadFromFile(HVEST_BITMAP ABitmap, char* AFileName)
#define VEST_BITMAP_GETWIDTH VEST_EXPORT double VEST_WINAPI VeST_BitmapGetWidth(HVEST_BITMAP ABitmap)
#define VEST_BITMAP_GETHEIGHT VEST_EXPORT double VEST_WINAPI VeST_BitmapGetHeight(HVEST_BITMAP ABitmap)
#define VEST_BITMAP_GETTRANSPARENTCOLOR VEST_EXPORT bool VEST_WINAPI VeST_BitmapGetTransparentColor(HVEST_BITMAP ABitmap, int* AR, int* AG, int* AB, int* AA)
#define VEST_BITMAP_SETTRANSPARENTCOLOR VEST_EXPORT bool VEST_WINAPI VeST_BitmapSetTransparentColor(HVEST_BITMAP ABitmap, int AR, int AG, int AB, int AA)
#define VEST_BITMAP_GETNOALPHA VEST_EXPORT bool VEST_WINAPI VeST_BitmapGetNoAlpha(HVEST_BITMAP ABitmap)
#define VEST_BITMAP_SETNOTALPHA VEST_EXPORT bool VEST_WINAPI VeST_BitmapSetNoAlpha(HVEST_BITMAP ABitmap, bool AState)
#define VEST_BITMAP_DRAW VEST_EXPORT bool VEST_WINAPI VeST_BitmapDraw(HVEST_BITMAP ABitmap, HVEST AVeST, double AX1, double AY1, double AX2, double AY2, double AX, double AY)
#define VEST_BITMAP_DRAW_ALPHABLEND VEST_EXPORT bool VEST_WINAPI VeST_BitmapDrawAlphaBlend(HVEST_BITMAP ABitmap, HVEST AVeST, double AX1, double AY1, double AX2, double AY2, double AX, double AY, char AAlpha)
#define VEST_BITMAP_DRAW_TRANSPARENT VEST_EXPORT bool VEST_WINAPI VeST_BitmapDrawTransparent(HVEST_BITMAP ABitmap, HVEST AVeST, double AX1, double AY1, double AX2, double AY2, double AX, double AY)
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
#endif

// VST Defines hInstance as an untyped handle.
extern VEST_HANDLE hInstance;

#endif

