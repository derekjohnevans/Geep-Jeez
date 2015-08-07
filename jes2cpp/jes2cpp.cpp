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

std::string FileNameResolve(const std::string& AFileName)
{
  return ProgramDirectory() + ExcludeLeadingPathDelimiter(AFileName);
}

// Scans a file path and return a vector of filenames. Excludes any filename starting with '.'
// There are two versions of this function here, because directory scanning doesn't seem
// to have a standard _portable_ api.
#ifdef __GNUC__
void GetFileNames(std::string APath, std::vector<std::string>& AFileNames)
{
  DIR* LDir = opendir(APath.c_str());
  if (LDir) {
    struct dirent* LDirent;
    while ((LDirent = readdir(LDir)) != nullptr) {
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
void GetFileNames(std::string APath, std::vector<std::string>& AFileNames)
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

// Define some common Delphi/FreePascal style helper functions.
// Note: Some of these will be removed if found to be not used.

std::string ProgramDirectory()
{
  return ExtractFilePath(GetModuleName((VEST_HANDLE) hInstance));
}

bool SameText(const std::string& A, const std::string& B)
{
  return strcasecmp(A.c_str(), B.c_str()) == 0;
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

// This is only used for debugging. If your VST effect beeps, then
// check the log.
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


#include "wdl/eel_fft.cpp"
#include "wdl/fft.c"
#include "wdl/eel_mdct.cpp"
