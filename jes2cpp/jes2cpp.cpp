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

#include "wdl/eel_fft.h"
#include "wdl/eel_mdct.h"

std::string FileNameResolve(const std::string& AFileName)
{
  return GetCurrentModulePath() + ExcludeLeadingPathDelimiter(AFileName);
}

void TJes2Cpp::DoOpen()
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

void TJes2Cpp::DoResume()
{
  if (srate$ != VeST_GetSampleRate(FVeST)) {
    DoOpen();
  }
  DoInit();
  DoSlider();
  VeST_SetInitialDelay(FVeST, (int)pdc_delay$);
}

void TJes2Cpp::DoInit()
{
  srate$ = VeST_GetSampleRate(FVeST);
  num_ch$ = VeST_GetNumInputs(FVeST);
  tempo$ = (EEL_F)VeST_GetTempo(FVeST);
  samplesblock$ = (EEL_F)VeST_GetBlockSize(FVeST);
}

void TJes2Cpp::DoClose() { }
void TJes2Cpp::DoSuspend() { }

void TJes2Cpp::DoBlock()
{
  double tempo, ts_num, ts_denom;
  // We must copy to locals to support 32bit float VST's.
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

void TJes2Cpp::DoGfx()
{
  int LWidth, LHeight;
  if (VeST_GetGraphicsSize(FVeST, &LWidth, &LHeight)) {
    gfx_w$ = (EEL_F)LWidth;
    gfx_h$ = (EEL_F)LHeight;
  }
  gfx_rate$ = GFX_RATE;
}

void TJes2Cpp::DoIdle()
{
  if (gfx_rate$ > 0) {
    if ((clock() - FClockInvalidate) > (CLOCKS_PER_SEC / gfx_rate$)) {
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

TJes2Cpp::TJes2Cpp()
{
  EEL_fft_register();
#ifdef BASS_H
  BASS_Init(-1, 44100, 0, 0, NULL);
#endif
  DoOpen();
}

TJes2Cpp::~TJes2Cpp()
{
#ifdef BASS_H
  BASS_Free();
#endif
}

#ifdef __GNUC__
void GetFileNames(std::string APath, TStringDynArray& AFileNames)
{
  DIR* LDir = opendir(APath.c_str());
  if (LDir) {
    struct dirent* LDirent;
    while ((LDirent = readdir(LDir)) != NULL) {
      if (LDirent->d_name[0] != '.') {
        struct stat LStat;
        if (!stat((APath + LDirent->d_name).c_str(), &LStat) && !S_ISDIR(LStat.st_mode)) {
          AFileNames.push_back(LDirent->d_name);
        }
      }
    }
    closedir(LDir);
  }
}
#else
void GetFileNames(std::string APath, TStringDynArray& AFileNames)
{
  _finddata_t LFindData;
  int LHandle = _findfirst((APath + "*").c_str(), &LFindData);
  if (LHandle != -1) {
    do {
      if ((LFindData.name[0] != '.') && !(LFindData.attrib & _A_SUBDIR)) {
        AFileNames.push_back(LFindData.name);
      }
    } while (!_findnext(LHandle, &LFindData));
    _findclose(LHandle);
  }
}
#endif

std::string GetCurrentModulePath()
{
  return ExtractFilePath(GetModuleName((VEST_HANDLE) hInstance));
}

bool SameText(const std::string& A, const std::string& B)
{
  return _stricmp(A.c_str(), B.c_str()) == 0;
}

bool SameStr(const std::string& A, const std::string& B)
{
  return strcmp(A.c_str(), B.c_str()) == 0;
}

bool AnsiEndsStr(const std::string& ASubStr, const std::string& AString)
{
  return SameStr(AString.substr(AString.length() - ASubStr.length()), ASubStr);
}

bool AnsiStartsStr(const std::string& ASubStr, const std::string& AString)
{
  return SameStr(AString.substr(0, ASubStr.length()), ASubStr);
}

bool FileNameIsPath(const std::string& AFileName)
{
  return AnsiEndsStr(DirectorySeparatorDos, AFileName) || AnsiEndsStr(DirectorySeparatorUnix, AFileName);
}

bool FileNameIsRoot(const std::string& AFileName)
{
  return AnsiStartsStr(DirectorySeparatorDos, AFileName) || AnsiStartsStr(DirectorySeparatorUnix, AFileName);
}

std::string IncludeTrailingPathDelimiter(const std::string& AFileName)
{
  return FileNameIsPath(AFileName) ? AFileName : AFileName + DirectorySeparator;
}

std::string IncludeLeadingPathDelimiter(const std::string& AFileName)
{
  return FileNameIsRoot(AFileName) ? AFileName : DirectorySeparator + AFileName;
}

std::string ExcludeLeadingPathDelimiter(const std::string& AFileName)
{
  return FileNameIsRoot(AFileName) ? AFileName.substr(1) : AFileName;
}

int FileNameStart(const std::string& AFileName)
{
  for (int LIndex = AFileName.length(); LIndex-- > 0;) {
    if (AFileName[LIndex] == '\\' || AFileName[LIndex] == '/') {
      return LIndex;
    }
  }
  return -1;
}

std::string ExtractFilePath(const std::string& AFileName)
{
  return AFileName.substr(0, FileNameStart(AFileName) + 1);
}

std::string ExtractFileName(const std::string& AFileName)
{
  return AFileName.substr(FileNameStart(AFileName) + 1);
}

std::string ExtractFileExt(const std::string& AFileName)
{
  int LPos = AFileName.rfind(ExtensionSeparator);
  return LPos < 0 ? EmptyStr : AFileName.substr(LPos);
}

#ifdef _WIN32
std::string GetModuleName(VEST_HANDLE AModule)
{
  char LFileName[MAX_PATH];
  GetModuleFileNameA((HMODULE)AModule, LFileName, MAX_PATH);
  return LFileName;
}
#endif

// This is only used for debugging.
void GeepError(const std::string& AString)
{
  FILE* LFile = fopen("\\geep.log.txt", "a");
  if (LFile) {
    fprintf(LFile, "%s\n", AString.c_str());
    fclose(LFile);
#ifdef _WIN32
    Beep(2000, 200);
#endif
  }
}

void CJes2CppParameter::Init()
{
  if (!FIsInitialized) {
    FIsInitialized = true;
    if (FFilePath.length() > 0) {
      GetFileNames(FileNameResolve(FFilePath), FOptions);
      if (FOptions.size() == 0) {
        FOptions.push_back("(No Data Files)");
      }
      FMinValue = 0;
      FMaxValue = (EEL_F)(FOptions.size() - 1);
      FDefValue = 0;
      FStepValue = 0.5;
    }
  }
}

EEL_F CJes2CppParameter::ToSlider(EEL_F AValue)
{
  return floor((FMinValue + (FMaxValue - FMinValue) * AValue + (FStepValue / 2)) / FStepValue) * FStepValue;
}

EEL_F CJes2CppParameter::FromSlider(EEL_F AValue)
{
  return (AValue - FMinValue) / (FMaxValue - FMinValue);
}

int CJes2CppParameter::GetOptionIndex(EEL_F AValue)
{
  return MinMax((int)((AValue - FMinValue) * (FOptions.size() - 1) / (FMaxValue - FMinValue)), 0, FOptions.size() - 1);
}

void CJes2CppParameter::GetDisplayFromSliderValue(char* AString, EEL_F AValue)
{
  int LIndex = GetOptionIndex(AValue);
  if (LIndex >= 0 && LIndex < (int)FOptions.size()) {
    strcpy(AString, FOptions[LIndex].c_str());
  } else {
    sprintf(AString, "%.2f", AValue);
  }
}

CJes2CppStream::CJes2CppStream()
{
  FPosition = 0;
}

void CJes2CppStream::Rewind()
{
  FPosition = 0;
}

void CJes2CppStream::Clear()
{
  FBuffer.clear();
  Rewind();
}

bool CJes2CppStream::Write(EEL_F AValue)
{
  FBuffer.resize(Max(FBuffer.size(), FPosition + 1));
  FBuffer[FPosition++] = (float)AValue;
  return true;
}

bool CJes2CppStream::Read(EEL_F& AValue)
{
  if (FPosition < (int)FBuffer.size()) {
    AValue = FBuffer[FPosition++];
    return true;
  }
  return false;
}

int CJes2CppStream::DataAvaliable()
{
  return FBuffer.size() - FPosition;
}

void CJes2CppStream::ReadFromFile(FILE* AFile)
{
  while (!feof(AFile)) {
    Write((EEL_F)fgetc(AFile));
  }
}

bool CJes2CppStream::LoadFromFileTxt(const std::string& AFileName)
{
  Clear();
  FILE* LFile = fopen(AFileName.c_str(), "rt");
  if (LFile) {
    ReadFromFile(LFile);
    fclose(LFile);
    Rewind();
    return true;
  }
  return false;
}

bool CJes2CppStream::LoadFromFileBin(const std::string& AFileName)
{
  Clear();
  FILE* LFile = fopen(AFileName.c_str(), "rb");
  if (LFile) {
    ReadFromFile(LFile);
    fclose(LFile);
    Rewind();
    return true;
  }
  return false;
}

bool CJes2CppStream::LoadFromFileSnd(const std::string& AFileName, int& AChannelCount, int& ASampleRate)
{
#ifdef SNDFILE_H
  SF_INFO LInfo;
  SNDFILE* LFile = sf_open(AFileName.c_str(), SFM_READ, &LInfo);
  if (LFile) {
    AChannelCount = LInfo.channels;
    ASampleRate = LInfo.samplerate;
    FBuffer.resize((unsigned)(LInfo.frames * LInfo.channels));
    sf_read_float(LFile, &FBuffer[0], FBuffer.size());
    sf_close(LFile);
    Rewind();
    return true;
  }
#endif
#ifdef BASS_H
  HSAMPLE LSample = BASS_SampleLoad(false, AFileName.c_str(), 0, 0, 1, BASS_SAMPLE_FLOAT);
  if (LSample) {
    BASS_SAMPLE LInfo;
    if (BASS_SampleGetInfo(LSample, &LInfo)) {
      AChannelCount = LInfo.chans;
      ASampleRate = LInfo.freq;
      FBuffer.resize((LInfo.length + (sizeof(float) - 1)) / sizeof(float));
      BASS_SampleGetData(LSample, &FBuffer[0]);
      BASS_SampleFree(LSample);
      Rewind();
      return true;
    }
    BASS_SampleFree(LSample);
  }
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
        FBuffer[LIndex] = *((int32_t*)&FBuffer[LIndex]) / (float)INT16_MAX;
      }
    }
    WavpackCloseFile(LContext);
    return true;
  }
#endif
  GeepError("Unable to load: " + AFileName);
  return false;
}

bool CJes2CppStream::SaveToFileBin(const std::string& AFileName)
{
  FILE* LFile = fopen(AFileName.c_str(), "wb");
  if (LFile) {
    for (int LIndex = 0; LIndex < (int)FBuffer.size(); LIndex++) {
      fputc(EEL_F2I(FBuffer[LIndex]), LFile);
    }
    fclose(LFile);
    return true;
  }
  return false;
}

bool CJes2CppStream::ReadString(std::string& AString)
{
  AString.clear();
  if (DataAvaliable()) {
    EEL_F LValue;
    while (Read(LValue)) {
      char LChar = EEL_F2I(LValue);
      if (LChar == '\n') {
        break;
      }
      AString += LChar;
    }
    return true;
  } else {
    return false;
  }
}

/*
void CJes2CppStream::SaveToChunk(HVEST AVeST)
{
  VeST_SetChunk(AVeST, &FBuffer[0], FBuffer.size() * sizeof(float), false);
}

void CJes2CppStream::LoadFromChunk(HVEST AVeST)
{
  PVOID LData;
  FBuffer.resize(VeST_GetChunk(AVeST, &LData, false) / sizeof(float));
  for (int LIndex = 0; LIndex < (int)FBuffer.size(); LIndex++)
  {
    FBuffer[LIndex] = ((float*)LData)[LIndex];
  }
}
*/

CJes2CppFile::CJes2CppFile()
{
  FIsText = false;
  FChannelCount = FSampleRate = 0;
  FMode = FILE_CLOSED;
}

CJes2CppFile::~CJes2CppFile()
{
  Close();
}

void CJes2CppFile::OpenWrite(const std::string& AFileName)
{
  Close();
  FMode = FILE_WRITE;
  FFileName = AFileName;
}

bool CJes2CppFile::OpenRead(const std::string& AFileName)
{
  Close();
  std::string LFileExt = ExtractFileExt(AFileName);
  // TODO: Support other audio file types.
  if (SameText(LFileExt, ".wav") && FStream.LoadFromFileSnd(FileNameResolve(AFileName), FChannelCount, FSampleRate)) {
    FMode = FILE_READ;
    return true;
  }
  if (SameText(LFileExt, ".txt") && FStream.LoadFromFileTxt(FileNameResolve(AFileName))) {
    FIsText = true;
    FMode = FILE_READ;
    return true;
  }
  if (FStream.LoadFromFileBin(FileNameResolve(AFileName))) {
    FMode = FILE_READ;
    return true;
  }
  return false;
}

void CJes2CppFile::Close()
{
  if (FMode == FILE_WRITE && FFileName.length() > 0) {
    FStream.SaveToFileBin(FileNameResolve(FFileName).c_str());
  }
  FFileName.clear();
  FStream.Clear();
  FChannelCount = FSampleRate = 0;
  FMode = FILE_CLOSED;
  FIsText = false;
}

bool CJes2CppFile::StreamValue(EEL_F& AValue)
{
  return FMode == FILE_WRITE ? FStream.Write(AValue) : FMode == FILE_READ ? FStream.Read(AValue) : false;
}

int CJes2CppFile::StreamMemory(CMemory* AMemory, EEL_F AIndex, EEL_F ALength)
{
  int LCount = 0;
  if (FMode != FILE_CLOSED) {
    int LIndex = EEL_F2I(AIndex), LLength = EEL_F2I(ALength);
    if (FMode == FILE_WRITE) {
      for (; LLength-- > 0; LCount++) {
        FStream.Write((*AMemory)[LIndex++]);
      }
    }
    if (FMode == FILE_READ) {
      LLength = Min(LLength, FStream.DataAvaliable());
      for (; LLength-- > 0; LCount++) {
        FStream.Read((*AMemory)[LIndex++]);
      }
    }
  }
  return LCount;
}

EEL_F CJes2CppFiles::file_open_(int AIndex)
{
  CJes2CppFile* LFile = &FFiles[AIndex];
  LFile->Close();
  return LFile->OpenRead(GetFileName(AIndex)) ? (EEL_F)AIndex : M_ERROR;
}

EEL_F CJes2CppFiles::file_open_(EEL_F& ASlider)
{
  int LIndex = &ASlider - &FSliders[0];
  if (LIndex < 0 || LIndex >= JES2CPP_SLIDER_COUNT) {
    return file_open_(EEL_F2I(ASlider));
  } else {
    CJes2CppFile* LFile = &FFiles[FILE_HANDLE_SLIDER + LIndex];
    LFile->Close();
    int LParamIndex = FindParameterBySliderIndex(LIndex);
    if (LParamIndex >= 0) {
      char LFileName[FILENAME_MAX];
      FParameters[LParamIndex].GetDisplayFromSliderValue(LFileName, FSliders[FParameters[LParamIndex].FIndex]);
      return LFile->OpenRead(FParameters[LParamIndex].FFilePath + LFileName) ? (EEL_F)(FILE_HANDLE_SLIDER + LIndex) : M_ERROR;
    }
  }
  return M_ERROR;
}

/*
** NOTE: Some of the following functions are based on caller functions from Cockos WDL.
**       So, here is their license as per their request.
*/

/*
  Copyright (C) 2006 and later Cockos Incorporated

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

/*
** This is a version of mdct_func() from Cockos "eel_mdct.h"
** We use a simpler memory manager, so code was taken out.
*/
void js_mdct(CMemory* AMemory, int AIndex, int ALength, bool AIsInverse)
{
  int LBitLen = LengthToBitLen(ALength);
  if (LBitLen >= EEL_DCT_MINBITLEN && LBitLen <= EEL_DCT_MAXBITLEN) {
    static mdct_lookup* mdct_ctxs[EEL_DCT_MAXBITLEN + 1];
    if (!mdct_ctxs[LBitLen]) {
      mdct_ctxs[LBitLen] = (mdct_lookup*) megabuf_mdct_init(ALength);
    }
    EEL_F LBuffer[1 << EEL_DCT_MAXBITLEN];
    if (AIsInverse) {
      megabuf_mdct_backward(mdct_ctxs[LBitLen], &(*AMemory)[AIndex], LBuffer);
      megabuf_mdct_apply_window(mdct_ctxs[LBitLen], LBuffer, &(*AMemory)[AIndex]);
    } else {
      megabuf_mdct_apply_window(mdct_ctxs[LBitLen], &(*AMemory)[AIndex], LBuffer);
      megabuf_mdct_forward(mdct_ctxs[LBitLen], LBuffer, &(*AMemory)[AIndex]);
    }
  }
}

/*
** This is based on eel_convolve_c() from Cockos "eel_fft.h"
** Again, we use a simple memory manager, so a lot of code was taken out. The key
** issue here is, we need to allocate twice as much memory as requested.
*/
void js_convolve_c(CMemory* AMemory, int ADst, int ASrc, int ALength)
{
  ALength *= 2;
  WDL_fft_complexmul((WDL_FFT_COMPLEX*) & (*AMemory)[ADst], (WDL_FFT_COMPLEX*) & (*AMemory)[ASrc], (ALength / 2) & ~1);
}

/*
** This is based on fft_func() from "eel_fft.h".
** This is a gateway for the functions fft(), ifft(), fft_permute() & fft_ipermute().
*/
void js_fft(CMemory* AMemory, int AIndex, int ALength, int ADir)
{
  int LBitLen = LengthToBitLen(ALength);
  if (LBitLen >= EEL_FFT_MINBITLEN && LBitLen <= EEL_FFT_MAXBITLEN) {
    FFT(LBitLen, &(*AMemory)[AIndex], ADir);
  }
}

void CJes2CppStrings::ClearStrings()
{
  FStringMap.Clear();
  FStringLiteralBase = EEL_STRING_LITERAL_BASE;
  str_count$ = (EEL_F)FStringMap.Count();
}

void CJes2CppStrings::VPrintF(char* AString, const char* AFormat, va_list AArgs)
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
      case 'f':
        sprintf(AString, LBuffer, va_arg(AArgs, double));
        AString = strchr(AString, 0);
        break;
      case 'd':
        sprintf(AString, LBuffer, EEL_F2I(va_arg(AArgs, double)));
        AString = strchr(AString, 0);
        break;
      case 's':
        sprintf(AString, LBuffer, GetString(va_arg(AArgs, double)).c_str());
        AString = strchr(AString, 0);
        break;
      }
    } else {
      *AString++ = *AFormat++;
    }
  }
  *AString = 0;
}

EEL_F CJes2CppStrings::strcpy_fromslider_(EEL_F AString, int ASlider)
{
  int LIndex = FindParameterBySliderIndex(ASlider);
  if (LIndex >= 0) {
    char LString[FILENAME_MAX];
    FParameters[LIndex].GetDisplayFromSliderValue(LString, FSliders[ASlider]);
    GetString(AString) = LString;
  }
  return AString;
}

EEL_F CJes2CppStrings::strcpy_fromslider_(EEL_F AString, EEL_F& ASlider)
{
  return strcpy_fromslider_(AString, &ASlider - &FSliders[0]);
}

CJes2CppImage::CJes2CppImage()
{
  FBitmap = NULL;
  FWidth = FHeight = M_ZERO;
}

CJes2CppImage::~CJes2CppImage()
{
  Clear();
}

void CJes2CppImage::Clear()
{
  if (FBitmap) {
    VeST_BitmapFree(FBitmap);
    FBitmap = NULL;
  }
  FWidth = FHeight = 0;
}

bool CJes2CppImage::LoadFromFile(const std::string& AFileName)
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

CJes2CppGraphics::CJes2CppGraphics()
{
  gfx_rate$ = M_ZERO;
  gfx_clear$ = M_ZERO;
  gfx_r$ = M_ZERO;
  gfx_g$ = M_ZERO;
  gfx_b$ = M_ZERO;
  gfx_a$ = M_ZERO;
  gfx_x$ = M_ZERO;
  gfx_y$ = M_ZERO;
  gfx_w$ = M_ZERO;
  gfx_h$ = M_ZERO;
}

void CJes2CppGraphics::DrawString(const char* AString)
{
  VeST_SetFontColor(FVeST, EEL_F2PEN(gfx_r$), EEL_F2PEN(gfx_g$), EEL_F2PEN(gfx_b$), EEL_F2PEN(gfx_a$));
  double LX2 = gfx_x$ + VeST_GetStringWidth(FVeST, AString);
  double LY2 = gfx_y$ + gfx_texth$;
  VeST_DrawString(FVeST, AString, gfx_x$, gfx_y$, LX2, LY2, false, 0);
  gfx_x$ = LX2;
}

CJes2CppImage& CJes2CppGraphics::GetImage(EEL_F AIndex)
{
  int LIndex = EEL_F2I(AIndex);
  if (!FImages[LIndex].FBitmap) {
    FImages[LIndex].LoadFromFile(GetFileName(LIndex));
  }
  return FImages[LIndex];
}

#include "wdl/eel_fft.cpp"
#include "wdl/fft.c"
#include "wdl/eel_mdct.cpp"
