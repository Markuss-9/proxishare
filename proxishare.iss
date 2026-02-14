; ProxiShare Windows Installer Script
; Set version from build parameter, fallback to default if not provided
#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif

[Setup]
AppName=ProxiShare
AppVersion={#AppVersion}
AppId={{8F15D3E8-4F9E-4B8C-8A6D-9C5E2F1B8A3D}
AppPublisher=ProxiShare
DefaultDirName={autopf}\ProxiShare
DefaultGroupName=ProxiShare
OutputDir=installer
OutputBaseFilename=ProxiShare-Setup-{#AppVersion}
SetupIconFile=assets\matterhorn.ico
UninstallDisplayIcon={app}\proxishare.exe
Compression=lzma
SolidCompression=yes
VersionInfoVersion={#AppVersion}
VersionInfoProductName=ProxiShare
VersionInfoProductVersion={#AppVersion}
VersionInfoCopyright=2026 ProxiShare
WizardStyle=modern
PrivilegesRequired=lowest
AllowUNCPath=no
UsePreviousAppDir=yes

[Files]
; Application executable and dependencies from Flutter build
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion
; Important: This section validates that the build exists
; If the build directory is missing, the installer will not be created

[Icons]
Name: "{group}\ProxiShare"; Filename: "{app}\proxishare.exe"; Comment: "ProxiShare - Local file sharing"
Name: "{commondesktop}\ProxiShare"; Filename: "{app}\proxishare.exe"; Comment: "ProxiShare - Local file sharing"

[Run]
Filename: "{app}\proxishare.exe"; Description: "Launch ProxiShare"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
