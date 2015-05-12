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

bool CJes2CppStream::Write(Real AValue)
{
  FBuffer.resize(Max(FBuffer.size(), FPosition + 1));
  FBuffer[FPosition++] = AValue;
  return true;
}

bool CJes2CppStream::Read(Real& AValue)
{
  if (FPosition < (int)FBuffer.size())
  {
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
  while (!feof(AFile)) Write((Real)fgetc(AFile)); 
}

bool CJes2CppStream::LoadFromFileTxt(const String& AFileName)
{
  Clear();
  FILE* LFile = fopen(AFileName.c_str(), "rt");
  if (LFile)
  {
    ReadFromFile(LFile); 
    fclose(LFile);     
    Rewind(); 
    return true;
  }
  return false;  
}

bool CJes2CppStream::LoadFromFileBin(const String& AFileName)
{
  Clear();
  FILE* LFile = fopen(AFileName.c_str(), "rb");
  if (LFile)
  {
    ReadFromFile(LFile); 
    fclose(LFile);     
    Rewind(); 
    return true;
  }
  return false;  
}

bool CJes2CppStream::LoadFromFileAud(const String& AFileName, int& AChannelCount, int& ASampleRate)
{
#ifndef _JES2CPP_NO_BASS_
  HSAMPLE LSample = BASS_SampleLoad(false, AFileName.c_str(), 0, 0, 1, BASS_SAMPLE_FLOAT);
  if (LSample)
  { 
    BASS_SAMPLE LInfo;
    if (BASS_SampleGetInfo(LSample, &LInfo))
    {
      AChannelCount = LInfo.chans;
      ASampleRate = LInfo.freq;
      FBuffer.resize((LInfo.length + (sizeof(FLOAT) - 1)) / sizeof(FLOAT));
      BASS_SampleGetData(LSample, &FBuffer[0]);  
      BASS_SampleFree(LSample);  
      Rewind();
      return true;
    }
    BASS_SampleFree(LSample);
  } else Beep(2000, 200);
#endif
  return false;
}

bool CJes2CppStream::SaveToFileBin(const String& AFileName)
{
  FILE* LFile = fopen(AFileName.c_str(), "wb");
  if (LFile)
  {
    for (int LIndex = 0; LIndex < (int)FBuffer.size(); LIndex++)
    {
      fputc(REAL2INT(FBuffer[LIndex]), LFile);
    }
    fclose(LFile);
    return true;
  }
  return false;
}

bool CJes2CppStream::ReadString(String& AString)
{ 
  AString.clear();
  if (DataAvaliable())
  {
    Real LValue;
    while (Read(LValue))
    { 
      char LChar = REAL2INT(LValue);
      if (LChar == '\n') break;
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
  VeST_SetChunk(AVeST, &FBuffer[0], FBuffer.size() * sizeof(FLOAT), false);
}

void CJes2CppStream::LoadFromChunk(HVEST AVeST)
{
  PVOID LData;
  FBuffer.resize(VeST_GetChunk(AVeST, &LData, false) / sizeof(FLOAT));
  for (int LIndex = 0; LIndex < (int)FBuffer.size(); LIndex++)
  {
    FBuffer[LIndex] = ((FLOAT*)LData)[LIndex];
  }
}
*/


