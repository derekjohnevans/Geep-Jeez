(*

Jes2Cpp - Jesusonic Script to C++ Transpiler

Created by Geep Software

Author:   Derek John Evans (derek.john.evans@hotmail.com)
Website:  http://www.wascal.net/music/

Copyright (C) 2015 Derek John Evans

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*)

unit Jes2CppConstants;

{$MODE DELPHI}

interface

// Do not translate these constants

const

  GiColWidth = 100;
  GiTabSize = 2;

const

  GsJes2CppName = 'Jes2Cpp';
  GsJes2CppSlogan = 'The Easy Way to Create Audio Plugins (VST/LADSPA)';
  GsJes2CppDescription = 'Jesusonic to C++ Transpiler';
  GsJes2CppVersion = '2.5';
  GsJes2CppBuildDate = 'BUILD:8thAugustJuly2015';
  GsJes2CppTitle = GsJes2CppName + ' (v' + GsJes2CppVersion + ') - ' + GsJes2CppDescription;
  GsJes2CppWebsite = 'http://www.wascal.net/music/';
  GsJes2CppCopyright = 'Copyright (C) 2015 Derek John Evans';
  GsJes2CppLicense = GsJes2CppName + ' has been released under LGPL';

const

  CharAmpersand = Char('&');
  CharAsterisk = Char('*');
  CharAtSymbol = Char('@');
  CharClosingBrace = Char('}');
  CharClosingBracket = Char(']');
  CharClosingParenthesis = Char(')');
  CharColon = Char(':');
  CharComma = Char(',');
  CharCR = Char(#13);
  CharDollar = Char('$');
  CharDot = Char('.');
  CharEqualSign = Char('=');
  CharExclamation = Char('!');
  CharGreaterThan = Char('>');
  CharHash = Char('#');
  CharLessThan = Char('<');
  CharLF = Char(#10);
  CharMinusSign = Char('-');
  CharNull = Char(#0);
  CharOpeningBrace = Char('{');
  CharOpeningBracket = Char('[');
  CharOpeningParenthesis = Char('(');
  CharPercent = Char('%');
  CharPlusSign = Char('+');
  CharQuestionMark = Char('?');
  CharQuoteDouble = Char('"');
  CharQuoteSingle = Char('''');
  CharSemiColon = Char(';');
  CharSlashBackward = Char('\');
  CharSlashForward = Char('/');
  CharSpace = Char(' ');
  CharTab = Char(#9);
  CharUnderscore = Char('_');
  CharVerticalBar = Char('|');

const

  Gs32Bit = '32bit';
  Gs64Bit = '64bit';
  GsCaption = 'Caption';
  GsClose = 'Close';
  GsCount = 'Count';
  GsCreate = 'Create';
  GsDestroy = 'Destroy';
  GsDLL = 'DLL';
  GsDoBlock = 'DoBlock';
  GsDoClose = 'DoClose';
  GsDoGfx = 'DoGfx';
  GsDoIdle = 'DoIdle';
  GsDoInit = 'DoInit';
  GsDoLoop = 'DoLoop';
  GsDoOpen = 'DoOpen';
  GsDoResume = 'DoResume';
  GsDoSample = 'DoSample';
  GsDoProcess = 'DoProcess';
  GsDoSerialize = 'DoSerialize';
  GsDoSlider = 'DoSlider';
  GsDoSuspend = 'DoSuspend';
  GsDraw = 'Draw';
  GsEffect = 'Effect';
  GsEffectName = 'EffectName';
  GsFile = 'File';
  GsGetChunk = 'GetChunk';
  GsGetEffectName = 'GetEffectName';
  GsGetParameter = 'GetParameter';
  GsGetParameterDisplay = 'GetParameterDisplay';
  GsGetParameterLabel = 'GetParameterLabel';
  GsGetParameterName = 'GetParameterName';
  GsGetProductString = 'GetProductString';
  GsGetProgramName = 'GetProgramName';
  GsGetProgramNameIndexed = 'GetProgramNameIndexed';
  GsGetVendorString = 'GetVendorString';
  GsGetVendorVersion = 'GetVendorVersion';
  GsIdle = 'Idle';
  GsInstallPath = 'InstallPath';
  GsItemIndex = 'ItemIndex';
  GsItems1 = 'Items[%d]';
  GsLine = 'Line';
  GsLJes2Cpp = 'LJes2Cpp';
  GsMouseDown = 'MouseDown';
  GsMouseMoved = 'MouseMoved';
  GsMouseUp = 'MouseUp';
  GsOpen = 'Open';
  GsPath = 'Path';
  GsPlugin = 'Plugin';
  GsProcessDoubleReplacing = 'ProcessDoubleReplacing';
  GsProcessReplacing = 'ProcessReplacing';
  GsProductString = 'ProductString';
  GsResume = 'Resume';
  GsSave = 'Save';
  GsSelected = 'Selected';
  GsSetChunk = 'SetChunk';
  GsSetParameter = 'SetParameter';
  GsSetProgramName = 'SetProgramName';
  GsSuspend = 'Suspend';
  GsText = 'Text';
  GsTJes2Cpp = 'TJes2Cpp';
  GsTJes2CppEffect = GsTJes2Cpp + GsEffect;
  GsTJes2CppEffectVst = GsTJes2CppEffect + 'Vst';
  GsUniqueId = 'UniqueId';
  GsValue = 'Value';
  GsVendorString = 'VendorString';
  GsVendorVersion = 'VendorVersion';
  GsVST = 'VST';
  GsVstPath = 'VstPath'; // Obsolete

const

  GsLineFile2 = GsLine + '=''%d'' ' + GsFile + '=''%s''';
  GsErrorLineFile3 = '%s @ ' + GsLineFile2;

// English Strings

resourcestring

  SMsgAbortingCompilationPleaseWait = 'Aborting Compilation - Please wait...';
  SMsgAlreadyDefined1 = '''%s'' is already defined.';
  SMsgAlreadyDefinedAsGlobal1 = '''%s'' is already defined as global.';
  SMsgAlreadyDefinedAsInstance1 = '''%s'' is already defined as an instance.';
  SMsgAlreadyDefinedAsLocal1 = '''%s'' is already defined as local.';
  SMsgAlreadyDefinedAsParameter1 = '''%s'' is already defined as a parameter.';
  SMsgAlreadyDefinedAsStatic1 = '''%s'' is already defined as a static.';
  SMsgArchitecture = 'Architecture';
  SMsgArrayElement = 'Array Element';
  SMsgAssignmentsInFunctionCall = 'Assignments in function calls are not portable.';
  SMsgAssignmentsInStatements = 'Assignments in statements are not portable.';
  SMsgCompilationAborted = 'User selected to abort.';
  SMsgCompilationFailed = 'Compilation failed. (Please check message log)';
  SMsgCompilerNotSelected =
    'No compiler selected. Note: C++ file has been saved to output folder.';
  SMsgCompilerTerminatedBecause1 = 'Compilation terminated because ''%s''.';
  SMsgCompiling = 'Compiling';
  SMsgCompressing = 'Compressing';
  SMsgConvertedWith = 'Converted with ';
  SMsgCreateAudioEffectInstance = 'Create Audio Effect Instance.';
  SMsgDeclareGlobalVariables = 'Declare Global Variables.';
  SMsgDefineInnerLoops = 'Define Inner Loops.';
  SMsgDefineInternalFunctions = 'Define Internal Functions.';
  SMsgDescription = 'Description';
  SMsgEffectDescription = 'Effect Description.';
  SMsgElement = 'Element';
  SMsgIdentifierEllipsesNotSupported = 'Identifier names with ellipses are not supported.';
  SMsgEndOfCode = 'End of Code Section.';
  SMsgExpectedButFound2 = 'Expected ''%s'' but found ''%s''.';
  SMsgExpression = 'Expression';
  SMsgFileDoesNotExist = 'File does not exist.';
  SMsgFileIsNotATextFile = 'File is not a text file.';
  SMsgFileNameMustBeAbsolute = 'Filename must be absolute.';
  SMsgFinished = 'Finished';
  SMsgFunctionasDuplicateOverloads1 = '''%s'' has duplicate overloads.';
  SMsgFunctionDefinedInsideFunction = 'Unable to define a function inside a function.';
  SMsgGlobalVariableNotAccessible1 = 'The global variable ''%s'' is not accessible.';
  SMsgHashSymbol = 'Hash Symbol';
  SMsgIdentifier = 'Identifier';
  SMsgIdentifierNameIsNotIdentical2 = 'Identifier ''%s'' is not identical to ''%s''.';
  SMsgIncludes = 'Includes';
  SMsgIncompleteStringCharSequence = 'Incomplete literal string/char sequence.';
  SMsgInvalidFilename = 'Invalid Filename.';
  SMsgInvalidNumber1 = '''%s'' is not a valid number.';
  SMsgJes2CppAudioCallBacks = 'VeST Audio Callbacks.';
  SMsgJes2CppEffectClass = 'Jes2Cpp Effect Class.';
  SMsgKeywordsCantBeUsedAsIdentNames = 'Keywords can not be used for identifier names.';
  SMsgLiteralChar = 'Literal Char';
  SMsgLiteralCharsMustBe = 'Literal chars must be 1-4 bytes.';
  SMsgLiteralNumber = 'Literal Number';
  SMsgLiteralString = 'Literal String';
  SMsgModified = 'Modified';
  SMsgNamespaceNotAccessible1 = 'The namespace ''%s'' is not accessible.';
  SMsgNotRequiredForThisEffect = 'Not required for this effect.';
  SMsgNumberOfParametersFound1 = '%d Parameter(s) Found.';
  SMsgParenthesisBlock = 'Parenthesis Block';
  SMsgPrecision = 'Precision';
  SMsgStarted = 'Started';
  SMsgTranspile = 'Transpile';
  SMsgTypeBuilding = 'Building';
  SMsgTypeError = 'Error';
  SMsgTypeException = 'Exception!';
  SMsgTypeGeneral = 'General';
  SMsgTypeHint = 'Hint';
  SMsgTypeImporting = 'Importing';
  SMsgTypeLoaded = 'Loaded';
  SMsgTypeParsing = 'Parsing';
  SMsgTypeSaving = 'Saving';
  SMsgTypeSyntaxChecking = 'SyntaxChecking';
  SMsgTypeWarning = 'Warning';
  SMsgUnableToCompileIncludeFile = 'Unable to build jsfx-inc file.';
  SMsgUnableToCreateOuputDirectory = 'Unable to create output directory.';
  SMsgUnableToDeleteOutputFile = 'Unable to delete output file.';
  SMsgUnableToFindFunction1 = 'Unable to find the function ''%s''.';
  SMsgUnableToFindImportFile = 'Unable to find import file.';
  SMsgUnableToFindImportFile1 =
    'Unable to import ''%s''. (Make sure script is saved and import file is in the same path)';
  SMsgUnableToFindSelectedCompiler1 = 'Unable to find selected compiler. ''%s''';
  SMsgUnchanged = 'Unchanged';
  SMsgVariableUsedBeforeAssignment1 = 'The variable ''%s'' is used before assignment.';
  SMsgVariadicEllipsisHasAlreadyBeenUsed = 'Variadic ellipsis has already been used.';
  SMsgVariadicEllipsisMustBeTheLastParameter = 'Variadic ellipsis must be the last parameter.';
  SMsgVariadicFunctionsMustHaveAtLeastOneParameter =
    'Variadic functions must have at least one parameter.';

implementation

end.
