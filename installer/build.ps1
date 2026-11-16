<#
.SYNOPSIS
  Builds the Wayfinch installer: build\installer\WayfinchSetup-<version>.exe

.DESCRIPTION
  1. flutter build windows --release (the real app, lib/main.dart)
  2. Stages the release folder plus the Visual C++ runtime DLLs the app
     needs on PCs without it (msvcp140, vcruntime140, vcruntime140_1).
  3. Compiles installer\wayfinch.iss with Inno Setup 6 (ISCC.exe).

  The version comes from pubspec.yaml ("version: 1.2.3+4" gives 1.2.3).

.PARAMETER SkipFlutterBuild
  Reuse the existing build\windows\x64\runner\Release folder.
#>
param([switch]$SkipFlutterBuild)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
  $version = (Select-String -Path pubspec.yaml -Pattern '^version:\s*([0-9.]+)').Matches[0].Groups[1].Value
  Write-Host "Wayfinch $version"

  if (-not $SkipFlutterBuild) {
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw 'flutter build failed' }
  }

  $release = 'build\windows\x64\runner\Release'
  $stage = 'build\installer\app'
  if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
  New-Item -ItemType Directory -Force $stage | Out-Null
  Copy-Item -Recurse "$release\*" $stage

  # The Visual C++ runtime, from the Visual Studio redist folder.
  $vsRoots = @(
    "${env:ProgramFiles}\Microsoft Visual Studio",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio"
  ) | Where-Object { Test-Path $_ }
  $crt = Get-ChildItem $vsRoots -Recurse -Filter vcruntime140.dll -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '\\Redist\\MSVC\\[^\\]+\\x64\\Microsoft\.VC\d+\.CRT\\' } |
    Sort-Object FullName -Descending | Select-Object -First 1
  if (-not $crt) { throw 'Visual C++ x64 runtime not found in the Visual Studio redist folder' }
  foreach ($dll in 'msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll') {
    Copy-Item (Join-Path $crt.DirectoryName $dll) $stage
  }

  $iscc = @(
    "${env:LOCALAPPDATA}\Programs\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
  ) | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $iscc) { throw 'Inno Setup 6 not found (winget install JRSoftware.InnoSetup)' }

  & $iscc /Qp "/DAppVersion=$version" "/DSourceDir=$root\$stage" installer\wayfinch.iss
  if ($LASTEXITCODE -ne 0) { throw 'Inno Setup failed' }
  Write-Host "Built build\installer\WayfinchSetup-$version.exe"
}
finally {
  Pop-Location
}
