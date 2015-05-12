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

  M_ZERO = 0;

const

  SJes2CppName = 'Jes2Cpp';
  SJes2CppSlogan = 'The Easy Way to Create VST Effects';
  SJes2CppDescription = 'Jesusonic Script to C++ Transpiler';
  SJes2CppVersion = '1.4';
  SJes2CppBuildDate = 'BUILD:11thMay2015';
  SJes2CppTitle = SJes2CppName + ' (v' + SJes2CppVersion + ') - ' + SJes2CppDescription;
  SJes2CppWebsite = 'http://www.wascal.net/music/';
  SJes2CppCopyright = 'Copyright (C) 2015 Derek John Evans';
  SJes2CppLicense = 'License: ' + SJes2CppName + ' source code has been released under LGPL' + LineEnding + LineEnding +
    'You should have received a copy of the GNU/LGPL General Public License' + LineEnding +
    'along with this program.  If not, see <http://www.gnu.org/licenses/>.';

const

  CharAsterisk = Char('*');
  CharAtSymbol = Char('@');
  CharAmpersand = Char('&');
  CharClosingBrace = Char('}');
  CharClosingBracket = Char(']');
  CharClosingParenthesis = Char(')');
  CharColon = Char(':');
  CharComma = Char(',');
  CharCR = Char(#13);
  CharDollar = Char('$');
  CharDot = Char('.');
  CharEqu = Char('=');
  CharExclamation = Char('!');
  CharHash = Char('#');
  CharLF = Char(#10);
  CharMinusSign = Char('-');
  CharNull = Char(#0);
  CharOpeningBrace = Char('{');
  CharOpeningBracket = Char('[');
  CharOpeningParenthesis = Char('(');
  CharPercent = Char('%');
  CharVerticalBar = Char('|');
  CharPlusSign = Char('+');
  CharQuestionMark = Char('?');
  CharQuoteDouble = Char('"');
  CharQuoteSingle = Char('''');
  CharSemiColon = Char(';');
  CharSlashBackward = Char('\');
  CharSlashForward = Char('/');
  CharSpace = Char(' ');
  CharTab = Char(#9);


  CharSetWhite = [#9, #10, #11, #12, #13, #32];
  CharSetQuote = ['''', '"'];
  CharSetEof = [CharNull];
  CharSetEol = CharSetEof + [#10, #13];
  CharSetUpper = ['A'..'Z'];
  CharSetLower = ['a'..'z'];
  CharSetHex = ['a'..'f', 'A'..'F'];
  CharSetDigit = ['0'..'9'];
  CharSetAlpha = CharSetLower + CharSetUpper;

  CharSetIdent1 = CharSetAlpha + ['_', '$', '#'];
  CharSetIdent2 = CharSetAlpha + CharSetDigit + ['_', '.'];

  CharSetNumber1 = CharSetDigit + ['.', '$'];
  CharSetNumber2 = CharSetDigit + CharSetAlpha + ['.', 'x', 'X', 'e', 'E', ''''];

  CharSetOperator1 = ['=', '*', '/', '%', '^', '+', '-', '|', '&', '!', '<', '>', '~'];
  CharSetOperator2 = ['<', '>', '&', '|', '='];

const

  S32Bit = '32bit';
  S64Bit = '64bit';
  SClose = 'Close';
  SCreate = 'Create';
  SDestroy = 'Destroy';
  SDLL = 'DLL';
  SDoBlock = 'DoBlock';
  SDoClose = 'DoClose';
  SDoGfx = 'DoGfx';
  SDoIdle = 'DoIdle';
  SDoInit = 'DoInit';
  SDoLoop = 'DoLoop';
  SDoOpen = 'DoOpen';
  SDoResume = 'DoResume';
  SDoSample = 'DoSample';
  SDoSerialize = 'DoSerialize';
  SDoSlider = 'DoSlider';
  SDoSuspend = 'DoSuspend';
  SDraw = 'Draw';
  SEffect = 'Effect';
  SEffectName = 'EffectName';
  SFile = 'File';
  SGetChunk = 'GetChunk';
  SGetEffectName = 'GetEffectName';
  SGetParameter = 'GetParameter';
  SGetParameterDisplay = 'GetParameterDisplay';
  SGetParameterLabel = 'GetParameterLabel';
  SGetParameterName = 'GetParameterName';
  SGetProductString = 'GetProductString';
  SGetProgramName = 'GetProgramName';
  SGetProgramNameIndexed = 'GetProgramNameIndexed';
  SGetVendorString = 'GetVendorString';
  SGetVendorVersion = 'GetVendorVersion';
  SIdle = 'Idle';
  SLine = 'Line';
  SMouseDown = 'MouseDown';
  SMouseMoved = 'MouseMoved';
  SMouseUp = 'MouseUp';
  SOpen = 'Open';
  SPath = 'Path';
  SProcessDoubleReplacing = 'ProcessDoubleReplacing';
  SProcessReplacing = 'ProcessReplacing';
  SProductString = 'ProductString';
  SResume = 'Resume';
  SSave = 'Save';
  SSetChunk = 'SetChunk';
  SSetParameter = 'SetParameter';
  SSetProgramName = 'SetProgramName';
  SSuspend = 'Suspend';
  STJes2Cpp = 'TJes2Cpp';
  STJes2CppEffect = STJes2Cpp + SEffect;
  STJes2CppEffectVst = STJes2CppEffect + 'Vst';
  SUniqueId = 'UniqueId';
  SVendorString = 'VendorString';
  SVendorVersion = 'VendorVersion';
  SVST = 'VST';
  SVstPath = 'VstPath';
  S_ConstString = '_ConstString';
  S_HashString = '_HashString';

const

  SM_PI = 'M_PI';

  S_JES2CPP_NO_BASS_ = '_JES2CPP_NO_BASS_';

const

  SCppFunct2 = '%s(%s)';
  SCppFunct3 = '%s(%s, %s)';
  SCppInlineSpace = 'inline' + CharSpace;
  SCppReturnSpace = 'return' + CharSpace;
  SCppCommaSpace = CharComma + CharSpace;
  SCppEqu = CharSpace + CharEqu + CharSpace;
  SCppEol = CharSemiColon;
  SCppCommentSpace = CharSlashForward + CharSlashForward + CharSpace;
  SCppVoidSpace = 'void' + CharSpace;

  SFileMarkerHead = '@@@file[';
  SFileMarkerFoot = ']';

  SLineMarkerHead = '@@@line[';
  SLineMarkerFoot = ']';

// English Strings

resourcestring

  SMsgAlreadyDefined1 = '"%s" is already defined.';
  SMsgAlreadyDefinedAsInstance1 = '"%s" is already defined as an instance.';
  SMsgAlreadyDefinedAsLocal1 = '"%s" is already defined as a local.';
  SMsgAlreadyDefinedAsParameter1 = '"%s" is already defined as a parameter.';
  SMsgCompilationAborted = 'Compilation aborted.';
  SMsgCompilationFailed = 'Compilation failed. (Please check message log)';
  SMsgCompilerNotSelected = 'No compiler selected. Note: C++ file has been saved to output folder.';
  SMsgCompilerTerminatedBecause1 = 'Compilation terminated because "%s".';
  SMsgConvertedWith = 'Converted with ';
  SMsgCreateAudioEffectInstance = 'Create Audio Effect Instance.';
  SMsgDefineGlobalVariables = 'Define Global Variables.';
  SMsgDescription = 'Description';
  SMsgEffectDescription = 'Effect Description.';
  SMsgElement = 'Element';
  SMsgEllipsesNotSupported = 'Variable names with ellipses are not supported.';
  SMsgEndOfCode = 'End of Code Section.';
  SMsgErrorInLine3 = 'Line="%d" - %s // File="%s"';
  SMsgExpectedButFound2 = 'Expected "%s" but found "%s".';
  SMsgExpression = 'Expression';
  SMsgExpressionBlockMissingReturn = 'Expression block is missing a return value.';
  SMsgFinished = 'Finished';
  SMsgFunctionasDuplicateOverloads1 = '"%s" has duplicate overloads.';
  SMsgFunctionDefinedInsideFunction = 'Unable to define a function inside a function.';
  SMsgIdentifier = 'Identifier';
  SMsgInvalidFilename = 'Invalid Filename.';
  SMsgInvalidNumber1 = '"%s" is not a valid number.';
  SMsgJes2CppAudioCallBacks = 'VeST Audio Callbacks.';
  SMsgJes2CppEffectClass = 'Jes2Cpp Effect Class.';
  SMsgMultipleAssignmentsInFunctionCall = 'Multiple assignments in function calls are not portable.';
  SMsgMultipleAssignmentsInStatements = 'Multiple assignments in statements are not portable.';
  SMsgNotRequiredForThisEffect = 'Not required for this effect.';
  SMsgNumberOfParametersFound1 = '%d Parameter(s) Found.';
  SMsgPrecision = 'Precision';
  SMsgProcessor = 'Processor';
  SMsgStarted = 'Started';
  SMsgStatementBlock = 'Statement Block';
  SMsgTypeBuilding = 'Building';
  SMsgTypeError = 'Error!';
  SMsgTypeException = 'Exception!';
  SMsgTypeGeneral = 'General';
  SMsgTypeImporting = 'Importing';
  SMsgTypeLoaded = 'Loaded';
  SMsgTypeParsing = 'Parsing';
  SMsgTypeSaving = 'Saving';
  SMsgTypeSyntaxChecking = 'SyntaxChecking';
  SMsgUnableToCreateOuputDirectory = 'Unable to create output directory.';
  SMsgUnableToDeleteOutputFile = 'Unable to delete output file.';
  SMsgUnableToFindFunction1 = 'Unable to find the function "%s".';
  SMsgUnableToFindImportFile1 = 'Unable to import "%s". (Make sure script is saved and import file is in the same path)';
  SMsgUnableToFindSelectedCompiler1 = 'Unable to find selected compiler. "%s"';



implementation

end.

