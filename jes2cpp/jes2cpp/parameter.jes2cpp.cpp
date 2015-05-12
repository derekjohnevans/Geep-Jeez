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

CJes2CppParameter::CJes2CppParameter(int AIndex, Real ADefValue, Real AMinValue, Real AMaxValue, Real AStepValue, 
  const String& AFilePath, const String& AFileName, const String& ALabelString, const String& ADescription) 
{
  FIsInitialized = FALSE;
  FIndex = AIndex;
  FDefValue = ADefValue;
  FMinValue = AMinValue;
  FMaxValue = AMaxValue;
  FStepValue = AStepValue;
  FFilePath = AFilePath;
  FFileName = AFileName;
  FLabelString = ALabelString;
  FDescription = ADescription;
}

void CJes2CppParameter::Init()
{
  if (!FIsInitialized) 
  {
    FIsInitialized = TRUE;
  
    if (FFilePath.length() > 0)
    {
      _finddata_t LFindData;

      int LHandle = _findfirst((FileNameResolve(FFilePath) + "*").c_str(), &LFindData);

      if (LHandle != -1)
      {
        do {
          if (LFindData.name[0] != '.') FOptions.push_back(LFindData.name);
        } while (!_findnext(LHandle, &LFindData));
        _findclose(LHandle);
      }
      if (FOptions.size() == 0) FOptions.push_back("(No Data Files)");  
      FMinValue = 0;
      FMaxValue = (Real)(FOptions.size() - 1);
      FDefValue = 0;
      FStepValue = 0.5;
    }
  }
}

Real CJes2CppParameter::ToSlider(Real AValue) 
{ 
  return floor((FMinValue + (FMaxValue - FMinValue) * AValue + (FStepValue / 2)) / FStepValue) * FStepValue; 
}

Real CJes2CppParameter::FromSlider(Real AValue) 
{  
  return (AValue - FMinValue) / (FMaxValue - FMinValue); 
}

void CJes2CppParameter::GetParameterName(PCHAR AString) 
{ 
  strcpy(AString, FDescription.c_str()); 
}

int CJes2CppParameter::GetOptionIndex(Real AValue) 
{ 
  return CLAMP((int)((AValue - FMinValue) * (FOptions.size() - 1) / (FMaxValue - FMinValue)), 0, FOptions.size() - 1); 
}

void CJes2CppParameter::GetDisplayFromSliderValue(PCHAR AString, Real AValue) 
{
  int LIndex = GetOptionIndex(AValue);
  if (LIndex >=0 && LIndex < (int)FOptions.size()) 
  {
    strcpy(AString, FOptions[LIndex].c_str()); 
  } else {
    sprintf(AString, "%.2f", AValue);
  }
}

void CJes2CppParameter::GetLabel(PCHAR AString, Real AValue) 
{
  strcpy(AString, FLabelString.c_str());
}

CJes2CppDescription::CJes2CppDescription()
{
  FChannelCount = FUniqueId = FVendorVersion = 0;
}

int CJes2CppDescription::FindParameterBySliderIndex(int AIndex)
{
  for (int LIndex = 0; LIndex < (int)FParameters.size(); LIndex++)
  {
    if (FParameters[LIndex].FIndex == AIndex)
    {
      return LIndex;
    }
  }
  return -1;
}
