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

/*
**
*/
Real CJes2CppMidi::FUN(midisend)(Real AIndex, Real AMsg1, Real AMsg2, Real AMsg3) 
{
  VeST_MidiSend(FVeST, (int) AIndex, (char) AMsg1, (char) AMsg2, (char) AMsg3);
  return AIndex;
}


/*
**
*/
Real CJes2CppMidi::FUN(midisend)(Real AIndex, Real AMsg1, Real AMsg23) 
{
  return FUN(midisend)(AIndex, AMsg1, (Real)(((int) AMsg23) & 0xFF), (Real)((((int) AMsg23) >> 8) & 0xFF));
}

/*
**
*/
Real CJes2CppMidi::FUN(midirecv)(Real& AIndex, Real& AMsg1, Real& AMsg23) 
{
  int LDeltaFrames;
  char LMidiData0, LMidiData1, LMidiData2; 
  VeST_MidiRecv(FVeST, &LDeltaFrames, &LMidiData0, &LMidiData1, &LMidiData2);
  AIndex = (Real) LDeltaFrames;
  AMsg1 = LMidiData0;
  AMsg23 = (Real)((LMidiData2 << 8) | LMidiData1);
  return AMsg1;
}

/*
**
*/
Real CJes2CppMidi::FUN(midisyx)(Real AIndex, Real AMsgPtr, Real ALength) 
{
  return AIndex;
}
