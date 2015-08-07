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

#ifdef JES2CPP_BASS
#ifdef _WIN32
#include "bass/bass.h"
#else
#include "bass/bass.linux.h"
#endif // _WIN32
#endif // JES2CPP_BASS

// The sndfile api is great!, but somewhat large. Therefore, if you want
// a small release and load wav files, you should look into your own file loader.
#ifdef JES2CPP_SNDFILE
#ifdef _WIN32
#include "libsndfile/sndfile.h"
#else
#include <sndfile.h>
#endif // _WIN32
#endif // JES2CPP_SNDFILE

#ifdef EEL_F
#error EEL_F must be undefined. Jes2Cpp will define EEL_F based on WDL_FFT_REALSIZE.
#endif // EEL_F

#if WDL_FFT_REALSIZE == 4
#define EEL_F float
#elif WDL_FFT_REALSIZE == 8
#define EEL_F double
#else
#error WDL_FFT_REALSIZE must be defined as either 4 or 8.
#endif // WDL_FFT_REALSIZE

#ifndef EEL_I
#define EEL_I int32_t
#endif // EEL_I

#include "wdl/eel_fft.h"
#include "wdl/eel_mdct.h"

#ifndef JES2CPP_INLINE
#define JES2CPP_INLINE inline
#endif // JES2CPP_INLINE

#ifdef __cplusplus
#define JES2CPP_EXTERN extern "C"
#else
#define JES2CPP_EXTERN
#endif // __cplusplus

#ifdef _WIN32
#define JES2CPP_EXPORT JES2CPP_EXTERN __declspec(dllexport)
#else
#define JES2CPP_EXPORT JES2CPP_EXTERN __attribute__((visibility("default")))
#endif // _WIN32

#define EmptyStr ""

#define DirectorySeparatorDos "\\"
#define DirectorySeparatorUnix "/"

#ifdef _WIN32
#define DirectorySeparator DirectorySeparatorDos
#else
#define DirectorySeparator DirectorySeparatorUnix
#endif // _WIN32

#define ExtensionSeparator "."

class TStringMap
{
  private:

    std::map<int, std::string> FStrings;

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
    inline std::string* operator[](int AKey)
    {
      // No index checking required when accessing std::map.
      return &FStrings[AKey];
    }
};

template<class TYPE, int PAGEBITS> class TPagedArray
{
  private:

    std::map<int, std::vector<TYPE>> FPages;

  public:

    inline void Clear()
    {
      FPages.clear();
    }
    inline TYPE& operator[](int AIndex)
    {
      // No index checking required when accessing std::map.
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

extern void GetFileNames(std::string APath, std::vector<std::string>& AFileNames);
extern std::string GetModuleName(VEST_HANDLE AModule);
extern std::string ProgramDirectory();
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

#ifndef FPU_ERROR
#ifdef __GNUC__
#define FPU_ERROR(x) (isnan(x) || isinf(x))
#else
#define FPU_ERROR(x) (_isnan(x) || !_finite(x))
#endif
#endif // FPU_ERROR

// NOTE: These standard operators can now be overrided by macros which may provide
// a speed increase, but also may not be compatible with REAPER. Your choise.

// Expand safe operators to C++ operators

#ifndef OR
#define OR(AX, AY) (EEL_F)((int32_t)(AX) | (int32_t)(AY))
#endif // OR

#ifndef AND
#define AND(AX, AY) (EEL_F)((int32_t)(AX) & (int32_t)(AY))
#endif // AND

#ifndef XOR
#define XOR(AX, AY) (EEL_F)((int32_t)(AX) ^ (int32_t)(AY))
#endif // XOR

#ifndef SHL
#define SHL(AX, AY) (EEL_F)((int32_t)(AX) << (int32_t)(AY))
#endif // SHL

#ifndef SHR
#define SHR(AX, AY) (EEL_F)((int32_t)(AX) >> (int32_t)(AY))
#endif // SHR

// Unsafe operators are implemented as inline functions.

#ifndef VAL
inline EEL_F VAL(EEL_F AX)
{
return FPU_ERROR(AX) ? M_ZERO : AX;
}
#endif // VAL

#ifndef IF
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
#endif // IF

#ifndef NOT
inline EEL_F NOT(EEL_F AX)
{
return AX < M_EPSILON && AX > -M_EPSILON ? M_TRUE : M_FALSE;
}
#endif // NOT

#ifndef EQU
inline EEL_F EQU(EEL_F AX, EEL_F AY)
{
return AX -= AY, AX < M_EPSILON && AX > -M_EPSILON ? M_TRUE : M_FALSE;
}
#endif // EQU

#ifndef NEQ
inline EEL_F NEQ(EEL_F AX, EEL_F AY)
{
return AX -= AY, AX < M_EPSILON && AX > -M_EPSILON ? M_FALSE : M_TRUE;
}
#endif // NEQ

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
private:

  std::vector<std::string> FOptions;

public:

  bool FIsInitialized;
  int FSliderIndex;
  EEL_F* FVariable;
  EEL_F FDefValue, FMinValue, FMaxValue, FStepValue;
  std::string FFilePath, FFileName, FLabel, FName;

public:

  CJes2CppParameter(int ASliderIndex, EEL_F* AVariable, EEL_F ADefValue, EEL_F AMinValue, EEL_F AMaxValue,
                    EEL_F AStepValue,
                    const std::string& AFilePath, const std::string& AFileName, const std::string& ALabel,
                    const std::string& AName)
  {
    FIsInitialized = false;
    FSliderIndex = ASliderIndex;
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
  // Returns true if given a valid option index.
  inline bool IsOptionIndex(int AOptionIndex)
  {
    return AOptionIndex >= 0 && AOptionIndex < (int)FOptions.size();
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
  inline int Slider2OptionIndex(EEL_F AValue)
  {
    return std::min<int>(std::max<int>((int)((AValue - FMinValue) * (FOptions.size() - 1) / (FMaxValue - FMinValue)), 0),
                         FOptions.size() - 1);
  }
  // Returns a string value for slider. This may be the selected option (if valid), or
  // a display string of the slider value.
  void GetDisplayFromSliderValue(char* AString, EEL_F AValue)
  {
    int LOptionIndex = Slider2OptionIndex(AValue);
    if (IsOptionIndex(LOptionIndex)) {
      strcpy(AString, FOptions[LOptionIndex].c_str());
    } else {
      sprintf(AString, "%.2f", AValue);
    }
  }
  void AddOption(const std::string& AString)
  {
    FOptions.push_back(AString);
  }
  // Initialize parameter. If the parameter is a file path, then the options are filled with
  // the filenames found at the path.
  void Init()
  {
    if (!FIsInitialized) {
      FIsInitialized = true;
      if (FFilePath.length() > 0) {
        GetFileNames(FileNameResolve(FFilePath), FOptions);
        if (FOptions.size() == 0) {
          AddOption("(No Data Files)");
        }
        FMinValue = 0;
        FMaxValue = (EEL_F)(FOptions.size() - 1);
        FDefValue = 0;
        FStepValue = 0.5;
      }
    }
  }
};

class CJes2CppMemory
{
protected:

  CMemory FMemory;

public:

  // Return a reference to memory value given a base and offset.
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
protected:

  bool FUpdateDisplay;

public:

  HVEST FVeST;

  CJes2CppVeST() : FVeST(nullptr), FUpdateDisplay(false) { }
};

class CJes2CppSliders : public CJes2CppVeST
{
public:

#define JES2CPP_SLIDER_COUNT 128

  std::vector<EEL_F> FSliders;

  CJes2CppSliders() : FSliders(JES2CPP_SLIDER_COUNT) { }

  // Returns true if given a valid slider index.
  inline bool IsSliderIndex(int ASliderIndex)
  {
    return ASliderIndex >= 1 && ASliderIndex < (int)FSliders.size();
  }
  // Returns a slider index given a pointer to a slider variable. Returns -1 on error.
  inline int GetSliderIndex(EEL_F* ASlider)
  {
    int LSliderIndex = ASlider - &FSliders[0];
    return IsSliderIndex(LSliderIndex) ? LSliderIndex : -1;
  }
  // Called when a slider is changed.
  virtual void DoSlider() { }
};

class CJes2CppSamples : public CJes2CppSliders
{
public:

#define JES2CPP_SAMPLE_COUNT 64

  std::vector<EEL_F> FSamples;

  CJes2CppSamples() : FSamples(JES2CPP_SAMPLE_COUNT) { }

  virtual void DoBlock() { };
  virtual void DoSample() { };

  // Process a block of samples. Handles both float and doubles.
  template<class FLOAT_TYPE> inline void DoProcess(FLOAT_TYPE** AInputs, FLOAT_TYPE** AOutputs, int ASampleFrames)
  {
    // We should only need to get this value once, so make it static.
    static int LNumInputs = VeST_GetNumInputs(FVeST);
    DoBlock();
    // Optimized 2 channel process. Doesn't do much for complex effects, since the
    // bottle neck is not the sample transfer.
    if (LNumInputs == 2) {
      FLOAT_TYPE* LSrc0 = AInputs[0];
      FLOAT_TYPE* LSrc1 = AInputs[1];
      FLOAT_TYPE* LDst0 = AOutputs[0];
      FLOAT_TYPE* LDst1 = AOutputs[1];
      for (int LFrame = ASampleFrames; LFrame-- > 0; ) {
        FSamples[0] = *LSrc0++;
        FSamples[1] = *LSrc1++;
        DoSample();
        *LDst0++ = FSamples[0];
        *LDst1++ = FSamples[1];
      }
    } else {
      for (int LSampleFrame = 0; LSampleFrame < ASampleFrames; LSampleFrame++) {
        for (int LChannel = LNumInputs; LChannel-- > 0;) {
          FSamples[LChannel] = AInputs[LChannel][LSampleFrame];
        }
        DoSample();
        for (int LChannel = LNumInputs; LChannel-- > 0;) {
          AOutputs[LChannel][LSampleFrame] = (FLOAT_TYPE)FSamples[LChannel];
        }
      }
    }
  }
  /*
  inline void DoProcess(float** AInputs, float** AOutputs, int ASampleFrames)
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
  inline void DoProcess(double** AInputs, double** AOutputs, int ASampleFrames)
  {
    DoBlock();
    int LInputs = VeST_GetNumInputs(FVeST);
    for (int LSampleFrame = 0; LSampleFrame < ASampleFrames; LSampleFrame++) {
      for (int LChannel = LInputs; LChannel-- > 0;) {
        FSamples[LChannel] = AInputs[LChannel][LSampleFrame];
      }
      DoSample();
      for (int LChannel = LInputs; LChannel-- > 0;) {
        AOutputs[LChannel][LSampleFrame] = (double)FSamples[LChannel];
      }
    }
  }
  */
};

class CJes2CppDescription : public CJes2CppSamples
{
protected:

  std::vector<CJes2CppParameter> FParameters;
  std::string FEffectName, FProductString, FVendorString, FProgramName;
  int FVendorVersion, FUniqueId, FChannelCount;

public:

  CJes2CppDescription() : FChannelCount(0), FUniqueId(0), FVendorVersion(0) { }

  // Gets the effect name.
  void GetEffectName(char* AString)
  {
    strcpy(AString, FEffectName.c_str());
  }
  // Gets the product string.
  void GetProductString(char* AString)
  {
    strcpy(AString, FProductString.c_str());
  }
  // Gets the vendor string.
  void GetVendorString(char* AString)
  {
    strcpy(AString, FVendorString.c_str());
  }
  // Gets the current program name. (Only used for description display)
  void GetProgramName(char* AString)
  {
    strcpy(AString, FProgramName.c_str());
  }
  // Sets the current program name. (Only used for description display)
  void SetProgramName(char* AString)
  {
    FProgramName = AString;
  }
  // Returns the vendor version.
  int GetVendorVersion()
  {
    return FVendorVersion;
  }
  // Returns the unique id of this effect.
  int GetUniqueId()
  {
    return FUniqueId;
  }
  // Returns the number of channels.
  int GetChannelCount()
  {
    return FChannelCount;
  }
  // Returns the number of parameters.
  int GetParameterCount()
  {
    return FParameters.size();
  }
  // Sets the value of a parameter, given a param index and value.
  void SetParameterValue(int AParamIndex, EEL_F AValue)
  {
    AValue = FParameters[AParamIndex].Param2Slider(AValue);
    if (NEQ(AValue, FSliders[FParameters[AParamIndex].FSliderIndex])) {
      FSliders[FParameters[AParamIndex].FSliderIndex] = AValue;
      if (FParameters[AParamIndex].FVariable) {
        *FParameters[AParamIndex].FVariable = AValue;
      }
      DoSlider();
    }
  }
  // Returns the value of a parameter given a param index.
  EEL_F GetParameterValue(int AParamIndex)
  {
    return FParameters[AParamIndex].Slider2Param(FSliders[FParameters[AParamIndex].FSliderIndex]);
  }
  // Returns the name of a parameter given a param index.
  void GetParameterName(int AParamIndex, char* AString)
  {
    strcpy(AString, FParameters[AParamIndex].FName.c_str());
  }
  // Returns the label of a parameter given a param index.
  void GetParameterLabel(int AParamIndex, char* AString)
  {
    strcpy(AString, FParameters[AParamIndex].FLabel.c_str());
  }
  // Returns the display string of a parameter given a param index.
  void GetParameterDisplay(int AParamIndex, char* AString)
  {
    FParameters[AParamIndex].GetDisplayFromSliderValue(AString, FSliders[FParameters[AParamIndex].FSliderIndex]);
  }
  // Returns a parameter index given a slider index. Returns -1 on error.
  int FindParameterBySliderIndex(int ASliderIndex)
  {
    for (int LIndex = FParameters.size(); LIndex-- > 0;) {
      if (FParameters[LIndex].FSliderIndex == ASliderIndex) {
        return LIndex;
      }
    }
    return -1;
  }
  // Adds a new parameter to the parameter list. Initializes the parameters options (if required).
  int AddParam(int ASliderIndex, EEL_F* AVariable, EEL_F ADefValue, EEL_F AMinValue, EEL_F AMaxValue, EEL_F AStepValue,
               const std::string& AFilePath, const std::string& AFileName, const std::string& ALabel, const std::string& AText)
  {
    FSliders[ASliderIndex] = ADefValue;
    FParameters.push_back(CJes2CppParameter(ASliderIndex, AVariable, ADefValue, AMinValue, AMaxValue, AStepValue, AFilePath,
                                            AFileName,
                                            ALabel, AText));
    FParameters[FParameters.size() - 1].Init();
    return FParameters.size() - 1;
  }
};

class CJes2CppStrings : public CJes2CppDescription
{
private:

  TStringMap FStringMap, FFileNames;

public:

  EEL_F jes2cpp$str_count$;

  CJes2CppStrings() : jes2cpp$str_count$(0)
  {
    ClearStrings();
  }
  void ClearStrings()
  {
    FStringMap.Clear();
    jes2cpp$str_count$ = (EEL_F)FStringMap.Count();
  }
  void VPrintF(char* AString, const char* AFormat, va_list AArgs)
  {
    while (*AFormat) {
      if (*AFormat == '%') {
        char LChar, LBuffer[256];
        char* LFormat = LBuffer;
        do {
          LChar = *LFormat++ = *AFormat++;
        } while (LChar && !isalpha(LChar));
        *LFormat = 0;
        switch (LChar) {
        case 'e':
        case 'E':
        case 'f':
        case 'g':
        case 'G':
          sprintf(AString, LBuffer, va_arg(AArgs, double));
          AString = strchr(AString, 0);
          break;
        case 'c':
        case 'd':
        case 'i':
        case 'o':
        case 'x':
        case 'X':
          sprintf(AString, LBuffer, EEL_F2I(va_arg(AArgs, double)));
          AString = strchr(AString, 0);
          break;
        case 's':
          sprintf(AString, LBuffer, GetString((EEL_F)va_arg(AArgs, double))->c_str());
          AString = strchr(AString, 0);
          break;
        }
      } else {
        *AString++ = *AFormat++;
      }
    }
    *AString = 0;
  }
  // Returns a string pointer given a string index.
  inline std::string* GetString(int AStringIndex)
  {
    std::string* LString = FStringMap[AStringIndex];
    jes2cpp$str_count$ = (EEL_F)FStringMap.Count();
    return LString;
  }
  // Same as above, but for a float indexes.
  inline std::string* GetString(EEL_F AStringIndex)
  {
    return GetString(EEL_F2I(AStringIndex));
  }
  // Sets a string given a string index and a string value.
  inline int SetString(int AStringIndex, const std::string& AString)
  {
    *GetString(AStringIndex) = AString;
    return AStringIndex;
  }
  // Sets a filename string given a filename index and string value.
  inline void SetFileName(int AFileNameIndex, const std::string& AFileName)
  {
    *FFileNames[AFileNameIndex] = AFileName;
  }
  // Returns true if given a valid filename index.
  inline bool IsFileNameIndex(int AFileNameIndex)
  {
    return FFileNames.Exists(AFileNameIndex);
  }
  // Returns a string pointer given a filename index. If no filename is defined, then return
  // a standard string from the index.
  inline std::string* GetFileName(int AFileNameIndex)
  {
    return IsFileNameIndex(AFileNameIndex) ? FFileNames[AFileNameIndex] : GetString(AFileNameIndex);
  }
  // Same as above, but for a float indexes.
  inline std::string* GetFileName(EEL_F AFileNameIndex)
  {
    return GetFileName(EEL_F2I(AFileNameIndex));
  }
  // Copies a sliders display string given a slider index. Returns an empty string on error.
  EEL_F strcpy_fromslider_(EEL_F AString, int ASliderIndex)
  {
    int LIndex = FindParameterBySliderIndex(ASliderIndex);
    if (LIndex < 0) {
      *GetString(AString) = EmptyStr;
    } else {
      char LString[FILENAME_MAX];
      FParameters[LIndex].GetDisplayFromSliderValue(LString, FSliders[ASliderIndex]);
      *GetString(AString) = LString;
    }
    return AString;
  }
  // Copies a sliders display string given a slider reference. If a non-slider is given (eg: a global variable)
  // then use the variables integer value as a slider index.
  EEL_F strcpy_fromslider_(EEL_F AString, EEL_F& ASliderOrSliderIndex)
  {
    int LSliderIndex = GetSliderIndex(&ASliderOrSliderIndex);
    return LSliderIndex < 0 ? strcpy_fromslider_(AString, EEL_F2I(ASliderOrSliderIndex)) : strcpy_fromslider_(AString,
           LSliderIndex);
  }
};

// Use floats for streaming because bass only outputs floats.
// WARNING! My WAVPACK loader wasn't written well, and requires stream element size = 32bit.
#define STREAM_F float

// Stream checks. These values are used to ident a block of stream values.
#define STREAM_IDENT_USER (-1000)
#define STREAM_IDENT_STRING (-1001)
#define STREAM_IDENT_SLIDERS (-1002)

class CJes2CppStream
{
private:

  int FPosition;
  std::vector<STREAM_F> FBuffer;

public:

  CJes2CppStream() : FPosition(0) {}

  // Rewinds stream position to the start.
  void Rewind()
  {
    FPosition = 0;
  }
  // Clears stream buffer and rewinds.
  void Clear()
  {
    FBuffer.clear();
    Rewind();
  }
  // Returns a pointer to streams internal vector buffer.
  std::vector<STREAM_F>* GetBuffer()
  {
    return &FBuffer;
  }
  // Returns the number of values (not bytes) avaliable.
  inline int DataAvaliable()
  {
    return FBuffer.size() - FPosition;
  }
  inline int GetByteSize()
  {
    return FBuffer.size() * sizeof(STREAM_F);
  }
  // Writes a value into stream buffer. Increases stream buffer if required.
  // Increments stream position. Always returns true.
  bool Write(EEL_F AValue)
  {
    FBuffer.resize(std::max<int>(FBuffer.size(), FPosition + 1));
    FBuffer[FPosition++] = (STREAM_F)AValue;
    return true;
  }
  // Reads a value from the current position and increments. Returns false on error (eg: end of stream).
  bool Read(EEL_F& AValue)
  {
    if (FPosition >= (int)FBuffer.size()) {
      return false;
    }
    AValue = FBuffer[FPosition++];
    return true;
  }
  // Reads a single string from the stream buffer. Increments the stream position.
  // Returns false on error (eg: end of stream).
  bool ReadString(std::string& AString, bool AIsSystem)
  {
    AString.clear();
    if (DataAvaliable() <= 0) {
      return false;
    }
    EEL_F LValue;
    if (AIsSystem) {
      if (!Read(LValue) || LValue != STREAM_IDENT_STRING || !Read(LValue)) {
        return false;
      }
      AString.resize(EEL_F2I(LValue));
      for (int LIndex = 0; LIndex < (int)AString.size(); LIndex ++) {
        if (!Read(LValue)) {
          AString.clear();
          return false;
        }
        AString[LIndex] = EEL_F2I(LValue);
      }
    } else {
      while (Read(LValue)) {
        char LChar = EEL_F2I(LValue);
        if (LChar == '\n') {
          break;
        }
        AString += LChar;
      }
    }
    return true;
  }
  // Writes a sting to the stream buffer. Increments the stream position.
  // Returns false on error. (Which should not happen)
  bool WriteString(const std::string& AString, bool AIsSystem)
  {
    if (AIsSystem) {
      Write(STREAM_IDENT_STRING);
      Write(AString.size());
    }
    for (int LIndex = 0; LIndex < (int)AString.length(); LIndex++) {
      Write(AString[LIndex]);
    }
    if (!AIsSystem) {
      Write('\n');
    }
    return true;
  }
  // Writes each byte of a file into the stream until end of file.
  void ReadFromFile(FILE* AFile)
  {
    while (!feof(AFile)) {
      Write((EEL_F)fgetc(AFile));
    }
  }
  // Clears the stream buffer, and loads a text file. Returns false on error.
  // Rewinds stream position.
  bool LoadFromFileTxt(const std::string& AFileName)
  {
    Clear();
    FILE* LFile = fopen(AFileName.c_str(), "rt");
    if (LFile == nullptr) {
      return false;
    }
    ReadFromFile(LFile);
    fclose(LFile);
    Rewind();
    return true;
  }
  // Clears the stream buffer, and loads a binary file. Returns false on error.
  // Rewinds stream position.
  bool LoadFromFileBin(const std::string& AFileName)
  {
    Clear();
    FILE* LFile = fopen(AFileName.c_str(), "rb");
    if (LFile == nullptr) {
      return false;
    }
    ReadFromFile(LFile);
    fclose(LFile);
    Rewind();
    return true;
  }
  // Clears the stream buffer, and loads a sound/audio file. Returns false on error.
  // Stream position is set to start of buffer.
  bool LoadFromFileSnd(const std::string& AFileName, int& AChannelCount, int& ASampleRate)
  {
    Clear();
#ifdef SNDFILE_H
    SF_INFO LInfo;
    SNDFILE* LFile = sf_open(AFileName.c_str(), SFM_READ, &LInfo);
    if (LFile) {
      AChannelCount = LInfo.channels;
      ASampleRate = LInfo.samplerate;
      FBuffer.resize((unsigned)(LInfo.frames * LInfo.channels));
      sf_read_float(LFile, &FBuffer[0], FBuffer.size());
      sf_close(LFile);
      return true;
    }
#endif
#ifdef BASS_H
    HCHANNEL LChannel = BASS_StreamCreateFile(false, AFileName.c_str(), 0, 0,
                        BASS_SAMPLE_FLOAT | BASS_STREAM_DECODE | BASS_STREAM_PRESCAN);
    if (LChannel) {
      BASS_CHANNELINFO LInfo;
      if (BASS_ChannelGetInfo(LChannel, &LInfo)) {
        AChannelCount = LInfo.chans;
        ASampleRate = LInfo.freq;
        FBuffer.resize(BASS_ChannelGetLength(LChannel, BASS_POS_BYTE) + (sizeof(STREAM_F) - 1) / sizeof(STREAM_F));
        BASS_ChannelGetData(LChannel, &FBuffer[0], FBuffer.size() * sizeof(STREAM_F));
      }
      BASS_StreamFree(LChannel);
      return FBuffer.size() > 0;
    }
    /*
    // Old BASS loading code. This method doesn't work if sound driver is not avaliable.

    HSAMPLE LSample = BASS_SampleLoad(false, AFileName.c_str(), 0, 0, 1, BASS_SAMPLE_FLOAT);
    if (LSample) {
      BASS_SAMPLE LInfo;
      if (BASS_SampleGetInfo(LSample, &LInfo)) {
        AChannelCount = LInfo.chans;
        ASampleRate = LInfo.freq;
        FBuffer.resize((LInfo.length + (sizeof(STREAM_F) - 1)) / sizeof(STREAM_F));
        BASS_SampleGetData(LSample, &FBuffer[0]);
      }
      BASS_SampleFree(LSample);
      return FBuffer.size() > 0;
    }
    */
#endif
#ifdef WAVPACK_H
    char LError[100];
    GeepError("Loading: " + AFileName);
    WavpackContext* LContext = WavpackOpenFileInput(AFileName.c_str(), LError, 0, 0);
    if (LContext) {
      AChannelCount = WavpackGetNumChannels(LContext);
      ASampleRate = WavpackGetSampleRate(LContext);
      int LNumSamples = WavpackGetNumSamples(LContext);
      FBuffer.resize(LNumSamples * AChannelCount);
      WavpackUnpackSamples(LContext, (int32_t*)&FBuffer[0], LNumSamples);
      if ((WavpackGetMode(LContext) & MODE_FLOAT) == 0) {
        for (int LIndex = 0; LIndex < (int)FBuffer.size(); LIndex++) {
          FBuffer[LIndex] = *((int32_t*)&FBuffer[LIndex]) / (STREAM_F)INT16_MAX;
        }
      }
      WavpackCloseFile(LContext);
      return FBuffer.size() > 0;
    }
#endif
    if (VeST_LoadWavFromFile(FBuffer, AFileName, AChannelCount, ASampleRate)) {
      return true;
    }
    GeepError("Unable to load: " + AFileName);
    return false;
  }
  // Saves entire stream buffer to a binary file. Returns false on error.
  // Does not change the stream position.
  bool SaveToFileBin(const std::string& AFileName)
  {
    FILE* LFile = fopen(AFileName.c_str(), "wb");
    if (LFile == nullptr) {
      return false;
    }
    for (int LIndex = 0; LIndex < (int)FBuffer.size(); LIndex++) {
      fputc(EEL_F2I(FBuffer[LIndex]), LFile);
    }
    fclose(LFile);
    return true;
  }
  // Resize stream and fill with size (bytes) of data.
  void LoadFromChunk(void* AData, int AByteSize)
  {
    FBuffer.resize(AByteSize / sizeof(STREAM_F));
    memcpy(&FBuffer[0], AData, GetByteSize());
  }
  // Returns a point to the start of the stream memory.
  void* GetStreamMemory()
  {
    return &FBuffer[0];
  }
};

typedef enum {fmClosed, fmRead, fmWrite} TFileMode;

class CJes2CppFile
{
private:

  std::string FFileName;
  CJes2CppStream FStream;

public:

  bool FIsText, FIsSystem;
  TFileMode FMode;
  int FChannelCount, FSampleRate;

  CJes2CppFile() : FIsText(false), FIsSystem(false), FChannelCount(0), FSampleRate(0), FMode(fmClosed) { }

  ~CJes2CppFile()
  {
    Close();
  }
  // Closes the file. If file was in write mode, and was given a filename, then
  // write the stream buffer out to a file.
  void Close()
  {
    if (FMode == fmWrite && FFileName.length() > 0) {
      FStream.SaveToFileBin(FileNameResolve(FFileName).c_str());
    }
    FFileName.clear();
    FStream.Clear();
    FChannelCount = FSampleRate = 0;
    FMode = fmClosed;
    FIsText = false;
  }
  // Closes the file, then opens file for reading.
  void OpenRead()
  {
    Close();
    FMode = fmRead;
  }
  // Closes the file, then opens file for reading.
  // Fills the stream buffer with a block of memory.
  bool OpenRead(void* AData, int AByteSize)
  {
    OpenRead();
    FStream.LoadFromChunk(AData, AByteSize);
    // TODO: Return true for now. We should check the size of the buffer to prevent
    // a large chunk of data being read from the host.
    return true;
  }
  // Closes the file, then opens file for reading given a filename. Returns false on error.
  bool OpenRead(const std::string& AFileName)
  {
    Close();
    std::string LFileExt = ExtractFileExt(AFileName);
    if ((SameText(LFileExt, ".wav") || SameText(LFileExt, ".mp1") || SameText(LFileExt, ".mp2")
         || SameText(LFileExt, ".mp3") || SameText(LFileExt, ".ogg") || SameText(LFileExt, ".aiif"))
        && FStream.LoadFromFileSnd(FileNameResolve(AFileName), FChannelCount, FSampleRate)) {
      FMode = fmRead;
      return true;
    }
    if (SameText(LFileExt, ".txt") && FStream.LoadFromFileTxt(FileNameResolve(AFileName))) {
      FIsText = true;
      FMode = fmRead;
      return true;
    }
    if (FStream.LoadFromFileBin(FileNameResolve(AFileName))) {
      FMode = fmRead;
      return true;
    }
    return false;
  }
  // Closes the file, then opens file for writing.
  void OpenWrite()
  {
    Close();
    FMode = fmWrite;
  }
  // Closes the file, then opens file for writing given a filename.
  // Note, files are written out when closed, so, there is no error returned here.
  void OpenWrite(const std::string& AFileName)
  {
    OpenWrite();
    FFileName = AFileName;
  }
  // Rewinds the file stream.
  void Rewind()
  {
    FStream.Rewind();
  }
  // Returns the number of stream values avaliable. (Not bytes)
  EEL_F DataAvaliable()
  {
    return FStream.DataAvaliable();
  }
  // Returns the size of stream in bytes.
  int GetByteSize()
  {
    return FStream.GetByteSize();
  }
  // Writes a value to stream. Always returns true.
  bool Write(EEL_F AValue)
  {
    return FStream.Write(AValue);
  }
  // Reads a value from stream. Returns false on error.
  bool Read(EEL_F& AValue)
  {
    return FStream.Read(AValue);
  }
  // Streams a value to or from the file stream based on the file mode. Returns false on error.
  bool StreamValue(EEL_F& AValue)
  {
    return FMode == fmWrite ? Write(AValue) : FMode == fmRead ? Read(AValue) : false;
  }
  bool StreamString(std::string& AString)
  {
    return FMode == fmWrite ? FStream.WriteString(AString, FIsSystem) : FMode == fmRead  ? FStream.ReadString(AString,
           FIsSystem) : false;
  }
  // Streams memory values to or from the file stream based on file mode. Returns number of
  // values written or read.
  int StreamMemory(CMemory* AMemory, EEL_F AIndex, EEL_F ALength)
  {
    if (FMode == fmClosed) {
      return 0;
    }
    int LCount = 0, LIndex = EEL_F2I(AIndex), LLength = EEL_F2I(ALength);
    if (FMode == fmRead) {
      LLength = std::min<int>(LLength, FStream.DataAvaliable());
    }
    for (; LLength-- > 0; LCount++) {
      StreamValue((*AMemory)[LIndex++]);
    }
    return LCount;
  }
  void* GetStreamMemory()
  {
    return FStream.GetStreamMemory();
  }
};

// This is the file index for the serialization file.
#define FILE_HANDLE_SERIAL 0

class CJes2CppFiles : public CJes2CppStrings
{
private:

  std::vector<CJes2CppFile> FFiles;

  // Finds a unused/closed file. Create a new file if non found.
  CJes2CppFile* GetNewFile()
  {
    for (int LIndex = 1; LIndex < (int)FFiles.size(); LIndex++) {
      if (FFiles[LIndex].FMode == fmClosed) {
        return &FFiles[LIndex];
      }
    }
    FFiles.resize(FFiles.size() + 1);
    jes2cpp$file_count$ = FFiles.size();
    return &FFiles[FFiles.size() - 1];
  }

public:

  EEL_F jes2cpp$file_count$;

  // Create files. FFiles[0] is the default system file.
  CJes2CppFiles() : FFiles(1), jes2cpp$file_count$(1)
  {
    FFiles[0].FIsSystem = true;
  }

  // Returns true if given a valid file index.
  inline bool IsFileIndex(int AFileIndex)
  {
    return AFileIndex >= 0 && AFileIndex < (int)FFiles.size();
  }
  // Returns a file pointer given a file index. Returns system file on error.
  inline CJes2CppFile* GetFile(int AFileIndex)
  {
    return IsFileIndex(AFileIndex) ? &FFiles[AFileIndex] : &FFiles[FILE_HANDLE_SERIAL];
  }
  // Same as above, but for a float indexes.
  inline CJes2CppFile* GetFile(EEL_F AFileIndex)
  {
    return GetFile(EEL_F2I(AFileIndex));
  }
  // Returns the file index for the given file. Returns -1 on error.
  inline int GetFileIndex(CJes2CppFile* AFile)
  {
    int LFileIndex = AFile - &FFiles[0];
    return IsFileIndex(LFileIndex) ? LFileIndex : -1;
  }
  // Opens a new file given a filename index. Here we use GetNewFile, which recycles closed
  // files. Returns file index or -1 on error.
  EEL_F file_open_(int AFileNameIndex)
  {
    CJes2CppFile* LFile = GetNewFile();
    return LFile->OpenRead(*GetFileName(AFileNameIndex)) ? (EEL_F)GetFileIndex(LFile) : M_ERROR;
  }
  // Opens a new file given a slider value. If slider is not valid, then the value of the variable
  // is used as a filename index, and sent to the function above.
  EEL_F file_open_(EEL_F& ASliderOrFileNameIndex)
  {
    int LSliderIndex = GetSliderIndex(&ASliderOrFileNameIndex);
    if (LSliderIndex < 0) {
      return file_open_(EEL_F2I(ASliderOrFileNameIndex));
    }
    CJes2CppFile* LFile = GetNewFile();
    int LParamIndex = FindParameterBySliderIndex(LSliderIndex);
    if (LParamIndex >= 0) {
      char LFileName[FILENAME_MAX];
      FParameters[LParamIndex].GetDisplayFromSliderValue(LFileName, FSliders[FParameters[LParamIndex].FSliderIndex]);
      return LFile->OpenRead(FParameters[LParamIndex].FFilePath + LFileName) ? (EEL_F)GetFileIndex(LFile) : M_ERROR;
    }
    return M_ERROR;
  }
};

class CJes2CppFont
{
public:

  std::string FName;
  EEL_F FSize;
  int FStyle;

  CJes2CppFont() : FSize(0), FStyle(0) { }
};

class CJes2CppFonts : public CJes2CppFiles
{
private:

  std::map<int, CJes2CppFont> FFonts;

public:

  EEL_F gfx_texth$;

  CJes2CppFonts() : gfx_texth$(0) { }

  // Returns a font pointer given a font index.
  inline CJes2CppFont* GetFont(int AFontIndex)
  {
    // No index checking required when accessing std::map.
    return &FFonts[AFontIndex];
  }
  // Same as above, but for a float indexes.
  inline CJes2CppFont* GetFont(EEL_F AFontIndex)
  {
    return GetFont(EEL_F2I(AFontIndex));
  }
  // Sets the current font to name, size and VST style.
  void SetFont(const std::string& AName, EEL_F ASize, int AStyle)
  {
    if (!VeST_SetFont(FVeST, (char*)AName.c_str(), EEL_F2I(ASize), AStyle)) {
      VeST_SetFont(FVeST, (char*)"verdana", EEL_F2I(ASize), AStyle);
    }
  }
};

class CJes2CppImage
{
public:

  HVEST_BITMAP FBitmap;
  double FWidth, FHeight;

  CJes2CppImage() : FBitmap(nullptr), FWidth(0), FHeight(0) { }

  ~CJes2CppImage()
  {
    Clear();
  }
  // Clears/frees the image bitmap. Sets width and height to 0.
  void Clear()
  {
    if (FBitmap) {
      VeST_BitmapFree(FBitmap);
      FBitmap = nullptr;
    }
    FWidth = FHeight = 0;
  }
  // Clears the bitmap and loads a bitmap given a filename. Returns false on error.
  bool LoadFromFile(const std::string& AFileName)
  {
    Clear();
    FBitmap = VeST_BitmapCreate();
    if (VeST_BitmapLoadFromFile(FBitmap, (char*)FileNameResolve(AFileName).c_str())) {
      FWidth = VeST_BitmapGetWidth(FBitmap);
      FHeight = VeST_BitmapGetHeight(FBitmap);
      return true;
    } else {
      GeepError("Unable to load: " + FileNameResolve(AFileName));
    }
    return false;
  }
};

class CJes2CppGraphics : public CJes2CppFonts
{
private:

  std::map<int, CJes2CppImage> FImages;

public:

  EEL_F gfx_clear$, gfx_r$, gfx_g$, gfx_b$, gfx_a$, gfx_x$, gfx_y$, gfx_w$, gfx_h$, jes2cpp$gfx_rate$;

  CJes2CppGraphics() : jes2cpp$gfx_rate$(0), gfx_clear$(0), gfx_r$(0), gfx_g$(0), gfx_b$(0), gfx_a$(0), gfx_x$(0),
    gfx_y$(0), gfx_w$(0),
    gfx_h$(0) { }

  // Draws a string to the current graphics (x, y) and using the current font/color setup.
  // Split the string into lines if newlines are found.
  void DrawString(const std::string AString)
  {
    VeST_SetFontColor(FVeST, EEL_F2PEN(gfx_r$), EEL_F2PEN(gfx_g$), EEL_F2PEN(gfx_b$), EEL_F2PEN(gfx_a$));
    int LPos = 0;
    while (true) {
      int LEnd = AString.find('\n', LPos);
      if (LEnd < 0) {
        LEnd = AString.length();
      }
      std::string LLine = AString.substr(LPos, LEnd - LPos);
      VEST_F LWidth = VeST_GetStringWidth(FVeST, LLine.c_str());
      // NOTE: We add 2 pixels to the rectangle height to fix a text alignment issue.
      VeST_DrawString(FVeST, LLine.c_str(), gfx_x$, gfx_y$, gfx_x$ + LWidth, gfx_y$ + gfx_texth$ + 2, false, 0);
      if (LEnd < (int)AString.length()) {
        gfx_y$ += gfx_texth$;
      } else {
        gfx_x$ += LWidth;
        break;
      }
      LPos = LEnd + 1;
    }
  }
  // Returns a image given a image index. If image index also maps to a valid filename index, then
  // the image will be loaded from the filename index.
  CJes2CppImage* GetImage(int AImageIndexOrFileNameIndex)
  {
    // No index checking required when accessing std::map.
    if (!FImages[AImageIndexOrFileNameIndex].FBitmap && IsFileNameIndex(AImageIndexOrFileNameIndex)) {
      FImages[AImageIndexOrFileNameIndex].LoadFromFile(*GetFileName(AImageIndexOrFileNameIndex));
    }
    // No index checking required when accessing std::map.
    return &FImages[AImageIndexOrFileNameIndex];
  }
  // Same as above, but for a float indexes.
  CJes2CppImage* GetImage(EEL_F AImageIndexOrFileNameIndex)
  {
    return GetImage(EEL_F2I(AImageIndexOrFileNameIndex));
  }
};

class CJes2CppMouse : public CJes2CppGraphics
{
public:

  // NOTE: We now store mouse status in the jes2cpp namespace. These values are then copied over
  // to the standard variables in "jes2cpp.jsfx-inc". This is done so, if a program changes
  // the values, they are reset in the next @gfx event.
  EEL_F jes2cpp$mouse_cap$, jes2cpp$mouse_x$, jes2cpp$mouse_y$;

  CJes2CppMouse() : jes2cpp$mouse_cap$(0), jes2cpp$mouse_x$(0),  jes2cpp$mouse_y$(0) { }

  // Sets the global mouse variables. The buttons are VST encoded, so they need to be
  // recoded to Jesusonic.
  void DoMouseMoved(VEST_F AX, VEST_F AY, int AButtons)
  {
    // Mouse cap states are not used for mouse move events. Probably because
    // Jesusonic effects dont support focusing.
    jes2cpp$mouse_x$ = AX;
    jes2cpp$mouse_y$ = AY;
    // The graphics rate is boosted to the default value each
    // time the mouse values are changed. This allows the graphics to be updated
    // with interactive graphics effects. You can set drop the graphics rate
    // in @gfx down to something like 4 FPS. Which means, the graphics will throttle,
    // instead of aways updating at 30 FPS's.
    jes2cpp$gfx_rate$ = std::max<EEL_F>(jes2cpp$gfx_rate$, GFX_RATE);
  }
  // Handle mouse down events.
  void DoMouseDown(VEST_F AX, VEST_F AY, int AButtons)
  {
    // Mouse/Key states are only set for mouse down events, and cleared on any mouse up event.
    jes2cpp$mouse_cap$ = (EEL_F)(
                           ((AButtons &  2) >> 1) |  // Left Button (1)
                           ((AButtons &  4) << 4) |  // Middle Button (64)
                           ((AButtons &  8) >> 2) |  // Right Button (2)
                           ((AButtons & 16) >> 1) |  // Shift (8)
                           ((AButtons & 32) >> 3) |  // Control (4)
                           ((AButtons & 64) >> 2) ); // Alt (16)
    DoMouseMoved(AX, AY, AButtons);
  }
  // Handle mouse up events.
  void DoMouseUp(VEST_F AX, VEST_F AY, int AButtons)
  {
    // REAPER clears all mouse states on a mouse button up events.
    jes2cpp$mouse_cap$ = 0;
    DoMouseMoved(AX, AY, AButtons);
  }
};

class TJes2Cpp : public CJes2CppMouse
{
private:

  clock_t FClockUpdate, FClockInvalidate;

public:

  EEL_F num_ch$, srate$, samplesblock$, pdc_delay$, pdc_top_ch$, pdc_bot_ch$, tempo$, ts_num$, ts_denom$, trigger$,
        beat_position$, play_state$;

  TJes2Cpp()
  {
    EEL_fft_register();
#ifdef BASS_H
    BASS_Init(0, 44100, 0, nullptr, nullptr);
#endif // BASS_H
    DoOpen();
  }
  virtual ~TJes2Cpp()
  {
#ifdef BASS_H
    BASS_Free();
#endif // BASS_H
  }

public:

  virtual void DoOpen()
  {
    FMemory.Clear();
    ClearStrings();
    num_ch$ = M_ZERO;
    pdc_delay$ = M_ZERO;
    pdc_top_ch$ = M_ZERO;
    pdc_bot_ch$ = M_ZERO;
    samplesblock$ = M_ZERO;
    srate$ = M_ZERO;
    tempo$ = M_ZERO;
    ts_num$ = M_ZERO;
    ts_denom$ = M_ZERO;
    trigger$ = M_ZERO;
    beat_position$ = M_ZERO;
    play_state$ = M_ZERO;
    FClockUpdate = FClockInvalidate = 0;
  }
  virtual void DoClose() { }
  virtual void DoSuspend() { }
  virtual void DoResume()
  {
    DoOpen();
    DoInit();
    DoSlider();
    VeST_SetInitialDelay(FVeST, EEL_F2I(pdc_delay$));
  }
  virtual void DoInit()
  {
    srate$ = VeST_GetSampleRate(FVeST);
    num_ch$ = VeST_GetNumInputs(FVeST);
    tempo$ = (EEL_F)VeST_GetTempo(FVeST);
    samplesblock$ = (EEL_F)VeST_GetBlockSize(FVeST);
  }
  virtual void DoBlock()
  {
    VEST_F tempo, ts_num, ts_denom;
    // We must copy to local VEST_F's to support 32bit float VST's.
    // ie: VEST_F is always double, but EEL_F may be float or double.
    VeST_GetTimeInfo3(FVeST, &tempo, &ts_num,  &ts_denom);
    tempo$ = tempo;
    ts_num$ = ts_num;
    ts_denom$ = ts_denom;
    // Currently doesn't support pause since it seems to be host dependent.
    play_state$ = (VeST_GetTransportPlaying(FVeST) ? 1 : 0) | (VeST_GetTransportRecording(FVeST) ? 4 : 0);
    beat_position$ =  VeST_GetPpqPos(FVeST);
    // Note: We dont seem to get DoIdle events when not in graphics mode,
    // which is odd, so I handle non-gfx GUI updating here. I dont like it
    // but, until I find a better solution....
    if ((clock() - FClockUpdate) > (CLOCKS_PER_SEC / 2)) {
      if (FUpdateDisplay) {
        FUpdateDisplay = false;
        VeST_UpdateDisplay(FVeST);
      }
      FClockUpdate = clock();
    }
  }
  virtual void DoGfx()
  {
    int LWidth, LHeight;
    if (VeST_GetGraphicsSize(FVeST, &LWidth, &LHeight)) {
      gfx_w$ = (EEL_F)LWidth;
      gfx_h$ = (EEL_F)LHeight;
    }
  }
  virtual void DoIdle()
  {
    if (jes2cpp$gfx_rate$ > 0) {
      if ((clock() - FClockInvalidate) > (CLOCKS_PER_SEC / jes2cpp$gfx_rate$)) {
        VeST_InvalidateGraphics(FVeST);
        FClockInvalidate = clock();
      }
    }
  }
  virtual void DoSerialize()
  {
  }
  virtual int DoSetChunk(void* AData, int ASize, bool AIsPreset)
  {
    // Unsure if we need to support presets?
    if (AIsPreset) {
      return 0;
    }
    CJes2CppFile* LFile = GetFile(FILE_HANDLE_SERIAL);
    if (LFile->OpenRead(AData, ASize)) {
      EEL_F LValue;
      if (LFile->Read(LValue) && LValue == STREAM_IDENT_USER) {
        DoSerialize();
      }
    }
    return LFile->GetByteSize();
  }
  virtual int DoGetChunk(void** AData, bool AIsPreset)
  {
    // Unsure if we need to support presets?
    if (AIsPreset) {
      return 0;
    }
    CJes2CppFile* LFile = GetFile(FILE_HANDLE_SERIAL);
    LFile->OpenWrite();
    // Write a known ident value so we can validate chunk with when reading.
    if (!LFile->Write(STREAM_IDENT_USER)) {
      return 0;
    }
    int LByteSize = LFile->GetByteSize();
    DoSerialize();
    // If no more data is written in DoSerialize(), then return zero bytes.
    // This prevents the standard slider serialization from being disabled.
    if (LByteSize == LFile->GetByteSize()) {
      return 0;
    }
    *AData = LFile->GetStreamMemory();
    // NOTE: We dont close file because a pointer to the stream data is sent
    // back to the host. File will be close next time a chunk is requested.
    return LFile->GetByteSize();
  }
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

// Returns true if value contains byte value. Used for multibyte font style decoding.
inline bool ContainsByte(uint32_t AValue, uint8_t AByte)
{
return
  ((AValue >>  0) & 0xFF) == AByte ||
  ((AValue >>  8) & 0xFF) == AByte ||
  ((AValue >> 16) & 0xFF) == AByte ||
  ((AValue >> 24) & 0xFF) == AByte ;
}

// There are constants copied from "eel_fft.h". Used by "jes2cpp.jsfx-inc".
// I will try to remove these soon.
#define DIR_FFT 0
#define DIR_IFFT 1
#define DIR_PERMUTE 4
#define DIR_IPERMUTE 5

extern void js_mdct(CMemory* AMemory, int AIndex, int ALength, bool AIsInverse);
extern void js_convolve_c(CMemory* AMemory, int ADst, int ASrc, int ALength);
extern void js_fft(CMemory* AMemory, int AIndex, int ALength, int ADir);

#endif

