program project;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Forms,
  Interfaces, // this includes the LCL widgetset
  jeezinifile,
  JeezLabels,
  jeezresources,
  jeezsynedit,
  jeeztreeview,
  JeezUtils,
  Jes2Cpp,
  jes2cppcompiler,
  Jes2CppConstants,
  Jes2CppDescription,
  jes2cppeel,
  Jes2CppFileNames,
  Jes2CppFunction,
  Jes2CppFunctionIdentifiers,
  Jes2CppIdentifier,
  Jes2CppIdentString,
  Jes2CppImporter,
  Jes2CppIterate,
  Jes2CppLoop,
  Jes2CppMessageLog,
  Jes2CppModuleImporter,
  jes2cppparameter,
  Jes2CppParser,
  Jes2CppParserElements,
  Jes2CppParserExpression,
  jes2cppparserfunctions,
  Jes2CppParserLoops,
  Jes2CppParserOperator,
  Jes2CppParserSimple,
  Jes2CppPlatform,
  jes2cppprinter,
  jes2cppprocess,
  Jes2CppReference,
  Jes2CppSections,
  Jes2CppStrings,
  Jes2CppTextFileCache,
  Jes2CppToken,
  jes2cpptranslate,
  Jes2CppUtils,
  Jes2CppVariable,
  lazcontrols,
  soda,
  UJeezAbout,
  UJeezBuild,
  ujeezdata,
  UJeezEditor,
  ujeezide,
  ujeezmessages,
  UJeezOptions,
  ujeezproperties,
  ujeezsplash;

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
  Application.CreateForm(TJeezConsole, JeezConsole);
  Application.CreateForm(TJeezSplash, JeezSplash);
  Application.CreateForm(TJeezAbout, JeezAbout);
  Application.Run;
end.
