# Provisions a JavaFX-capable JRE (Zulu FX 17, Windows x64) into .\jre next to
# this script. BridgeLink's client ships a classes-only openjfx.jar, so Mirth
# must run on a JDK with built-in JavaFX; plain Corretto/OpenJDK fail with
# "Error initializing QuantumRenderer: no suitable pipeline found".
#
# Idempotent: re-running does nothing when a valid JRE is already present.
#
# Usage (from PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\setup-jre.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Target    = Join-Path $ScriptDir "jre"
$ZuluUrl   = "https://cdn.azul.com/zulu/bin/zulu17.66.19-ca-fx-jdk17.0.19-win_x64.zip"

function Test-FxJre {
    param([string]$Path)
    if (-not (Test-Path (Join-Path $Path "bin\java.exe"))) { return $false }
    # JavaFX markers: Zulu FX / OpenJFX layout
    return (Test-Path (Join-Path $Path "lib\javafx.properties")) -or
           (Test-Path (Join-Path $Path "lib\javafx-swt.jar"))
}

if (Test-FxJre $Target) {
    Write-Host "OK: $Target already present."
    exit 0
}

# Remove a previous broken/incomplete provisioning attempt
if (Test-Path $Target) { Remove-Item -Recurse -Force $Target }

Write-Host "Downloading Zulu FX 17 ($ZuluUrl) ..."
$Tmp = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $Tmp | Out-Null
try {
    $ZipPath = Join-Path $Tmp "zulu-fx.zip"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $ZuluUrl -OutFile $ZipPath -UseBasicParsing
    Expand-Archive -Path $ZipPath -DestinationPath $Tmp -Force
    $Inner = Get-ChildItem -Path $Tmp -Directory |
        Where-Object { $_.Name -ne "zulu-fx.zip" } |
        Select-Object -First 1
    Move-Item -Path $Inner.FullName -Destination $Target
} finally {
    Remove-Item -Recurse -Force $Tmp -ErrorAction SilentlyContinue
}

if (-not (Test-FxJre $Target)) {
    Write-Error "$Target does not look like a JavaFX-capable JRE."
    exit 1
}

Write-Host "OK: provisioned $($Target)."
