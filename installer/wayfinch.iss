; Wayfinch installer (Inno Setup 6). Build it with installer\build.ps1,
; which builds the app, stages the files and passes AppVersion/SourceDir.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\build\installer\app"
#endif

#define AppName "Wayfinch"
#define AppExe "wayfinch.exe"
; Must match the AUMID the app registers for its notifications.
#define AppUserModelId "Wayfinch.Wayfinch.Desktop"

[Setup]
; Never change AppId: Windows uses it to find this app for updates and
; uninstalls.
AppId={{8C1F4E2A-5B7D-4A39-9E61-2D0B7F3C6A58}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppName}
AppPublisherURL=https://github.com/Ayloonah/Wayfinch
AppSupportURL=https://github.com/Ayloonah/Wayfinch/issues
AppUpdatesURL=https://github.com/Ayloonah/Wayfinch/releases
VersionInfoVersion={#AppVersion}
; "Just me" (no admin, AppData\Local\Programs) by default; the wizard also
; offers "everyone on this PC" (Program Files, asks for admin).
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
DefaultDirName={autopf}\{#AppName}
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
WizardStyle=modern
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppName}
OutputDir=..\build\installer
OutputBaseFilename=WayfinchSetup-{#AppVersion}
Compression=lzma2/max
SolidCompression=yes
; Wayfinch keeps running in the tray, so updates close it first.
CloseApplications=force
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[CustomMessages]
english.DeleteDataTitle=Uninstall Wayfinch
english.DeleteDataCheck=Also delete my list, settings and daily backups
english.DeleteDataNote=Your list is kept unless you tick this, so reinstalling picks up where you left off. Deleting it can't be undone. Backups you moved to another folder stay there.
french.DeleteDataTitle=Désinstaller Wayfinch
french.DeleteDataCheck=Supprimer aussi ma liste, mes paramètres et mes sauvegardes quotidiennes
french.DeleteDataNote=Ta liste est gardée sauf si tu coches ceci, pour que réinstaller reprenne là où tu en étais. La supprimer est irréversible. Les sauvegardes déplacées dans un autre dossier y restent.

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; The AUMID ties notifications to this shortcut.
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"; AppUserModelID: "{#AppUserModelId}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; Stop the copy running from this folder (it may be in the tray).
Filename: "powershell.exe"; Parameters: "-NoProfile -NonInteractive -Command ""Get-Process wayfinch -ErrorAction SilentlyContinue | Where-Object {{ $_.Path -like '{app}\*' } | Stop-Process -Force"""; Flags: runhidden; RunOnceId: "StopWayfinch"

[Registry]
; Created by the app itself; removed on uninstall.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: none; ValueName: "{#AppName}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\AppUserModelId\{#AppUserModelId}"; ValueType: none; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup\{#AppUserModelId}"; ValueType: none; Flags: uninsdeletekey

[Code]
var
  DeleteData: Boolean;

{ Asks (with a checkbox, off by default) whether to delete the list too. }
procedure AskAboutData();
var
  Form: TSetupForm;
  Check: TNewCheckBox;
  Note: TNewStaticText;
  OkButton: TNewButton;
begin
  Form := CreateCustomForm(ScaleX(460), ScaleY(150), False, False);
  try
    Form.Caption := CustomMessage('DeleteDataTitle');

    Check := TNewCheckBox.Create(Form);
    Check.Parent := Form;
    Check.Left := ScaleX(16);
    Check.Top := ScaleY(16);
    Check.Width := Form.ClientWidth - ScaleX(32);
    Check.Height := ScaleY(20);
    Check.Caption := CustomMessage('DeleteDataCheck');
    Check.Checked := False;

    Note := TNewStaticText.Create(Form);
    Note.Parent := Form;
    Note.Left := ScaleX(16);
    Note.Top := Check.Top + Check.Height + ScaleY(8);
    Note.Width := Form.ClientWidth - ScaleX(32);
    Note.AutoSize := False;
    Note.WordWrap := True;
    Note.Height := ScaleY(56);
    Note.Caption := CustomMessage('DeleteDataNote');

    OkButton := TNewButton.Create(Form);
    OkButton.Parent := Form;
    OkButton.Width := ScaleX(90);
    OkButton.Height := ScaleY(26);
    OkButton.Left := Form.ClientWidth - OkButton.Width - ScaleX(16);
    OkButton.Top := Form.ClientHeight - OkButton.Height - ScaleY(12);
    OkButton.Caption := SetupMessage(msgButtonOK);
    OkButton.ModalResult := mrOk;
    OkButton.Default := True;

    Form.ActiveControl := OkButton;
    Form.ShowModal();
    DeleteData := Check.Checked;
  finally
    Form.Free();
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  { Asked after the "remove Wayfinch?" confirmation; silent uninstalls keep
    the data. }
  if (CurUninstallStep = usUninstall) and not UninstallSilent then
    AskAboutData();
  if (CurUninstallStep = usPostUninstall) and DeleteData then
    DelTree(ExpandConstant('{userappdata}\app.wayfinch'), True, True, True);
end;
