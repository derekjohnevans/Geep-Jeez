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

  SMsgUnableToFindVariable1 = 'Unable to find variable ''%s''.';
  SMsgUnableToFindFunction1 = 'Unable to find function ''%s''.';
  SMsgFileNameMustBeAbsolute = 'File name must be absolute.';
  SMsgFileDoesNotExist1 = 'The file ''%s'' does not exist.';
  SMsgPluginDoesNotExistWouldYouLikeToBuildInstallIt1 = 'The plugin ''%s'' does not exist. Would you like to build/install it?';
  SMsgFileIsNotText1 = 'The file ''%s'' is not a text file.';
  SMsgSyntaxCheckingCompleteNoErrorsFound = 'Syntax checking complete. No errors were found.';
  SMsgNoCompilerIsSelected = 'No Compiler is Selected. (Choose compiler from Tools->Options)';
  SMsgDoYouWantToSaveModifiedFile1 = '''%s'' has been modified. Do you want to save?';
  SMsgSearchCompleted1 = 'Search completed. Do you want to restart from the %s?';
  SMsgCompilationComplete1 = 'Compilation Complete - Time Duration = %s';
  SMsgScriptsMustBeSaved = 'Script must be saved before VST can be installed.';
  SMsgPluginHasBeenInstalled = 'Plugin has been installed';
  SMsgPluginFailedToInstall = 'Failed to install plugin. (Please check VSTPath is valid and/or if plugin is in use)';

implementation

end.

