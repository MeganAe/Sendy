; Sendy independent unsigned installer. The upstream identity is not registered.
#ifndef PayloadDir
  #error PayloadDir must point to the Flutter Release bundle
#endif
#ifndef ResultDir
  #define ResultDir "."
#endif
#ifndef MyAppVersion
  #define MyAppVersion "0.1.1"
#endif
[Setup]
AppId={{7C94B8D3-9ED5-44C0-AE62-6470E0943496}
AppName=Sendy
AppVersion={#MyAppVersion}
AppPublisher=Metoushela Walker
DefaultDirName={localappdata}\Programs\Sendy
DefaultGroupName=Sendy
UsePreviousAppDir=no
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#ResultDir}
OutputBaseFilename=Sendy-{#MyAppVersion}-windows-x64-setup
SetupIconFile={#PayloadDir}\logo.ico
UninstallDisplayIcon={app}\sendy.exe
LicenseFile={#PayloadDir}\data\LICENSE.txt
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
[Files]
Source: "{#PayloadDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
[Icons]
Name: "{autoprograms}\Sendy"; Filename: "{app}\sendy.exe"
Name: "{autodesktop}\Sendy"; Filename: "{app}\sendy.exe"; Tasks: desktopicon
[Run]
Filename: "{app}\sendy.exe"; Description: "{cm:LaunchProgram,Sendy}"; Flags: nowait postinstall skipifsilent

[Code]
function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
  if FileExists(ExpandConstant('{app}\localsend_app.exe')) then
    Result := 'Sendy must not be installed in an existing LocalSend directory. Choose a separate Sendy installation.';
end;
