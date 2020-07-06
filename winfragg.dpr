 (*----------------------------------------------------------------------------+
  Winfragg(c) is created by Wash for A.M.U

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  The CsTiger searching feature is an exclusivity for Winfragg(c) only.

  Amu's page : http://winfragg.sourceforge.net/
  Dev Page   : https://sourceforge.net/projects/winfragg/
  Contact    : amunit@users.sourceforge.net
  CsTiger    : http://www.cstiger.de
  Borland    : http://www.borland.com
 +----------------------------------------------------------------------------*)

program winfragg;

{%ToDo 'winfragg.todo'}

uses
  Forms,
  WinProcs,
  Messages,
  syslib in 'syslib.pas',
  main in 'main.pas' {MainForm},
  queryLib in 'queryLib.pas' {QueryMain},
  bookmark in 'bookmark.pas' {MainBook},
  setup in 'setup.pas' {SetupMain},
  servermain in 'servermain.pas' {MainServer},
  constants in 'constants.pas',
  tstruct in 'tstruct.pas';

{$R *.res}

var
  hMutex : THandle;
  atom_Send: Atom;
  
 procedure SendingMessage;
 begin
  if (ParamStr(1) <> 'ip') and (ParamStr(1) <> '')
  then
   begin
    atom_Send := GlobalAddAtom(PChar(ParamStr(1)));
    SendMessage(FindWindow('TMainForm',nil),WM_USER+17879,atom_Send,0)
   end
 end;

begin

  hMutex := CreateMutex(nil, true, 'Winfragg');

  if GetLastError = ERROR_ALREADY_EXISTS then
   begin
     CloseHandle(hMutex);
     SendingMessage();
   end
  else
   begin
    Application.Initialize;
    Application.Title := 'Winfragg FUSiON #2.03';
    Application.CreateForm(TMainForm, MainForm);
    Application.CreateForm(TQueryMain, QueryMain);
    Application.CreateForm(TMainBook, MainBook);
    Application.CreateForm(TMainServer, MainServer);
    Application.CreateForm(TSetupMain, SetupMain);
    SetupMain.LoadGameconf;
    SendingMessage();
    Application.Run
   end;

end.
