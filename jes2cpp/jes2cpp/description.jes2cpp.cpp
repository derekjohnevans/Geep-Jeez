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

int CJes2CppDescription::AddParam(int AIndex, Real ADefValue, Real AMinValue, Real AMaxValue, Real AStepValue, 
  const String& AFilePath, const String& AFileName, const String& ALabel, const String& AText)
{
  VAR(slider$)[AIndex] = ADefValue;
  FParameters.push_back(CJes2CppParameter(AIndex, ADefValue, AMinValue, AMaxValue, AStepValue, AFilePath, AFileName, ALabel, AText));
  FParameters[FParameters.size() - 1].Init();
  return FParameters.size() - 1;
}
