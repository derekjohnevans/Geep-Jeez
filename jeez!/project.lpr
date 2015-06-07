program project;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Forms,
  Interfaces, // this includes the LCL widgetset
  jeezinifile,
  jeezresources,
  jeezsynedit,
  jeeztreeview,
  JeezUtils,
  Jes2CppConstants,
  Jes2CppDescription,
  Jes2CppEat,
  Jes2CppFileNames,
  Jes2CppFunction,
  Jes2CppIdentifier,
  Jes2CppIdentString,
  Jes2CppImporter,
  Jes2CppLoop,
  Jes2CppMessageLog,
  Jes2CppParser,
  Jes2CppParserElements,
  Jes2CppParserExpression,
  jes2cppparserfunctions,
  Jes2CppParserOperator, jes2cppprinter,
  Jes2CppPlatform,
  jes2cppprocess,
  Jes2CppReference,
  Jes2CppSections,
  jes2cpptranslate,
  Jes2Cpp,
  Jes2CppUtils, jes2cppeel, jes2cppparameter,
  Jes2CppVariable, jes2cppcompiler,
  lazcontrols,
  UJeezBuild,
  ujeezdata,
  UJeezEditor,
  ujeezguieditor,
  ujeezide,
  ujeezmessages,
  UJeezOptions,
  ujeezproperties,
  ujeezsplash, Jes2CppModuleImporter, Jes2CppStrings, JeezLabels, 
Jes2CppIterate, Jes2CppParserLoops, Jes2CppToken;

{$R *.res}

begin
  Application.Title := 'Geep Jeez!';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TJeezIde, JeezIde);
  Application.CreateForm(TJeezOptions, JeezOptions);
  Application.CreateForm(TJeezProperties, JeezProperties);
  Application.CreateForm(TJeezBuild, JeezBuild);
  Application.CreateForm(TJeezData, JeezData);
  Application.CreateForm(TJeezGuiEditor, JeezGuiEditor);
  Application.CreateForm(TJeezMessages, JeezMessages);
  Application.CreateForm(TJeezSplash, JeezSplash);
  Application.Run;
end.
