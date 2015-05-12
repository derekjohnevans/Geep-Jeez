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

#ifndef _JES2CPP_H_
#define _JES2CPP_H_

#ifndef EEL_F
#define EEL_F float
#endif

#define Real EEL_F

#include "VeST.h"
// Eventually the geep library will be included is VeST, Maybe.
#include "geep.h" 

#ifndef _JES2CPP_NO_BASS_
#include "bass.h"
#endif

extern String FileNameResolve(const String& AFileName);

// Math Constants

#ifndef M_PI
#define M_PI ((Real)3.14159265358979323846)
#endif

#define M_ZERO ((Real)0)
#define M_ONE ((Real)1)
#define M_TRUE M_ONE
#define M_FALSE M_ZERO
#define M_NOP M_ZERO
#define M_ERROR (-M_ONE)
#define M_EPSILON ((Real)0.00001)

// These are used to try to make the translated C++ more readable. Unsure if it works.

#define THEN ?
#define ELSE :

// EEL variable/function namespacing macros.

#define VAR(A) _var_##A
#define FUN(A) _fun_##A

// Expand safe operators to C++ operators

#define CHR(AX) (AX)
#define SET(AX, AY) ((AX) = (AY))
#define EQUX(AX, AY) ((AX) == (AY))
#define NEQX(AX, AY) ((AX) != (AY))
#define GT(AX, AY) ((AX) > (AY))
#define LT(AX, AY) ((AX) < (AY))
#define GTE(AX, AY) ((AX) >= (AY))
#define LTE(AX, AY) ((AX) <= (AY))
#define MUL(AX, AY) ((AX) * (AY))
#define DIV(AX, AY) ((AX) / (AY))
#define ADD(AX, AY) ((AX) + (AY))
#define SUB(AX, AY) ((AX) - (AY))
#define POW(AX, AY) pow(AX, AY)
#define OR(AX, AY) (Real)((LONG)(AX) | (LONG)(AY))
#define AND(AX, AY) (Real)((LONG)(AX) & (LONG)(AY))
#define XOR(AX, AY) (Real)((LONG)(AX) ^ (LONG)(AY))
#define SHL(AX, AY) (Real)((LONG)(AX) << (LONG)(AY))
#define SHR(AX, AY) (Real)((LONG)(AX) >> (LONG)(AY))
#define NOT(AX) (ABS(AX) < M_EPSILON ? M_TRUE : M_FALSE)
#define ANDIF(AX, AY) (IF(AX) && IF(AY))
#define ORIF(AX, AY) (IF(AX) || IF(AY))

// Unsafe operators are implemented as inline functions.

inline int FLOOR(Real AX) { return AX < 0 ? (int)(AX - (Real)0.9999) : (int)AX; }
inline int CEIL(Real AX) { return AX < 0 ? (int)AX : (int)(AX + (Real)0.9999); }
inline int CLAMP(int AX, int AMin, int AMax) { return Min(Max(AX, AMin), AMax); }

inline Real ABS(Real AX) { return AX < M_ZERO ? -AX : AX; }
inline Real MOD(Real AX, Real AY) { return fmod(AX, AY); }
inline Real EQU(Real AX, Real AY) { return ABS(AX - AY) < M_EPSILON ? M_TRUE : M_FALSE; }
inline Real NEQ(Real AX, Real AY) { return ABS(AX - AY) < M_EPSILON ? M_FALSE : M_TRUE; }

inline bool IF(bool AX) { return AX; }
inline bool IF(Real AX) { return ABS(AX) < M_EPSILON ? false : true; }

#ifndef GFX_RATE
#define GFX_RATE 30
#endif

#define SAMPLE_COUNT 64
#define SLIDER_COUNT 128

// Real type convertion functions.

inline int REAL2INT(Real AX) { return AX < 0 ? (int)(AX - (Real)0.0001) : (int)(AX + (Real)0.0001); }
inline int REAL2FIXED(Real AX) { return (int)(AX * 0x10000); }
inline int REAL2PEN(Real AX) { return CLAMP(REAL2INT(AX * 255), 0, 255); }
inline int REAL2SAMPLE(Real AX) { return REAL2INT(AX) & (SAMPLE_COUNT - 1); }
inline int REAL2SLIDER(Real AX) { return REAL2INT(AX) & (SLIDER_COUNT - 1); }

class CJes2CppParameter 
{
  public:

    bool FIsInitialized;
    int FIndex;
    Real FDefValue, FMinValue, FMaxValue, FStepValue;
    String FFilePath, FFileName, FLabelString, FDescription;
    TStringDynArray FOptions;

  public:

    CJes2CppParameter(int AIndex, Real ADefValue, Real AMinValue, Real AMaxValue, Real AStepValue, 
      const String& AFilePath, const String& AFileName, const String& ALabelString, const String& ADescription);
    
    Real ToSlider(Real AValue);
    Real FromSlider(Real AValue);
    void GetParameterName(PCHAR AString);
    int GetOptionIndex(Real AValue);
    void GetDisplayFromSliderValue(PCHAR AString, Real AValue);
    void GetLabel(PCHAR AString, Real AValue);

    void Init();
};

class CJes2CppMathBasic
{
  public:  

    inline static Real FUN(sqr)(Real AX) { return AX * AX; }
    inline static Real FUN(abs)(Real AX) { return AX < M_ZERO ? -AX : AX; }
	  inline static Real FUN(max)(Real AX, Real AY) { return AX > AY ? AX : AY; }
	  inline static Real FUN(min)(Real AX, Real AY) { return AX < AY ? AX : AY; }
    inline static Real FUN(sign)(Real AX) { return AX > M_ZERO ? M_ONE : AX < M_ZERO ? -M_ONE : M_ZERO; }
};

class CJes2CppMath : public CJes2CppMathBasic
{
  public:      
     
#define ISNAN(AX) ((AX) != (AX))
#define MATH1(AFN, AX) (ISNAN(AX) ? AX : AFN(AX))
#define MATH2(AFN, AX, AY) (ISNAN(AX) ? AX : ISNAN(AY) ? AY : AFN(AX, AY))

    inline static Real FUN(sin)(Real AX) { return MATH1(sin, AX); }
	  inline static Real FUN(cos)(Real AX) { return MATH1(cos, AX); }
    inline static Real FUN(tan)(Real AX) { return MATH1(tan, AX); }
    inline static Real FUN(asin)(Real AX) { return MATH1(asin, AX); }
    inline static Real FUN(acos)(Real AX) { return MATH1(acos, AX); }
    inline static Real FUN(atan)(Real AX) { return MATH1(atan, AX); }
    inline static Real FUN(atan2)(Real AX, Real AY) { return MATH2(atan2, AX, AY); } 
	  inline static Real FUN(sqrt)(Real AX) { return ISNAN(AX) ? AX : sqrt(FUN(abs)(AX)); }
	  inline static Real FUN(exp)(Real AX) { return MATH1(exp, AX); }
    inline static Real FUN(log)(Real AX) { return MATH1(log, AX); }
    inline static Real FUN(log10)(Real AX) { return MATH1(log10, AX); }
	  inline static Real FUN(rand)(Real AX) { return AX * (Real)rand() / (Real)RAND_MAX; } // Is this correct? 
    inline static Real FUN(floor)(Real AX) { return MATH1(floor, AX); }
    inline static Real FUN(ceil)(Real AX) { return MATH1(ceil, AX); }
    inline static Real FUN(pow)(Real AX, Real AY) { return MATH2(pow, AX, AY); }
    inline static Real FUN(invsqrt)(Real AX) { return M_ONE / FUN(sqrt)(AX); } 

#undef ISNAN
#undef MATH1
#undef MATH2
};

class CJes2CppTime : public CJes2CppMath
{
  public:

    Real FUN(time)();
    Real FUN(time)(Real& ATimeStamp);
};

typedef TPagedArray<Real, 16> CMemory;

class CJes2CppMemory : public CJes2CppTime
{
  public:

    CMemory FMemory;  

    inline Real& MEM(Real ABase, Real AOffset)
    {
      return FMemory[REAL2INT(ABase + AOffset)];
    }
    Real FUN(memcpy)(Real ADst, Real ASrc, Real ALength);
    Real FUN(memset)(Real ADst, Real AValue, Real ALength);
    Real FUN(freembuf)(Real ACount);
};

class CJes2CppMDCT : public CJes2CppMemory
{
  public:

    Real FUN(mdct)(Real AIndex, Real ALength);
    Real FUN(imdct)(Real AIndex, Real ALength);
};

class CJes2CppFFT : public CJes2CppMDCT
{
  public:

    Real FUN(fft)(Real AIndex, Real ALength);
    Real FUN(ifft)(Real AIndex, Real ALength);
    Real FUN(fft_permute)(Real AIndex, Real ALength);
    Real FUN(fft_ipermute)(Real AIndex, Real ALength);
    Real FUN(convolve_c)(Real ADst, Real ASrc, Real ALength);    
};

class CJes2CppVeST : public CJes2CppFFT 
{
  public:

    HVEST FVeST;
    bool FUpdateDisplay;
          
    CJes2CppVeST()
    {
      FVeST = NULL;  
      FUpdateDisplay = FALSE;
    }  
};

class CJes2CppMidi : public CJes2CppVeST
{
  public: 

    Real FUN(midirecv)(Real& AIndex, Real& AMsg1, Real& AMsg23);
    Real FUN(midisend)(Real AIndex, Real AMsg1, Real AMsg2, Real AMsg3);
    Real FUN(midisend)(Real AIndex, Real AMsg1, Real AMsg23);
    Real FUN(midisyx)(Real AIndex, Real AMsgPtr, Real ALength);    
};

class CJes2CppSliders : public CJes2CppMidi
{
  public:

    TDynArray<Real> VAR(slider$);

    CJes2CppSliders() : VAR(slider$)(SLIDER_COUNT) { }

    Real FUN(sliderchange)(Real AValue);
    inline Real& FUN(slider)(Real AIndex) { return VAR(slider$)[REAL2SLIDER(AIndex)]; }
};

class CJes2CppSamples : public CJes2CppSliders
{
  public:

    TDynArray<Real> VAR(spl$);

    CJes2CppSamples() : VAR(spl$)(SAMPLE_COUNT) { }

    inline Real& FUN(spl)(Real AIndex) { return VAR(spl$)[REAL2SAMPLE(AIndex)]; }
};

#define STRING_CONSTANT 10000 
#define STRING_FILENAME 90000

class CJes2CppStrings : public CJes2CppSamples
{
  private:

    TStringMap FStringMap;
    int FStringConstantKey;

  public:

    Real VAR(str_count$), FStringVerdana;

    CJes2CppStrings()
    {
      FStringConstantKey = STRING_CONSTANT;
      ClearStrings();
    }
    void ClearStrings();

    void VPrintF(PCHAR AString, PCHAR AFormat, va_list AArgs);    

    inline String& GetString(int AKey)
    {
      String& LString = FStringMap.GetString(AKey);    
      VAR(str_count$) = (Real)FStringMap.Count();
      return LString;
    }
    inline String& GetString(Real AKey)
    {
      return GetString(REAL2INT(AKey));
    }
    inline int SetString(int AKey, const String& AString)
    {
      GetString(AKey) = AString;
      return AKey;
    }
    inline Real STR(const String& AString)
    {
      return SetString(FStringConstantKey++, AString);
    } 
    inline PCHAR GetCStr(Real AKey)
    {
      return (PCHAR)GetString(AKey).c_str(); 
    }
    inline void SetFileName(int AKey, const String& AFileName)
    {
      SetString(AKey + STRING_FILENAME, AFileName);
    }
    inline String& GetFileName(int AKey)
    {
      return FStringMap.Exists(AKey + STRING_FILENAME) ? GetString(AKey + STRING_FILENAME) : GetString(AKey);
    }

    Real FUN(strlen)(Real AStr);
    Real FUN(strcpy)(Real ADst, Real ASrc);
    Real FUN(strcpy_from)(Real ADst, Real ASrc, Real AIndex);
    Real FUN(strcpy_substr)(Real ADst, Real ASrc, Real AIndex, Real ALength);
    Real FUN(strcpy_substr)(Real ADst, Real ASrc, Real AIndex);
    Real FUN(strcat)(Real AStr1, Real AStr2);
    Real FUN(strncpy)(Real ADst, Real ASrc, Real ALength);
    Real FUN(strcmp)(Real AStr1, Real AStr2);
    Real FUN(stricmp)(Real AStr1, Real AStr2);
    Real FUN(strncmp)(Real AStr1, Real AStr2, Real ALength);
    Real FUN(strnicmp)(Real AStr1, Real AStr2, Real ALength);
    Real FUN(str_getchar)(Real AStr, Real AIndex);
    Real FUN(str_setchar)(Real AStr, Real AIndex, Real AValue);
    Real FUN(sprintf)(Real AStr, Real AFormat, ...);
    Real FUN(strcpy_fromslider)(Real& AStr, Real& ASlider);
    Real FUN(match)(Real ANeedle, Real AHaystack, ...);
};

class CJes2CppDescription : public CJes2CppStrings
{
  public:

    String FEffectName, FProductString, FVendorString, FProgramName;
    int FVendorVersion, FUniqueId, FChannelCount;
    TDynArray<CJes2CppParameter> FParameters;

  public:

    CJes2CppDescription();

  public:

    int AddParam(int AIndex, Real ADefValue, Real AMinValue, Real AMaxValue, Real AStepValue, 
      const String& AFilePath, const String& AFileName, const String& ALabel, const String& AText);
    int FindParameterBySliderIndex(int AIndex);
};

class CJes2CppStream
{
  public:

    TSingleDynArray FBuffer;
    int FPosition;

    CJes2CppStream();

    void Rewind();
    void Clear();
    bool Write(Real AValue);
    bool Read(Real& AValue);
    int DataAvaliable();

    void ReadFromFile(FILE* AFile);
    bool LoadFromFileTxt(const String& AFileName);
    bool LoadFromFileBin(const String& AFileName);
    bool LoadFromFileAud(const String& AFileName, int& AChannelCount, int& ASampleRate);

    bool SaveToFileBin(const String& AFileName);

    bool ReadString(String& AString);
};

#define FILE_CLOSED 0
#define FILE_READ 1
#define FILE_WRITE 2

#define FILE_HANDLE_SERIAL 0
#define FILE_HANDLE_SLIDER 10000

class CJes2CppFile 
{
  private:
    
    String FFileName;

  public:

    bool FIsText;
    int FMode, FChannelCount, FSampleRate;
    CJes2CppStream FStream;

    CJes2CppFile();
    ~CJes2CppFile();

    void Close();
    bool OpenRead(const String& AFileName);
    void OpenWrite(const String& AFileName);
    bool StreamValue(Real& AValue);
    int StreamMemory(CMemory* AMemory, Real AIndex, Real ALength);
};

class CJes2CppFiles : public CJes2CppDescription
{
  public:

    TDynMap<int, CJes2CppFile> FFiles; 

    Real FUN(file_open)(int AIndex);
    Real FUN(file_open)(Real& ASlider);
    Real FUN(file_close)(Real& AHandle);
    Real FUN(file_rewind)(Real AHandle);
    Real FUN(file_var)(Real AHandle, Real& AValue);
    Real FUN(file_mem)(Real AHandle, Real AIndex, Real ALength);
    Real FUN(file_avail)(Real AHandle);
    Real FUN(file_riff)(Real AHandle, Real& AChannelCount, Real& ASampleRate);
    Real FUN(file_text)(Real AHandle);
    Real FUN(file_string)(Real AHandle, Real AString);
};

class CJes2CppFont
{
  public:

    String FName;
    Real FSize;
    int FStyle;

    CJes2CppFont();    
};

class CJes2CppFonts : public CJes2CppFiles
{
  public:

    Real VAR(gfx_texth$);
    TDynMap<int, CJes2CppFont> FFonts;

    CJes2CppFonts();

    void SetFont(const String& AName, Real ASize, int AStyle); 

    Real FUN(gfx_setfont)(Real AIndex, Real AName, Real ASize, Real AStyle);
    Real FUN(gfx_setfont)(Real AIndex, Real AName, Real ASize);
    Real FUN(gfx_setfont)(Real AIndex);
};

class CJes2CppImage
{
  public:

    int FWidth, FHeight;
    HVEST_BITMAP FBitmap;

    CJes2CppImage();
    ~CJes2CppImage();

    void Clear();
    bool LoadFromFile(const String& AFileName);
};

class CJes2CppGraphics : public CJes2CppFonts
{
  private:

    TDynMap<int, CJes2CppImage> FImages;

    void SetFillColor();
    void SetFrameColor();
    void SetFontColor();
    void _DrawString(PCHAR AString);
    void DrawRoundRect(int AX1, int AY1, int AX2, int AY2, int AR) ;
    void DrawGradRect(
      int AX1, int AY1, int AX2, int AY2,
      int AIR, int AIG, int AIB, int AIA,
      int AR1, int AG1, int AB1, int AA1,
      int AR2, int AG2, int AB2, int AA2);
    CJes2CppImage* GetImage(Real AIndex);

  public:   
    
    Real VAR(gfx_clear$), VAR(gfx_r$), VAR(gfx_g$), VAR(gfx_b$), VAR(gfx_a$), VAR(gfx_x$), VAR(gfx_y$), VAR(gfx_w$), VAR(gfx_h$), VAR(gfx_rate$);

    CJes2CppGraphics();

    Real FUN(gfx_setpixel)(Real AR, Real AG, Real AB);
    Real FUN(gfx_circle)(Real AX, Real AY, Real AR, Real AFill);
    Real FUN(gfx_drawstr)(Real AString);
    Real FUN(gfx_gradrect)(
      Real AX, Real AY, Real AW, Real AH,
      Real AR, Real AG, Real AB, Real AA,
      Real AR1, Real AG1, Real AB1, Real AA1,
      Real AR2, Real AG2, Real AB2, Real AA2);

    Real FUN(gfx_lineto)(Real AX, Real AY, Real AFlags);
    Real FUN(gfx_lineto)(Real AX, Real AY);
    Real FUN(gfx_line)(Real AX1, Real AY1, Real AX2, Real AY2);
    Real FUN(gfx_measurestr)(Real AString, Real &AW, Real &AH);
    Real FUN(gfx_rectto)(Real AX, Real AY);
    Real FUN(gfx_roundrect)(Real AX, Real AY, Real AW, Real AH, Real AR);
    Real FUN(gfx_drawnumber)(Real ANumber, Real ADigitCount);
    Real FUN(gfx_drawchar)(Real AChar);
    Real FUN(gfx_printf)(Real AFormat, ...);

    Real FUN(gfx_setimgdim)(Real AIndex, Real AWidth, Real AHeight);
    Real FUN(gfx_getimgdim)(Real AIndex, Real& AWidth, Real& AHeight);
    Real FUN(gfx_loadimg)(Real AIndex, Real AFileName);

    Real FUN(gfx_blit)(Real AIndex, Real AScale, Real ARotation, Real AX1, Real AY1, Real AW1, Real AH1, Real AX2, Real AY2, Real AW2, Real AH2);
    Real FUN(gfx_blit)(Real AIndex, Real AScale, Real ARotation, Real AX1, Real AY1, Real AW1, Real AH1, Real AX2, Real AY2);
    Real FUN(gfx_blit)(Real AIndex, Real AScale, Real ARotation, Real AX1, Real AY1, Real AW1, Real AH1);
    Real FUN(gfx_blit)(Real AIndex, Real AScale, Real ARotation, Real AX1, Real AY1);
    Real FUN(gfx_blit)(Real AIndex, Real AScale, Real ARotation);
    Real FUN(gfx_blitext)(Real AIndex, Real AList, Real ARotation);
  };

class CJes2CppMouse : public CJes2CppGraphics
{
  public:

    Real VAR(mouse_cap$), VAR(mouse_x$), VAR(mouse_y$);

    CJes2CppMouse() 
    {
      VAR(mouse_cap$) = VAR(mouse_x$) = VAR(mouse_y$) = 0;  
    } 
};

class TJes2Cpp : public CJes2CppMouse
{
  public:

    clock_t FClockUpdate, FClockInvalidate;
    Real 
      VAR(num_ch$), VAR(pdc_delay$), VAR(srate$), VAR(samplesblock$), 
      VAR(tempo$), VAR(ts_num$), VAR(ts_denom$), VAR(trigger$), VAR(beat_position$), VAR(play_state$);

    TJes2Cpp();
    virtual ~TJes2Cpp();

  public:

    virtual void DoOpen();
    virtual void DoClose();
    virtual void DoSuspend();
    virtual void DoResume();
    virtual void DoInit();
    virtual void DoSlider();
    virtual void DoBlock();
    virtual void DoSample();
    virtual void DoSample(float** AInputs, float** AOutputs, int ASampleFrames);
    virtual void DoSample(double** AInputs, double** AOutputs, int ASampleFrames);
    virtual void DoGfx();
    virtual void DoIdle();
    virtual void DoSerialize();
  
    virtual void SaveToChunk();
    virtual void LoadFromChunk();
};

/*
** Converts a length to a bit length. Updates length to correct length.
*/
inline int LengthToBitLen(int& ALength)
{
  int LResult = 0, LLength = ALength;
  while ((LLength >>= 1) > 0) LResult++;
  ALength = 1 << LResult;
  return LResult;
}

inline bool ContainsByte(DWORD AValue, BYTE AByte)
{
  return 
    ((AValue >>  0) & 0xFF) == AByte ||
    ((AValue >>  8) & 0xFF) == AByte ||
    ((AValue >> 16) & 0xFF) == AByte ||
    ((AValue >> 24) & 0xFF) == AByte ;
}

#endif

