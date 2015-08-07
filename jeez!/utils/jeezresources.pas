(*

Jeez! - Jesusonic Script Editor

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

unit JeezResources;

{$MODE DELPHI}

interface


resourcestring

  SMsgParsingDotDotDot = 'Parsing ...';
  SMsgCompilationComplete1 = 'Compilation Complete - Time Duration = %s';
  SMsgCountFunctions1 = '(%d Functions)';
  SMsgCountVariables1 = '(%d Variables)';
  SMsgDoYouWantToSaveModifiedFile1 = '''%s'' has been modified. Do you want to save?';
  SMsgFileDoesNotExist1 = 'The file ''%s'' does not exist.';
  SMsgFileIsNotText1 = 'The file ''%s'' is not a text file.';
  SMsgFileNameMustBeAbsolute = 'File name must be absolute.';
  SMsgNoCompilerIsSelected = 'No Compiler is Selected. (Choose compiler from Tools->Options)';
  SMsgPluginDoesNotExistWouldYouLikeToBuildInstallIt1 =
    'The plugin ''%s'' does not exist. Would you like to build/install it?';
  SMsgPluginFailedToInstall =
    'Failed to install plugin. (Please check VSTPath is valid and/or if plugin is in use)';
  SMsgPluginHasBeenInstalled = 'Plugin has been installed';
  SMsgScriptsMustBeSaved = 'Script must be saved before VST can be installed.';
  SMsgSearchCompleted1 = 'Search completed. Do you want to restart from the %s?';
  SMsgSyntaxCheckingCompleteNoErrorsFound = 'Syntax checking complete. No errors were found.';
  SMsgSyntaxError = 'Syntax Error';
  SMsgUnableToFind1 = 'Unable to find ''%s''.';
  SMsgUnableToFindFunction1 = 'Unable to find function ''%s''.';
  SMsgUnableToFindVariable1 = 'Unable to find variable ''%s''.';

implementation

end.
