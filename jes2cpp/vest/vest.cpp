/*

VeST - A VST Flat Wrapper (ie: VST without the need for the SDK)

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

#include "vest.h"

#ifdef VEST_VST

#if !defined(VSTGUI_ENABLE_DEPRECATED_METHODS) || VSTGUI_ENABLE_DEPRECATED_METHODS != 1
#error Deprecated methods must be enabled. (#define VSTGUI_ENABLE_DEPRECATED_METHODS 1)
#endif

#if !defined(VSTGUI_FLOAT_COORDINATES)
#error Float coordinates must be enabled. (#define VSTGUI_FLOAT_COORDINATES 1)
#endif

// Let VSTGUI define the Windows version.
#undef _WIN32_WINNT

#include "audioeffectx.h"
#include "vstcontrols.h"
#include "aeffeditor.h"
#include "aeffguieditor.h"

#ifdef _WIN32
#if !defined(GDIPLUS) || GDIPLUS != 1
#error GdiPlus must be enabled. (#define GDIPLUS 1)
#endif // GDIPLUS
#include <gdiplus.h>
#endif

#endif // VEST_VST

VEST_HANDLE hInstance;

#ifdef VEST_VST
class CVeST : public AudioEffectX
{
  private:

    HVEST_DATA FData;
    CDrawContext* FDrawContext;
    int FMidiIn, FMidiOut;
    std::vector<CFontDesc*> FFonts;
    std::vector<VstMidiEvent> FMidiEvents;

  public:

    TVeSTCallBacks FVeSTCallBacks;

    CVeST(HVEST_DATA AData, TVeSTCallBacks* AVeSTCallBacks, audioMasterCallback AAudioMaster, VstInt32 ANumPrograms,
          VstInt32 ANumParams)
      : FDrawContext(NULL), FData(AData), FVeSTCallBacks(*AVeSTCallBacks), AudioEffectX(AAudioMaster, ANumPrograms,
          ANumParams)
    {
      FMidiIn = FMidiOut = 0;
      FMidiEvents.resize(1000);
      canProcessReplacing();
      canDoubleReplacing();
      if (FVeSTCallBacks.OnCreate) {
        FVeSTCallBacks.OnCreate((HVEST)this);
      }
    }
    ~CVeST()
    {
      for (int LIndex = 0; LIndex < (int)FFonts.size(); LIndex++) {
        FFonts[LIndex]->forget();
        FFonts[LIndex] = NULL;
      }
      if (FVeSTCallBacks.OnDestroy) {
        FVeSTCallBacks.OnDestroy((HVEST)this);
      }
    }
    HVEST_DATA GetData()
    {
      return FData;
    }
    CDrawContext* GetDrawContext()
    {
      return FDrawContext;
    }
    void SetDrawContext(CDrawContext* ADrawContext)
    {
      FDrawContext = ADrawContext;
    }
    CFontDesc* GetFont(const char* AName)
    {
      for (int LIndex = FFonts.size(); LIndex-- > 0;) {
        if (!stricmp(FFonts[LIndex]->getName(), AName)) {
          return FFonts[LIndex];
        }
      }
      FFonts.push_back(new CFontDesc(AName));
      return FFonts[FFonts.size() - 1];
    }
    virtual void open()
    {
      AudioEffectX::open();
      if (FVeSTCallBacks.OnOpen) {
        FVeSTCallBacks.OnOpen((HVEST)this);
      }
    }
    virtual void suspend()
    {
      AudioEffectX::suspend();
      if (FVeSTCallBacks.OnSuspend) {
        FVeSTCallBacks.OnSuspend((HVEST)this);
      }
    }
    virtual void resume()
    {
      AudioEffectX::resume();
      if (FVeSTCallBacks.OnResume) {
        FVeSTCallBacks.OnResume((HVEST)this);
      }
    }
    virtual void close()
    {
      AudioEffectX::close();
      if (FVeSTCallBacks.OnClose) {
        FVeSTCallBacks.OnClose((HVEST)this);
      }
    }
    virtual VstInt32 getVendorVersion()
    {
      return FVeSTCallBacks.OnGetVendorVersion ? FVeSTCallBacks.OnGetVendorVersion((HVEST)this) : 0;
    }
    virtual bool getVendorString(char* AString)
    {
      return FVeSTCallBacks.OnGetVendorString ? FVeSTCallBacks.OnGetVendorString((HVEST)this, AString) : false;
    }
    virtual bool getProductString(char* AString)
    {
      return FVeSTCallBacks.OnGetProductString ? FVeSTCallBacks.OnGetProductString((HVEST)this, AString) : false;
    }
    virtual bool getEffectName(char* AString)
    {
      return FVeSTCallBacks.OnGetEffectName ? FVeSTCallBacks.OnGetEffectName((HVEST)this, AString) : false;
    }
    virtual void setProgramName(char* AString)
    {
      if (FVeSTCallBacks.OnSetProgramName) {
        FVeSTCallBacks.OnSetProgramName((HVEST)this, AString);
      }
    }
    virtual void getProgramName(char* AString)
    {
      if (FVeSTCallBacks.OnGetProgramName) {
        FVeSTCallBacks.OnGetProgramName((HVEST)this, AString);
      }
    }
    virtual bool getProgramNameIndexed(VstInt32 ACategory, VstInt32 AIndex, char* AString)
    {
      return FVeSTCallBacks.OnGetProgramNameIndexed ? FVeSTCallBacks.OnGetProgramNameIndexed((HVEST)this, ACategory, AIndex,
             AString) : false;
    }
    virtual void setParameter(VstInt32 AIndex, float AValue)
    {
      if (FVeSTCallBacks.OnSetParameter) {
        FVeSTCallBacks.OnSetParameter((HVEST)this, AIndex, AValue);
      }
    }
    virtual float getParameter(VstInt32 AIndex)
    {
      return FVeSTCallBacks.OnGetParameter ? FVeSTCallBacks.OnGetParameter((HVEST)this, AIndex) : 0;
    }
    virtual void getParameterName(VstInt32 AIndex, char* AString)
    {
      if (FVeSTCallBacks.OnGetParameterName) {
        FVeSTCallBacks.OnGetParameterName((HVEST)this, AIndex, AString);
      }
    }
    virtual void getParameterLabel(VstInt32 AIndex, char* AString)
    {
      if (FVeSTCallBacks.OnGetParameterLabel) {
        FVeSTCallBacks.OnGetParameterLabel((HVEST)this, AIndex, AString);
      }
    }
    virtual void getParameterDisplay(VstInt32 AIndex, char* AString)
    {
      if (FVeSTCallBacks.OnGetParameterDisplay) {
        FVeSTCallBacks.OnGetParameterDisplay((HVEST)this, AIndex, AString);
      }
    }
    virtual void processReplacing(float** AInputs, float** AOutputs, VstInt32 ASampleFrames)
    {
      if (FVeSTCallBacks.OnProcessReplacing) {
        FVeSTCallBacks.OnProcessReplacing((HVEST)this, AInputs, AOutputs, ASampleFrames);
      }
    }
    virtual void processDoubleReplacing(double** AInputs, double** AOutputs, VstInt32 ASampleFrames)
    {
      if (FVeSTCallBacks.OnProcessDoubleReplacing) {
        FVeSTCallBacks.OnProcessDoubleReplacing((HVEST)this, AInputs, AOutputs, ASampleFrames);
      }
    }
    VstInt32 processEvents(VstEvents* AVstEvents)
    {
      for (int LIndex = 0; LIndex < AVstEvents->numEvents; LIndex++) {
        if (AVstEvents->events[LIndex]->type == kVstMidiType) {
          FMidiEvents[FMidiIn] = *((VstMidiEvent*) AVstEvents->events[LIndex]);
          if (++FMidiIn >= (int)FMidiEvents.size()) {
            FMidiIn = 0;
          }
        }
      }
      return 1;
    }
    VstInt32 canDo(char* AText)
    {
      if(strcmp(AText, "receiveVstMidiEvent") == 0) {
        return cEffect.flags | effFlagsIsSynth;
      }
      //return AudioEffectX::canDo(AText);
      return -1;
    }
    VstInt32 setChunk(void* AData, VstInt32 ASize, bool AIsPreset)
    {
      return FVeSTCallBacks.OnSetChunk ?
             FVeSTCallBacks.OnSetChunk((HVEST)this, AData, ASize, AIsPreset) :
             AudioEffectX::setChunk(AData, ASize, AIsPreset);
    }
    VstInt32 getChunk(void** AData, bool AIsPreset)
    {
      return FVeSTCallBacks.OnGetChunk ?
             FVeSTCallBacks.OnGetChunk((HVEST)this, AData, AIsPreset) :
             AudioEffectX::getChunk(AData, AIsPreset);
    }
    bool MidiRecv(int* ADeltaFrames, int* AMidiData0, int* AMidiData1, int* AMidiData2)
    {
      if (FMidiOut == FMidiIn) {
        *ADeltaFrames = *AMidiData0 = *AMidiData1 = *AMidiData2 = 0;
        return false;
      } else {
        *ADeltaFrames = FMidiEvents[FMidiOut].deltaFrames;
        *AMidiData0 = FMidiEvents[FMidiOut].midiData[0];
        *AMidiData1 = FMidiEvents[FMidiOut].midiData[1];
        *AMidiData2 = FMidiEvents[FMidiOut].midiData[2];
        if (++FMidiOut >= (int)FMidiEvents.size()) {
          FMidiOut = 0;
        }
      }
      return true;
    }
    bool MidiSend(int ADeltaFrames, int AMidiData0, int AMidiData1, int AMidiData2)
    {
      VstEvents LVstEvents;
      VstMidiEvent LMidiEvent;
      memset(&LVstEvents, 0, sizeof(LVstEvents));
      memset(&LMidiEvent, 0, sizeof(LMidiEvent));
      LVstEvents.numEvents = 1;
      LVstEvents.events[0] = (VstEvent*) &LMidiEvent;
      LMidiEvent.type = kVstMidiType;
      LMidiEvent.byteSize = sizeof(LMidiEvent);
      LMidiEvent.deltaFrames = ADeltaFrames;
      LMidiEvent.midiData[0] = AMidiData0;
      LMidiEvent.midiData[1] = AMidiData1;
      LMidiEvent.midiData[2] = AMidiData2;
      return sendVstEventsToHost(&LVstEvents);
    }
    bool MidiSysex(int ADeltaFrames, char* AData, int ALength)
    {
      VstEvents LVstEvents;
      VstMidiSysexEvent LMidiEvent;
      memset(&LVstEvents, 0, sizeof(LVstEvents));
      memset(&LMidiEvent, 0, sizeof(LMidiEvent));
      LVstEvents.numEvents = 1;
      LVstEvents.events[0] = (VstEvent*) &LMidiEvent;
      LMidiEvent.type = kVstSysExType;
      LMidiEvent.byteSize = sizeof(LMidiEvent);
      LMidiEvent.deltaFrames = ADeltaFrames;
      LMidiEvent.dumpBytes = ALength;
      LMidiEvent.sysexDump = AData;
      return sendVstEventsToHost(&LVstEvents);
    }
};

class CVeSTView : public CView
{
  private:

    CVeST* FVeST;

  public:

    CRect FRect;

    CVeSTView(CVeST* AVeST, const CRect& ARect) : FVeST(AVeST), FRect(ARect), CView(ARect) { }

    virtual void draw(CDrawContext* AContext)
    {
      if (FVeST->FVeSTCallBacks.OnDraw) {
        FVeST->SetDrawContext ( AContext);
        FVeST->FVeSTCallBacks.OnDraw((HVEST)FVeST, FRect.getWidth(), FRect.getHeight());
        FVeST->SetDrawContext ( NULL);
      }
    }
    CMouseEventResult onMouseDown(CPoint& APoint, const long& AButtons)
    {
      if (FVeST->FVeSTCallBacks.OnMouseDown) {
        FVeST->FVeSTCallBacks.OnMouseDown((HVEST)FVeST, APoint.x, APoint.y, AButtons);
      }
      return kMouseEventHandled;
    }
    CMouseEventResult onMouseUp(CPoint& APoint, const long& AButtons)
    {
      if (FVeST->FVeSTCallBacks.OnMouseUp) {
        FVeST->FVeSTCallBacks.OnMouseUp((HVEST)FVeST, APoint.x, APoint.y, AButtons);
      }
      return kMouseEventHandled;
    }
    CMouseEventResult onMouseMoved(CPoint& APoint, const long& AButtons)
    {
      if (FVeST->FVeSTCallBacks.OnMouseMoved) {
        FVeST->FVeSTCallBacks.OnMouseMoved((HVEST)FVeST, APoint.x, APoint.y, AButtons);
      }
      return kMouseEventHandled;
    }
    long onKeyDown(VstKeyCode& AKeyCode)
    {
      if (FVeST->FVeSTCallBacks.OnKeyDown) {
        FVeST->FVeSTCallBacks.OnKeyDown((HVEST)FVeST, AKeyCode.character, AKeyCode.modifier, AKeyCode.virt);
      }
      return 1;
    }
    long onKeyUp(VstKeyCode& AKeyCode)
    {
      if (FVeST->FVeSTCallBacks.OnKeyUp) {
        FVeST->FVeSTCallBacks.OnKeyUp((HVEST)FVeST, AKeyCode.character, AKeyCode.modifier, AKeyCode.virt);
      }
      return 1;
    }
};

class CVeSTEditor : public AEffGUIEditor
{
  private:

    CVeST* FVeST;
    CVeSTView* FView;

  public:

    int FWidth, FHeight;

    CVeSTEditor(CVeST* AVeST, int AWidth, int AHeight):  FView(NULL), FVeST(AVeST), FWidth(AWidth), FHeight(AHeight),
      AEffGUIEditor(AVeST)
    {
      rect.left = rect.top = 0;
      rect.right = AWidth;
      rect.bottom = AHeight;
    }

    CVeSTView* GetView()
    {
      return FView;
    }
    CFrame* GetFrame()
    {
      return frame;
    }
    bool open(void* ASystemWindow)
    {
      frame = new CFrame(CRect(0, 0, FWidth, FHeight), ASystemWindow, this);
      frame->addView(FView = new CVeSTView(FVeST, CRect(0, 0, FWidth, FHeight)));
      return true;
    }
    void close()
    {
      if (frame) {
        frame->forget();
        frame = NULL;
      }
    }
    void idle()
    {
      if (FView && frame && FVeST->FVeSTCallBacks.OnIdle) {
        FVeST->FVeSTCallBacks.OnIdle((HVEST)FVeST);
      }
      AEffGUIEditor::idle();
    }
};

class CBitmapExt : public CBitmap
{
  public:
    CBitmapExt(PCHAR AFileName)
    {
      loadFromPath(AFileName);
    }
};

class CVeSTBitmap
{
  public:

    CBitmap* FBitmap;

    CVeSTBitmap()
    {
      FBitmap = NULL;
    }
    ~CVeSTBitmap()
    {
      Clear();
    }
    VOID Clear()
    {
      if (FBitmap) {
        FBitmap->forget();
        FBitmap = NULL;
      }
    }
    bool LoadFromFile(const std::string AFileName)
    {
      Clear();
#ifdef WIN32
      std::wstring LFileName;
      LFileName.assign(AFileName.begin(), AFileName.end());
      Gdiplus::Bitmap LBitmap(LFileName.c_str());
      if (LBitmap.GetLastStatus() == Gdiplus::Ok) {
        FBitmap = new CBitmap(&LBitmap);
        return true;
      }
#else
      // Untested Code for Non-Windows
      FBitmap = new CBitmapExt((PCHAR)AFileName.c_str());
      if (!FBitmap->isLoaded()) {
        FBitmap->forget();
        FBitmap = NULL;
      }
#endif // WIN32
      return false;
    }
};
#endif // VEST_VST

#ifdef VEST_LV1
// LADSPA CallBacks

static LADSPA_Handle LADSPA_Instantiate(const LADSPA_Descriptor* ADescriptor, unsigned long ASampleRate);
static void LADSPA_ConnectPort(LADSPA_Handle AVeST, unsigned long AIndex, LADSPA_Data* AData);
void LADSPA_Activate(LADSPA_Handle AVeST);
void LADSPA_Deactivate(LADSPA_Handle AVeST);
static void LADSPA_Run(LADSPA_Handle AVeST, unsigned long ASampleCount);
static void LADSPA_Cleanup(LADSPA_Handle AVeST);

class CVeST
{
  private:

    std::vector<char*> FPortNames;
    std::vector<LADSPA_PortDescriptor> FPortDescriptors;
    std::vector<std::string> FPortStrings;
    std::vector<LADSPA_PortRangeHint> FPortHints;
    std::string FProductString, FVendorString, FEffectName;
    std::vector<float> FParamValues;
    std::vector<LADSPA_Data*> FPortData;
    TVeSTCallBacks FCallBacks;
    int FNumParams, FNumInputs, FNumOutputs, FUniqueID, FSampleRate;
    HVEST_DATA FData;
    bool FActive;

  public:

    LADSPA_Descriptor FDescriptor;

  public:

    CVeST(HVEST_DATA AData, TVeSTCallBacks* ACallBacks, int AProgramCount, int AParamCount)
    {
      char LBuffer[256];
      FNumParams = AParamCount;
      FNumInputs = FNumOutputs = FUniqueID = FSampleRate = FActive = 0;
      FData = AData;
      FCallBacks = *ACallBacks;
      memset(&FDescriptor, 0, sizeof(FDescriptor));
      if (FCallBacks.OnCreate) {
        FCallBacks.OnCreate((HVEST)this);
      }
      if (FCallBacks.OnGetEffectName) {
        FCallBacks.OnGetEffectName((HVEST)this, LBuffer);
        FEffectName = LBuffer;
      }
      if (FCallBacks.OnGetProductString) {
        FCallBacks.OnGetProductString((HVEST)this, LBuffer);
        FProductString = LBuffer;
      }
      if (FCallBacks.OnGetVendorString) {
        FCallBacks.OnGetVendorString((HVEST)this, LBuffer);
        FVendorString = LBuffer;
      }
      // Setup Properties and ports.
      FDescriptor.ImplementationData = this;
      FDescriptor.Properties = LADSPA_PROPERTY_HARD_RT_CAPABLE;
      FDescriptor.PortCount = FNumInputs + FNumOutputs + AParamCount;
      // Effect properties.
      FDescriptor.UniqueID = FUniqueID;
      FDescriptor.Label = FEffectName.c_str();
      FDescriptor.Name = FProductString.c_str();
      FDescriptor.Maker = FVendorString.c_str();
      FDescriptor.Copyright = FVendorString.c_str();
      // Resize port arrays.
      FPortData.resize(FDescriptor.PortCount);
      FPortNames.resize(FDescriptor.PortCount);
      FPortStrings.resize(FDescriptor.PortCount);
      FPortDescriptors.resize(FDescriptor.PortCount);
      FPortHints.resize(FDescriptor.PortCount);
      FParamValues.resize(AParamCount);
      // Assign arrays to descriptor.
      FDescriptor.PortDescriptors = &FPortDescriptors[0];
      FDescriptor.PortNames = &FPortNames[0];
      FDescriptor.PortRangeHints = &FPortHints[0];
      // Setup each port.
      int LPortIndex = 0;
      // Setup input ports.
      for (int LIndex = 0; LIndex < FNumInputs; LIndex++) {
        FPortDescriptors[LPortIndex] = LADSPA_PORT_INPUT | LADSPA_PORT_AUDIO;
        FPortStrings[LPortIndex] = "INPUT";
        FPortNames[LPortIndex] = (char*)FPortStrings[LPortIndex].c_str();
        FPortHints[LPortIndex].HintDescriptor = LADSPA_HINT_DEFAULT_NONE;
        FPortHints[LPortIndex].LowerBound = -1;
        FPortHints[LPortIndex].UpperBound = 1;
        LPortIndex++;
      }
      // Setup output ports.
      for (int LIndex = 0; LIndex < FNumOutputs; LIndex++) {
        FPortDescriptors[LPortIndex] = LADSPA_PORT_OUTPUT | LADSPA_PORT_AUDIO;
        FPortStrings[LPortIndex] = "OUTPUT";
        FPortNames[LPortIndex] = (char*)FPortStrings[LPortIndex].c_str();
        FPortHints[LPortIndex].HintDescriptor = LADSPA_HINT_DEFAULT_NONE;
        FPortHints[LPortIndex].LowerBound = -1;
        FPortHints[LPortIndex].UpperBound = 1;
        LPortIndex++;
      }
      // Setup control ports.
      for (int LIndex = 0; LIndex < AParamCount; LIndex++) {
        FPortDescriptors[LPortIndex] = LADSPA_PORT_INPUT | LADSPA_PORT_CONTROL;
        if (FCallBacks.OnGetParameterName) {
          FCallBacks.OnGetParameterName((HVEST)this, LIndex, LBuffer);
        } else {
          strcpy(LBuffer, "CONTROL");
        }
        FPortStrings[LPortIndex] = LBuffer;
        FPortNames[LPortIndex] = (char*)FPortStrings[LPortIndex].c_str();
        FPortHints[LPortIndex].HintDescriptor = LADSPA_HINT_BOUNDED_BELOW  | LADSPA_HINT_BOUNDED_ABOVE |
                                                LADSPA_HINT_DEFAULT_MIDDLE;
        FPortHints[LPortIndex].LowerBound = 0;
        FPortHints[LPortIndex].UpperBound = 1;
        FParamValues[LIndex] = -100;
        LPortIndex++;
      }
      // LADSPA callbacks.
      FDescriptor.instantiate = LADSPA_Instantiate;
      FDescriptor.connect_port = LADSPA_ConnectPort;
      FDescriptor.activate = LADSPA_Activate;
      FDescriptor.deactivate = LADSPA_Deactivate;
      FDescriptor.run = LADSPA_Run;
      FDescriptor.cleanup = LADSPA_Cleanup;
      // Unused fields.
      FDescriptor.run_adding = NULL;
      FDescriptor.set_run_adding_gain = NULL;
    }
    ~CVeST()
    {
      if (FCallBacks.OnDestroy) {
        FCallBacks.OnDestroy((HVEST)this);
      }
    }
    HVEST_DATA GetData()
    {
      return FData;
    }
    void SetNumInputs(int AValue)
    {
      FNumInputs = AValue;
    }
    void SetNumOutputs(int AValue)
    {
      FNumOutputs = AValue;
    }
    void SetUniqueID(int AValue)
    {
      FUniqueID = AValue;
    }
    int GetSampleRate()
    {
      return FSampleRate;
    }
    int GetNumInputs()
    {
      return FNumInputs;
    }
    int GetNumOutputs()
    {
      return FNumOutputs;
    }
    void SetPortData(int AIndex, LADSPA_Data* AData)
    {
      FPortData[AIndex] = AData;
    }
    void Run(int ASamples)
    {
      int LControls = FNumInputs + FNumOutputs;
      for (int LIndex = 0; LIndex < FNumParams; LIndex++) {
        if (FParamValues[LIndex] != *FPortData[LIndex + LControls]) {
          FParamValues[LIndex] = *FPortData[LIndex + LControls];
          if (FCallBacks.OnSetParameter) {
            FCallBacks.OnSetParameter((HVEST)this, LIndex, FParamValues[LIndex]);
          }
        }
      }
      if (FCallBacks.OnProcessReplacing) {
        FCallBacks.OnProcessReplacing((HVEST)this, &FPortData[0], &FPortData[FNumInputs], ASamples);
      }
    }
    void Open(int ASampleRate)
    {
      FSampleRate = ASampleRate;
      if (FCallBacks.OnOpen) {
        FCallBacks.OnOpen((HVEST)this);
      }
    }
    void Close()
    {
      if (FCallBacks.OnClose) {
        FCallBacks.OnClose((HVEST)this);
      }
    }
    void Resume()
    {
      if (FCallBacks.OnResume) {
        FCallBacks.OnResume((HVEST)this);
      }
    }
    void Suspend()
    {
      if (FCallBacks.OnSuspend) {
        FCallBacks.OnSuspend((HVEST)this);
      }
    }
};

static LADSPA_Handle LADSPA_Instantiate(const LADSPA_Descriptor* ADescriptor, unsigned long ASampleRate)
{
  return ((CVeST*)ADescriptor->ImplementationData)->Open(ASampleRate), ADescriptor->ImplementationData;
}

static void LADSPA_ConnectPort(LADSPA_Handle AVeST, unsigned long AIndex, LADSPA_Data* AData)
{
  ((CVeST*)AVeST)->SetPortData(AIndex,  AData);
}

void LADSPA_Activate(LADSPA_Handle AVeST)
{
  ((CVeST*)AVeST)->Resume();
}

void LADSPA_Deactivate(LADSPA_Handle AVeST)
{
  ((CVeST*)AVeST)->Suspend();
}

static void LADSPA_Run(LADSPA_Handle AVeST, unsigned long ASampleCount)
{
  ((CVeST*)AVeST)->Run(ASampleCount);
}

static void LADSPA_Cleanup(LADSPA_Handle AVeST)
{
  ((CVeST*)AVeST)->Close();
}
#endif // VEST_LV1

extern "C" {

  VEST_INIT
  {
#ifdef VEST_VST
    if (!((audioMasterCallback)AAudioMaster)(0, audioMasterVersion, 0, 0, 0, 0))
    {
      return NULL;
    }
    return (HVEST) new CVeST(AData, AVeSTCallBacks, (audioMasterCallback) AAudioMaster, AProgramCount, AParamCount);
#endif // VEST_VST
#ifdef VEST_LV1
    return (HVEST) new CVeST(AData, AVeSTCallBacks, AProgramCount, AParamCount);
#endif // VEST_LV1
  }

#define Get_VeST(X) (CVeST*)X; if (!X) return 0;
#define Get_VeST_DrawContext(X) Get_VeST(X); if (!((CVeST*)X)->GetDrawContext()) return 0;

#ifdef VEST_VST
  VEST_EXPORT HVEST_AEFFECT WINAPI VeST_GetAEffect(HVEST AVeST)
  {
    CVeST* LVeST = Get_VeST(AVeST);
    return (HVEST_AEFFECT)LVeST->getAeffect();
  }
#endif // VEST_VST
#ifdef VEST_LV1
  VEST_EXPORT LADSPA_Descriptor* VEST_WINAPI VeST_GetLADSPA(HVEST AVeST)
  {
    return &((CVeST*)AVeST)->FDescriptor;
  }
#endif // VEST_LV1
  VEST_GETDATA {
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->GetData();
  }

  VEST_GETNUMINPUTS {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getAeffect()->numInputs;
#endif // VEST_VST
#ifdef VEST_LV1
    return ((CVeST*)AVeST)->GetNumInputs();
#endif // VEST_LV1
  }

  VEST_GETNUMOUTPUTS {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getAeffect()->numOutputs;
#endif // VEST_VST
#ifdef VEST_LV1
    return ((CVeST*)AVeST)->GetNumOutputs();
#endif // VEST_LV1
  }

  VEST_SETNUMINPUTS {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->setNumInputs(ACount), true;
#endif // VEST_VST
#ifdef VEST_LV1
    return ((CVeST*)AVeST)->SetNumInputs(ACount), true;
#endif // VEST_LV1
  }

  VEST_SETNUMOUTPUTS {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->setNumOutputs(ACount), true;
#endif // VEST_VST
#ifdef VEST_LV1
    return ((CVeST*)AVeST)->SetNumOutputs(ACount), true;
#endif // VEST_LV1
  }

  VEST_SETUNIQUEID {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->setUniqueID(AValue), true;
#endif // VEST_VST
#ifdef VEST_LV1
    return ((CVeST*)AVeST)->SetUniqueID(AValue), true;
#endif // VEST_LV1
  }

  VEST_GETSAMPLERATE {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getSampleRate();
#endif // VEST_VST
#ifdef VEST_LV1
    return (float)((CVeST*)AVeST)->GetSampleRate();
#endif // VEST_LV1
  }

  VEST_GETTEMPO {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getTimeInfo(kVstTempoValid)->tempo;
#else
    return 0;
#endif // VEST_VST
  }

  VEST_GETTRANSPORTRECORDING {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getTimeInfo(kVstTransportRecording)->flags & kVstTransportRecording;
#else
    return false;
#endif // VEST_VST
  }

  VEST_GETTRANSPORTPLAYING {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getTimeInfo(kVstTransportPlaying)->flags & kVstTransportPlaying;
#else
    return false;
#endif // VEST_VST
  }
  VEST_GETPPQPOS {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getTimeInfo(kVstPpqPosValid)->ppqPos;
#else
    return 0;
#endif // VEST_VST
  }

  VEST_GETBARSTARTPOS {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getTimeInfo(kVstBarsValid)->barStartPos;
#else
    return 0;
#endif // VEST_VST
  }

  VEST_GETTIMEINFO3 {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    VstTimeInfo* LTimeInfo = LVeST->getTimeInfo(kVstTempoValid | kVstTimeSigValid);
    if (LTimeInfo)
    {
      if (ATempo) {
        *ATempo = LTimeInfo->tempo;
      }
      if (ASigNumerator) {
        *ASigNumerator = LTimeInfo->timeSigNumerator;
      }
      if (ASigDenominator) {
        *ASigDenominator = LTimeInfo->timeSigDenominator;
      }
      return true;
    }
#endif // VEST_VST
    return false;
  }

  VEST_GETBLOCKSIZE {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getBlockSize();
#else
    return 0;
#endif // VEST_VST
  }

  VEST_UPDATEDISPLAY {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->updateDisplay();
#else
    return false;
#endif // VEST_VST
  }

  VEST_INVALIDATEGRAPHICS {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    CVeSTEditor* LEditor = (CVeSTEditor*) LVeST->getEditor();
    if (LEditor)
    {
      CVeSTView* LView = LEditor->GetView();
      if (LView) {
        return LView->invalidRect(LView->FRect), true;
      }
    }
    return false;
#else
    return false;
#endif // VEST_VST
  }

  VEST_SETINITIALDELAY {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->setInitialDelay(ADelay), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_SETISSYNTH {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->isSynth(AState), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_MIDISYSEX {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->MidiSysex(ADeltaFrames, AData, ALength);
#else
    return false;
#endif // VEST_VST
  }
  VEST_MIDISEND {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->MidiSend(ADeltaFrames, AMidiData0, AMidiData1, AMidiData2);
#else
    return false;
#endif // VEST_VST
  }

  VEST_MIDIRECV {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->MidiRecv(ADeltaFrames, AMidiData0,  AMidiData1,  AMidiData2);
#else
    return false;
#endif // VEST_VST
  }

  VEST_SETGRAPHICSSIZE {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getEditor() ? false : (LVeST->setEditor(new CVeSTEditor(LVeST, AWidth, AHeight)), true);
#else
    return false;
#endif // VEST_VST
  }

  VEST_GETGRAPHICSSIZE {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    CVeSTEditor* LEditor = (CVeSTEditor*)LVeST->getEditor();
    if (LEditor)
    {
      *AWidth = LEditor->FWidth;
      *AHeight = LEditor->FHeight;
      return true;
    }
    return false;
#else
    return false;
#endif // VEST_VST
  }

  VEST_SETDRAWMODE {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->setDrawMode((CDrawMode)AMode), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_SETFONTCOLOR {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->setFontColor(MakeCColor(AR, AG, AB, AA)), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_SETFILLCOLOR {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->setFillColor(MakeCColor(AR, AG, AB, AA)), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_SETFRAMECOLOR {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->setFrameColor(MakeCColor(AR, AG, AB, AA)), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_SETFONT {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->setFont(LVeST->GetFont(AName), ASize, AStyle), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_GETSTRINGWIDTH {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->getStringWidth(AString);
#else
    return 0;
#endif // VEST_VST
  }

  VEST_GETFONTSIZE {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->getFontSize();
#else
    return 0;
#endif // VEST_VST
  }

  VEST_MOVETO {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->moveTo(CPoint(AX, AY)), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_LINETO {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->lineTo(CPoint(AX, AY)), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_DRAWRECT {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->drawRect(CRect(AX1, AY1, AX2, AY2), (CDrawStyle)AStyle), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_DRAWELLIPSE {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->drawEllipse(CRect(AX1, AY1, AX2, AY2), (CDrawStyle)AStyle), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_DRAWSTRING {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->drawString(AString, CRect(AX1, AY1, AX2, AY2), AIsOpaque, (CHoriTxtAlign)AAlign), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_DRAWSTRINGUTF8_XY {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->drawStringUTF8(AString, CPoint(AX, AY), AAntiAlias), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_DRAWSTRINGUTF8 {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->drawStringUTF8(AString, CRect(AX1, AY1, AX2, AY2), (CHoriTxtAlign)AAlign, AAntiAlias), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_DRAWPOINT {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    return LVeST->GetDrawContext()->drawPoint(CPoint(AX, AY), MakeCColor(AR, AG, AB, AA)), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_GETPOINT {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    // Note: getPoint is DEPRECATED and not avaliable on the mac
    CColor LColor = LVeST->GetDrawContext()->getPoint(CPoint(AX, AY));
    * AR = LColor.red;
    * AG = LColor.green;
    * AB = LColor.blue;
    * AA = LColor.alpha;
    return true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_BITMAP_CREATE {
#ifdef VEST_VST
    return (HVEST_BITMAP) new CVeSTBitmap();
#else
    return NULL;
#endif // VEST_VST
  }

  VEST_BITMAP_FREE {
#ifdef VEST_VST
    CVeSTBitmap* LBitmap = (CVeSTBitmap*)ABitmap;
    return LBitmap ? delete LBitmap, true : false;
#else
    return false;
#endif // VEST_VST
  }

  VEST_BITMAP_LOADFROMFILE {
#ifdef VEST_VST
    CVeSTBitmap* LBitmap = (CVeSTBitmap*)ABitmap;
    return LBitmap ? LBitmap->LoadFromFile(AFileName) : false;
#else
    return false;
#endif // VEST_VST
  }

  VEST_BITMAP_GETWIDTH {
#ifdef VEST_VST
    CVeSTBitmap* LBitmap = (CVeSTBitmap*)ABitmap;
    return LBitmap && LBitmap->FBitmap ? LBitmap->FBitmap->getWidth() : false;
#else
    return 0;
#endif // VEST_VST
  }

  VEST_BITMAP_GETHEIGHT {
#ifdef VEST_VST
    CVeSTBitmap* LBitmap = (CVeSTBitmap*)ABitmap;
    return LBitmap && LBitmap->FBitmap ? LBitmap->FBitmap->getHeight() : false;
#else
    return 0;
#endif // VEST_VST
  }

  VEST_BITMAP_GETTRANSPARENTCOLOR {
#ifdef VEST_VST
    CVeSTBitmap* LBitmap = (CVeSTBitmap*)ABitmap;
    if (LBitmap && LBitmap->FBitmap)
    {
      CColor LColor = LBitmap->FBitmap->getTransparentColor();
      *AR = LColor.red;
      *AG = LColor.green;
      *AB = LColor.blue;
      *AA = LColor.alpha;
      return true;
    }
    return false;
#else
    return false;
#endif // VEST_VST
  }

  VEST_BITMAP_SETTRANSPARENTCOLOR {
#ifdef VEST_VST
    CVeSTBitmap* LBitmap = (CVeSTBitmap*)ABitmap;
    return LBitmap && LBitmap->FBitmap ? LBitmap->FBitmap->setTransparentColor(MakeCColor(AR, AG, AB, AA)), true : false;
#else
    return false;
#endif // VEST_VST
  }

  VEST_BITMAP_GETNOALPHA {
#ifdef VEST_VST
    CVeSTBitmap* LBitmap = (CVeSTBitmap*)ABitmap;
    return LBitmap && LBitmap->FBitmap ? LBitmap->FBitmap->getNoAlpha() : false;
#else
    return false;
#endif // VEST_VST
  }

  VEST_BITMAP_SETNOTALPHA {
#ifdef VEST_VST
    CVeSTBitmap* LBitmap = (CVeSTBitmap*)ABitmap;
    return LBitmap && LBitmap->FBitmap ? LBitmap->FBitmap->setNoAlpha(AState), true : false;
#else
    return false;
#endif // VEST_VST
  }

  VEST_BITMAP_DRAW {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    CVeSTBitmap* LBitmap = (CVeSTBitmap*)ABitmap;
    if (LBitmap && LBitmap->FBitmap)
    {
      CRect LRect(AX1, AY1, AX2, AY2);
      CPoint LPoint(AX, AY);
      return LBitmap->FBitmap->draw(LVeST->GetDrawContext(), LRect, LPoint), true;
    }
    return false;
#else
    return false;
#endif // VEST_VST
  }

  VEST_BITMAP_DRAW_ALPHABLEND {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    CVeSTBitmap* LBitmap = (CVeSTBitmap*)ABitmap;
    if (LBitmap && LBitmap->FBitmap)
    {
      CRect LRect(AX1, AY1, AX2, AY2);
      CPoint LPoint(AX, AY);
      return LBitmap->FBitmap->drawAlphaBlend(LVeST->GetDrawContext(), LRect, LPoint, AAlpha), true;
    }
    return false;
#else
    return false;
#endif // VEST_VST
  }

  VEST_BITMAP_DRAW_TRANSPARENT {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST_DrawContext(AVeST);
    CVeSTBitmap* LBitmap = (CVeSTBitmap*)ABitmap;
    if (LBitmap && LBitmap->FBitmap)
    {
      CRect LRect(AX1, AY1, AX2, AY2);
      CPoint LPoint(AX, AY);
      return LBitmap->FBitmap->drawTransparent(LVeST->GetDrawContext(), LRect, LPoint), true;
    }
    return false;
#else
    return false;
#endif // VEST_VST
  }

  VEST_GETHOSTLANGUAGE {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getHostLanguage();
#else
    return 0;
#endif // VEST_VST
  }

  VEST_GETHOSTPRODUCTSTRING {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getHostProductString(AString);
#else
    return false;
#endif // VEST_VST
  }

  VEST_GETHOSTVENDORSTRING {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getHostVendorString(AString);
#else
    return false;
#endif // VEST_VST
  }

  VEST_GETHOSTVENDORVERSION {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getHostVendorVersion();
#else
    return 0;
#endif // VEST_VST
  }

  VEST_GETMASTERVERSION {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getMasterVersion();
#else
    return 0;
#endif // VEST_VST
  }

  VEST_GETCURRENTUNIQUEID {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->getCurrentUniqueId();
#else
    return 0;
#endif // VEST_VST
  }

  VEST_MASTERIDLE {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->masterIdle(), true;
#else
    return false;
#endif // VEST_VST
  }

  VEST_PROGRAMSARECHUNKS {
#ifdef VEST_VST
    CVeST* LVeST = Get_VeST(AVeST);
    return LVeST->programsAreChunks(AState), true;
#else
    return false;
#endif // VEST_VST
  }
#ifdef _WIN32
  bool VEST_WINAPI DllMain(VEST_HANDLE hInst, uint32_t dwReason, void* lpvReserved)
  {
    hInstance = hInst;
    /* I think this is a bad idea.
        char LFileName[MAX_PATH];
        GetModuleFileNameA((HMODULE)hInstance, LFileName, MAX_PATH);
        char* LEndOfPath = strrchr(LFileName, '\\');
        if (LEndOfPath) {
          LEndOfPath[1] = 0;
        }
        SetCurrentDirectoryA(LFileName);
    */
    return true;
  }
#endif
}

