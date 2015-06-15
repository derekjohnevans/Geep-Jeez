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

#ifndef JES2CPP_H
#define JES2CPP_H

#include "vest/vest.h"

// The bass api doesn't work if the default windows sound driver is
// disabled, so I dont recommend using it.
#ifdef JES2CPP_BASS
#ifdef _WIN32
#include "bass/bass.h"
#else
#include "bass/bass.linux.h"
#endif
#endif

// The sndfile api is great!, but somewhat large. Therefore, if you want
// a small release and load wav files, you should look into your own file loader.
#ifdef JES2CPP_SNDFILE
#ifdef _WIN32
#include "libsndfile/sndfile.h"
#else
#include <sndfile.h>
#endif
#endif

#ifndef JES2CPP_INLINE
#define JES2CPP_INLINE inline
#endif

#ifdef __cplusplus
#define JES2CPP_EXTERN extern "C"
#else
#define JES2CPP_EXTERN
#endif

#ifdef _WIN32
#define JES2CPP_EXPORT JES2CPP_EXTERN __declspec(dllexport)
#else
#define JES2CPP_EXPORT JES2CPP_EXTERN __attribute__((visibility("default")))
#endif

#ifndef EEL_F
#define EEL_F double
#endif

#ifndef EEL_I
#define EEL_I int32_t
#endif

#define EmptyStr ""

// map is faster than unordered_map for this app
#define TDynMap std::map

#define DirectorySeparatorDos "\\"
#define DirectorySeparatorUnix "/"

#ifdef _WIN32
#define DirectorySeparator DirectorySeparatorDos
#else
#define DirectorySeparator DirectorySeparatorUnix
#endif

#define ExtensionSeparator "."

typedef std::vector<std::string> TStringDynArray;
typedef std::vector<int> TIntegerDynArray;
typedef std::vector<float> TSingleDynArray;
typedef std::vector<double> TDoubleDynArray;

class TStringMap
{
  private:

    TDynMap<int, std::string> FStrings;

  public:

    TStringMap()
    {
      Clear();
    }
    inline void Clear()
    {
      FStrings.clear();
    }
    inline int Count()
    {
      return FStrings.size();
    }
    inline bool Exists(int AKey)
    {
      return FStrings.find(AKey) != FStrings.end();
    }
    inline std::string& GetString(int AKey)
    {
      return FStrings[AKey];
    }
    inline int SetString(int AKey, const std::string& AString)
    {
      return FStrings[AKey] = AString, AKey;
    }
};

template<class TYPE, int PAGEBITS> class TPagedArray
{
  private:

    TDynMap<int, std::vector<TYPE>> FPages;

  public:

    inline void Clear()
    {
      FPages.clear();
    }
    inline TYPE& operator[](int AIndex)
    {
      return FPages[AIndex >> PAGEBITS].resize(1 << PAGEBITS), FPages[AIndex >> PAGEBITS][AIndex & ((1 << PAGEBITS) - 1)];
    }
    inline void Copy(int ADst, int ASrc, int ALength)
    {
      if (ADst < ASrc) {
        while (ALength-- > 0) {
          (*this)[ADst++] = (*this)[ASrc++];
        }
      } else if (ADst > ASrc) {
        ADst += ALength;
        ASrc += ALength;
        while (ALength-- > 0) {
          (*this)[--ADst] = (*this)[--ASrc];
        }
      }
    }
    inline void Set(int ADst, TYPE AValue, int ALength)
    {
      while (ALength-- > 0) {
        (*this)[ADst++] = AValue;
      }
    }
};

typedef TPagedArray<EEL_F, 16> CMemory;

extern void GetFileNames(std::string APath, TStringDynArray& AFileNames);
extern std::string GetModuleName(VEST_HANDLE AModule);
extern std::string GetCurrentModulePath();
extern bool SameText(const std::string& A, const std::string& B);
extern bool SameStr(const std::string& A, const std::string& B);
extern bool AnsiEndsStr(const std::string& ASubStr, const std::string& AString);
extern bool AnsiStartsStr(const std::string& ASubStr, const std::string& AString);
extern bool FileNameIsPath(const std::string& AFileName);
extern bool FileNameIsRoot(const std::string& AFileName);
extern std::string IncludeTrailingPathDelimiter(const std::string& AFileName);
extern std::string IncludeLeadingPathDelimiter(const std::string& AFileName);
extern std::string ExcludeLeadingPathDelimiter(const std::string& AFileName);
extern int FileNameStart(const std::string& AFileName);
extern std::string ExtractFilePath(const std::string& AFileName);
extern std::string ExtractFileName(const std::string& AFileName);
extern std::string ExtractFileExt(const std::string& AFileName);

extern void GeepError(const std::string& AString);

extern std::string FileNameResolve(const std::string& AFileName);

// Math Constants

#define M_ZERO ((EEL_F)0)
#define M_ONE ((EEL_F)1)
#define M_TRUE M_ONE
#define M_FALSE M_ZERO
#define M_NOP M_ZERO
#define M_ERROR (-M_ONE)
#define M_EPSILON ((EEL_F)0.00001)

#ifdef __GNUC__
#define FPU_ERROR(x) (isnan(x) || isinf(x))
#else
#define FPU_ERROR(x) (_isnan(x) || !_finite(x))
#endif

// Expand safe operators to C++ operators

#define CHR(AX) (AX)
#define OR(AX, AY) (EEL_F)((int32_t)(AX) | (int32_t)(AY))
#define AND(AX, AY) (EEL_F)((int32_t)(AX) & (int32_t)(AY))
#define XOR(AX, AY) (EEL_F)((int32_t)(AX) ^ (int32_t)(AY))
#define SHL(AX, AY) (EEL_F)((int32_t)(AX) << (int32_t)(AY))
#define SHR(AX, AY) (EEL_F)((int32_t)(AX) >> (int32_t)(AY))

// Unsafe operators are implemented as inline functions.

inline EEL_F VAL(int AX)
{
return (EEL_F)AX;
}

inline EEL_F VAL(EEL_F AX)
{
return FPU_ERROR(AX) ? M_ZERO : AX;
}

inline bool IF(int AX)
{
return AX ? true : false;
}

inline bool IF(bool AX)
{
return AX;
}

inline bool IF(EEL_F AX)
{
return AX < M_EPSILON && AX > -M_EPSILON ? false : true;
}

inline EEL_F NOT(EEL_F AX)
{
return AX < M_EPSILON && AX > -M_EPSILON ? M_TRUE : M_FALSE;
}

inline EEL_F EQU(EEL_F AX, EEL_F AY)
{
return AX -= AY, AX < M_EPSILON && AX > -M_EPSILON ? M_TRUE : M_FALSE;
}

inline EEL_F NEQ(EEL_F AX, EEL_F AY)
{
return AX -= AY, AX < M_EPSILON && AX > -M_EPSILON ? M_FALSE : M_TRUE;
}

#ifndef GFX_RATE
#define GFX_RATE 30
#endif

// EEL_F type convertion functions.

inline int EEL_F2I(EEL_F AX)
{
return AX < 0 ? (int)(AX - (EEL_F)0.0001) : (int)(AX + (EEL_F)0.0001);
}

inline int EEL_F2I16(EEL_F AX)
{
return (int)(AX * 0x10000);
}

inline int EEL_F2PEN(EEL_F AX)
{
return std::min<int>(std::max<int>(EEL_F2I(AX * 255), 0), 255);
}

class CJes2CppParameter
{
public:

  bool FIsInitialized;
  int FIndex;
  EEL_F* FVariable;
  EEL_F FDefValue, FMinValue, FMaxValue, FStepValue;
  std::string FFilePath, FFileName, FLabel, FName;
  TStringDynArray FOptions;

public:

  CJes2CppParameter(int AIndex, EEL_F* AVariable, EEL_F ADefValue, EEL_F AMinValue, EEL_F AMaxValue, EEL_F AStepValue,
                    const std::string& AFilePath, const std::string& AFileName, const std::string& ALabel,
                    const std::string& AName)
  {
    FIsInitialized = false;
    FIndex = AIndex;
    FVariable = AVariable;
    FDefValue = ADefValue;
    FMinValue = AMinValue;
    FMaxValue = AMaxValue;
    FStepValue = AStepValue;
    FFilePath = AFilePath;
    FFileName = AFileName;
    FLabel = ALabel;
    FName = AName;
  }
  // Returns a slider value, given a parameter value.
  inline EEL_F Param2Slider(EEL_F AValue)
  {
    return floor((FMinValue + (FMaxValue - FMinValue) * AValue + (FStepValue / 2)) / FStepValue) * FStepValue;
  }
  // Returns a parameter value given a slider value.
  inline EEL_F Slider2Param(EEL_F AValue)
  {
   return (AValue - FMinValue) / (FMaxValue - FMinValue);
  }
  // Returns a option index given a slider value. Returns -1 on error.
  inline int Slider2Option(EEL_F AValue)
  {  
    return std::min<int>(std::max<int>((int)((AValue - FMinValue) * (FOptions.size() - 1) / (FMaxValue - FMinValue)), 0), FOptions.size() - 1);
  }
  void GetDisplayFromSliderValue(char* AString, EEL_F AValue);

  void Init();
};

class CJes2CppMemory
{
public:

  CMemory FMemory;

  inline EEL_F& MEM(EEL_F ABase, EEL_F AOffset)
  {
    return FMemory[EEL_F2I(ABase + AOffset)];
  }
  // Extracts a string of bytes from array buffer.
  void GetMemory(std::string& ADst, int ASrc, int ALength)
  {
    ADst.resize(ALength);
    while (ALength-- > 0) {
      ADst[ALength] = EEL_F2I(FMemory[ASrc + ALength]);
    }
  }
};

class CJes2CppVeST : public CJes2CppMemory
{
public:

  HVEST FVeST;
  bool FUpdateDisplay;

  CJes2CppVeST()
  {
    FVeST = NULL;
    FUpdateDisplay = false;
  }
};

class CJes2CppSliders : public CJes2CppVeST
{
public:

#define JES2CPP_SLIDER_COUNT 128

  EEL_F FSliders[JES2CPP_SLIDER_COUNT];

  CJes2CppSliders()
  {
    memset(FSliders, 0, sizeof(FSliders));
  }
  virtual void DoSlider() { }
};

class CJes2CppSamples : public CJes2CppSliders
{
public:

#define JES2CPP_SAMPLE_COUNT 64

  EEL_F FSamples[JES2CPP_SAMPLE_COUNT];

  CJes2CppSamples()
  {
    memset(FSamples, 0, sizeof(FSamples));
  }
  virtual void DoBlock() { };
  virtual void DoSample() { };

  virtual void DoSample(float** AInputs, float** AOutputs, int ASampleFrames)
  {
    DoBlock();
    int LInputs = VeST_GetNumInputs(FVeST);
    for (int LSampleFrame = 0; LSampleFrame < ASampleFrames; LSampleFrame++) {
      for (int LChannel = LInputs; LChannel-- > 0;) {
        FSamples[LChannel] = AInputs[LChannel][LSampleFrame];
      }
      DoSample();
      for (int LChannel = LInputs; LChannel-- > 0;) {
        AOutputs[LChannel][LSampleFrame] = (float)FSamples[LChannel];
      }
    }
  }

  virtual void DoSample(double** AInputs, double** AOutputs, int ASampleFrames)
  {
    DoBlock();
    int LInputs = VeST_GetNumInputs(FVeST);
    for (int LSampleFrame = 0; LSampleFrame < ASampleFrames; LSampleFrame++) {
      for (int LChannel = LInputs; LChannel-- > 0;) {
        FSamples[LChannel] = AInputs[LChannel][LSampleFrame];
      }
      DoSample();
      for (int LChannel = LInputs; LChannel-- > 0;) {
        AOutputs[LChannel][LSampleFrame] = FSamples[LChannel];
      }
    }
  }
};

class CJes2CppDescription : public CJes2CppSamples
{
protected:

  std::vector<CJes2CppParameter> FParameters;
  std::string FEffectName, FProductString, FVendorString, FProgramName;
  int FVendorVersion, FUniqueId, FChannelCount;

public:

  CJes2CppDescription()
  {
    FChannelCount = FUniqueId = FVendorVersion = 0;
  }
  void GetEffectName(char* AString)
  {
    strcpy(AString, FEffectName.c_str());
  }
  void GetProductString(char* AString)
  {
    strcpy(AString, FProductString.c_str());
  }
  void GetVendorString(char* AString)
  {
    strcpy(AString, FVendorString.c_str());
  }
  void GetProgramName(char* AString)
  {
    strcpy(AString, FProgramName.c_str());
  }
  void SetProgramName(char* AString)
  {
    FProgramName = AString;
  }
  int GetVendorVersion()
  {
    return FVendorVersion;
  }
  int GetUniqueId()
  {
    return FUniqueId;
  }
  int GetChannelCount()
  {
    return FChannelCount;
  }
  int GetParameterCount()
  {
    return FParameters.size();
  }
  void SetParameterValue(int AIndex, EEL_F AValue)
  {
    AValue = FParameters[AIndex].Param2Slider(AValue);
    if (NEQ(AValue, FSliders[FParameters[AIndex].FIndex])) {
      FSliders[FParameters[AIndex].FIndex] = AValue;
      if (FParameters[AIndex].FVariable) {
        *FParameters[AIndex].FVariable = AValue;
      }
      DoSlider();
    }
  }
  EEL_F GetParameterValue(int AIndex)
  {
    return FParameters[AIndex].Slider2Param(FSliders[FParameters[AIndex].FIndex]);
  }
  void GetParameterName(int AIndex, char* AString)
  {
    strcpy(AString, FParameters[AIndex].FName.c_str());
  }
  void GetParameterLabel(int AIndex, char* AString)
  {
    strcpy(AString, FParameters[AIndex].FLabel.c_str());
  }
  void GetParameterDisplay(int AIndex, char* AString)
  {
    FParameters[AIndex].GetDisplayFromSliderValue(AString, FSliders[FParameters[AIndex].FIndex]);
  }
  int FindParameterBySliderIndex(int AIndex)
  {
    for (int LIndex = 0; LIndex < (int)FParameters.size(); LIndex++) {
      if (FParameters[LIndex].FIndex == AIndex) {
        return LIndex;
      }
    }
    return -1;
  }

  int AddParam(int AIndex, EEL_F* AVariable, EEL_F ADefValue, EEL_F AMinValue, EEL_F AMaxValue, EEL_F AStepValue,
               const std::string& AFilePath, const std::string& AFileName, const std::string& ALabel, const std::string& AText)
  {
    FSliders[AIndex] = ADefValue;
    FParameters.push_back(CJes2CppParameter(AIndex, AVariable, ADefValue, AMinValue, AMaxValue, AStepValue, AFilePath,
                                            AFileName,
                                            ALabel, AText));
    FParameters[FParameters.size() - 1].Init();
    return FParameters.size() - 1;
  }
};

// These constants were taken from WDL's "eel_strings.h".
// They are here mostly for reference.

#ifndef EEL_STRING_MAX_USER_STRINGS
// strings 0...x-1
#define EEL_STRING_MAX_USER_STRINGS 1024
#endif

#ifndef EEL_STRING_LITERAL_BASE
// strings defined by "xyz"
#define EEL_STRING_LITERAL_BASE 10000
#endif

// base for named mutable strings (#xyz)
#ifndef EEL_STRING_NAMED_BASE
#define EEL_STRING_NAMED_BASE  90000
#endif

// base for unnamed mutable strings (#)
#ifndef EEL_STRING_UNNAMED_BASE
#define EEL_STRING_UNNAMED_BASE  190000
#endif

#define STRING_FILENAME 90000

class CJes2CppStrings : public CJes2CppDescription
{
private:

  TStringMap FStringMap;
  int FStringLiteralBase;

public:

  EEL_F jes2cpp$str_count$;

  CJes2CppStrings()
  {
    FStringLiteralBase = EEL_STRING_LITERAL_BASE;
    ClearStrings();
  }
  void ClearStrings();

  void VPrintF(char* AString, const char* AFormat, va_list AArgs);

  inline std::string& GetString(int AKey)
  {
    std::string& LString = FStringMap.GetString(AKey);
    jes2cpp$str_count$ = (EEL_F)FStringMap.Count();
    return LString;
  }
  inline std::string& GetString(EEL_F AKey)
  {
    return GetString(EEL_F2I(AKey));
  }
  inline int SetString(int AKey, const std::string& AString)
  {
    GetString(AKey) = AString;
    return AKey;
  }
  inline EEL_F STR(const std::string& AString)
  {
    return SetString(FStringLiteralBase++, AString);
  }
  inline void SetFileName(int AKey, const std::string& AFileName)
  {
    SetString(AKey + STRING_FILENAME, AFileName);
  }
  inline std::string& GetFileName(int AKey)
  {
    return FStringMap.Exists(AKey + STRING_FILENAME) ? GetString(AKey + STRING_FILENAME) : GetString(AKey);
  }
  inline std::string& GetFileName(EEL_F AKey)
  {
    return GetFileName(EEL_F2I(AKey));
  }

  EEL_F strcpy_fromslider_(EEL_F AString, int ASlider);
  EEL_F strcpy_fromslider_(EEL_F AString, EEL_F& ASlider);
};

class CJes2CppStream
{
public:

  TSingleDynArray FBuffer;
  int FPosition;

  CJes2CppStream();

  void Rewind();
  void Clear();
  bool Write(EEL_F AValue);
  bool Read(EEL_F& AValue);
  int DataAvaliable();

  void ReadFromFile(FILE* AFile);
  bool LoadFromFileTxt(const std::string& AFileName);
  bool LoadFromFileBin(const std::string& AFileName);
  bool LoadFromFileSnd(const std::string& AFileName, int& AChannelCount, int& ASampleRate);

  bool SaveToFileBin(const std::string& AFileName);

  bool ReadString(std::string& AString);
};

#define FILE_CLOSED 0
#define FILE_READ 1
#define FILE_WRITE 2

#define FILE_HANDLE_SERIAL 0
#define FILE_HANDLE_SLIDER 10000

class CJes2CppFile
{
private:

  std::string FFileName;
  CJes2CppStream FStream;

public:

  bool FIsText;
  int FMode, FChannelCount, FSampleRate;

  CJes2CppFile();
  ~CJes2CppFile();

  void Close();
  bool OpenRead(const std::string& AFileName);
  void OpenWrite(const std::string& AFileName);
  void Rewind()
  {
    FStream.Rewind();
  }
  inline EEL_F ReadString(std::string& AString)
  {
    return FStream.ReadString(AString);
  }
  inline EEL_F DataAvaliable()
  {
    return FStream.DataAvaliable();
  }
  bool StreamValue(EEL_F& AValue);
  int StreamMemory(CMemory* AMemory, EEL_F AIndex, EEL_F ALength);
};

class CJes2CppFiles : public CJes2CppStrings
{
public:

  TDynMap<int, CJes2CppFile> FFiles;

  inline CJes2CppFile& GetFile(EEL_F AHandle)
  {
    return FFiles[EEL_F2I(AHandle)];
  }

  EEL_F file_open_(int AIndex);
  EEL_F file_open_(EEL_F& ASlider);
};

class CJes2CppFont
{
public:

  std::string FName;
  EEL_F FSize;
  int FStyle;

  CJes2CppFont()
  {
    FSize = M_ZERO;
    FStyle = 0;
  }
};

class CJes2CppFonts : public CJes2CppFiles
{
private:

  TDynMap<int, CJes2CppFont> FFonts;

public:

  EEL_F gfx_texth$;

  CJes2CppFonts()
  {
    gfx_texth$ = M_ZERO;
  }

  CJes2CppFont& GetFont(EEL_F AFont)
  {
    return FFonts[EEL_F2I(AFont)];
  }
  void SetFont(const std::string& AName, EEL_F ASize, int AStyle)
  {
    gfx_texth$ = ASize;
    // For some reason, VSTGUI doesn't output the same font sizes as REAPER
    ASize *= 0.85;
    if (!VeST_SetFont(FVeST, (char*)AName.c_str(), EEL_F2I(ASize), AStyle)) {
      VeST_SetFont(FVeST, (char*)"verdana", EEL_F2I(ASize), AStyle);
    }
  }
};

class CJes2CppImage
{
public:

  double FWidth, FHeight;
  HVEST_BITMAP FBitmap;

  CJes2CppImage();
  ~CJes2CppImage();

  void Clear();
  bool LoadFromFile(const std::string& AFileName);
};

class CJes2CppGraphics : public CJes2CppFonts
{
public:

  TDynMap<int, CJes2CppImage> FImages;
  EEL_F gfx_clear$, gfx_r$, gfx_g$, gfx_b$, gfx_a$, gfx_x$, gfx_y$, gfx_w$, gfx_h$, jes2cpp$gfx_rate$;

  CJes2CppGraphics();

  void DrawString(const char* AString);
  CJes2CppImage& GetImage(EEL_F AIndex);
};

class CJes2CppMouse : public CJes2CppGraphics
{
public:

  EEL_F mouse_cap$, mouse_x$, mouse_y$;

  CJes2CppMouse()
  {
    mouse_cap$ = mouse_x$ = mouse_y$ = 0;
  }
  void SetMouse(double AX, double AY, int AButtons)
  {
    mouse_cap$ = ((AButtons&2)>>1)|((AButtons&4)<<4)|((AButtons&8)>>1);
    mouse_x$ = AX;
    mouse_y$ = AY;
    jes2cpp$gfx_rate$ = std::max<EEL_F>(jes2cpp$gfx_rate$, GFX_RATE);
  }
};

class TJes2Cpp : public CJes2CppMouse
{
public:

  clock_t FClockUpdate, FClockInvalidate;
  EEL_F num_ch$, srate$, samplesblock$, pdc_delay$, pdc_top_ch$, pdc_bot_ch$, tempo$, ts_num$, ts_denom$, trigger$,
        beat_position$, play_state$;

  TJes2Cpp();
  virtual ~TJes2Cpp();

public:

  virtual void DoOpen();
  virtual void DoClose();
  virtual void DoSuspend();
  virtual void DoResume();
  virtual void DoInit();
  virtual void DoBlock();
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
while ((LLength >>= 1) > 0) {
  LResult++;
}
ALength = 1 << LResult;
return LResult;
}

inline bool ContainsByte(uint32_t AValue, uint8_t AByte)
{
return
  ((AValue >>  0) & 0xFF) == AByte ||
  ((AValue >>  8) & 0xFF) == AByte ||
  ((AValue >> 16) & 0xFF) == AByte ||
  ((AValue >> 24) & 0xFF) == AByte ;
}

#define DIR_FFT 0
#define DIR_IFFT 1
#define DIR_PERMUTE 4
#define DIR_IPERMUTE 5

extern void js_mdct(CMemory* AMemory, int AIndex, int ALength, bool AIsInverse);
extern void js_convolve_c(CMemory* AMemory, int ADst, int ASrc, int ALength);
extern void js_fft(CMemory* AMemory, int AIndex, int ALength, int ADir);

#endif

