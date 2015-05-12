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

void CJes2CppFile::OpenWrite(const String& AFileName)
{
  Close();
  FMode = FILE_WRITE;
  FFileName = AFileName;
}

bool CJes2CppFile::OpenRead(const String& AFileName)
{
  Close();  
  String LFileExt = ExtractFileExt(AFileName);
  if (SameText(LFileExt, ".wav") && FStream.LoadFromFileAud(FileNameResolve(AFileName), FChannelCount, FSampleRate))
  {
    FMode = FILE_READ; 
    return TRUE;
  }
  if (SameText(LFileExt, ".txt") && FStream.LoadFromFileTxt(FileNameResolve(AFileName)))
  {
    FIsText = true;
    FMode = FILE_READ; 
    return TRUE;
  }
  if (FStream.LoadFromFileBin(FileNameResolve(AFileName)))
  {
    FMode = FILE_READ; 
    return TRUE;
  }
  return FALSE;
}

void CJes2CppFile::Close()
{
  if (FMode == FILE_WRITE && FFileName.length() > 0)
  {
    FStream.SaveToFileBin(FileNameResolve(FFileName).c_str());    
  }
  FFileName.clear();
  FStream.Clear();
  FChannelCount = FSampleRate = 0;
  FMode = FILE_CLOSED;
  FIsText = false;
}

bool CJes2CppFile::StreamValue(Real& AValue)
{
  return FMode == FILE_WRITE ? FStream.Write(AValue) : FMode == FILE_READ ? FStream.Read(AValue) : FALSE;
}

int CJes2CppFile::StreamMemory(CMemory* AMemory, Real AIndex, Real ALength) 
{ 
  int LCount = 0;
  if (FMode != FILE_CLOSED)
  {
    int LIndex = REAL2INT(AIndex), LLength = REAL2INT(ALength);
    if (FMode == FILE_WRITE)
    {
      for (; LLength-- > 0; LCount++)
      {
        FStream.Write((*AMemory)[LIndex++]);
      }
    }
    if (FMode == FILE_READ)
    {
      LLength = Min(LLength, FStream.DataAvaliable());
      for (; LLength-- > 0; LCount++) 
      {
        FStream.Read((*AMemory)[LIndex++]);
      }
    }
  }
  return LCount; 
}

Real CJes2CppFiles::FUN(file_open)(int AIndex) 
{
  CJes2CppFile* LFile = &FFiles[AIndex];
  LFile->Close();  
  return LFile->OpenRead(GetFileName(AIndex)) ? (Real)AIndex : M_ERROR;  
}

Real CJes2CppFiles::FUN(file_open)(Real& ASlider) 
{  
  int LIndex = &ASlider - &VAR(slider$)[0];
  
  if (LIndex < 0 || LIndex >= (int)VAR(slider$).size())
  {    
    return FUN(file_open)(REAL2INT(ASlider));
  } else {
    CJes2CppFile* LFile = &FFiles[FILE_HANDLE_SLIDER + LIndex];
    LFile->Close();
    int LParamIndex = FindParameterBySliderIndex(LIndex);
    if (LParamIndex >= 0)
    {      
      CHAR LFileName[MAX_PATH];
      FParameters[LParamIndex].GetDisplayFromSliderValue(LFileName, VAR(slider$)[FParameters[LParamIndex].FIndex]);
      return LFile->OpenRead(FParameters[LParamIndex].FFilePath + LFileName) ? (Real)(FILE_HANDLE_SLIDER + LIndex) : M_ERROR;
    }
  }
  return M_ERROR; 
}

Real CJes2CppFiles::FUN(file_close)(Real& AHandle) 
{ 
  return FFiles[REAL2INT(AHandle)].Close(), AHandle = M_ERROR;
}

Real CJes2CppFiles::FUN(file_rewind)(Real AHandle) 
{ 
  return FFiles[REAL2INT(AHandle)].FStream.Rewind(), M_TRUE;
}

Real CJes2CppFiles::FUN(file_var)(Real AHandle, Real& AValue) 
{ 
  return FFiles[REAL2INT(AHandle)].StreamValue(AValue);
}

Real CJes2CppFiles::FUN(file_mem)(Real AHandle, Real AIndex, Real ALength) 
{ 
  return FFiles[REAL2INT(AHandle)].StreamMemory(&FMemory, AIndex, ALength);
}

Real CJes2CppFiles::FUN(file_avail)(Real AHandle) 
{       
  return FFiles[REAL2INT(AHandle)].FMode == FILE_WRITE ? M_ERROR : FFiles[REAL2INT(AHandle)].FStream.DataAvaliable();
}

Real CJes2CppFiles::FUN(file_riff)(Real AHandle, Real& AChannelCount, Real& ASampleRate) 
{ 
  AChannelCount = (Real)FFiles[REAL2INT(AHandle)].FChannelCount;
  ASampleRate = (Real)FFiles[REAL2INT(AHandle)].FSampleRate; 
  return M_TRUE; 
}

Real CJes2CppFiles::FUN(file_text)(Real AHandle) 
{ 
  return FFiles[REAL2INT(AHandle)].FIsText; 
} 

Real CJes2CppFiles::FUN(file_string)(Real AHandle, Real AString)
{
  return FFiles[REAL2INT(AHandle)].FStream.ReadString(GetString(AString));
}


