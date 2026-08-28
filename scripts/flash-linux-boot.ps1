# First Linux flash: boot partition only. Requires the Android backup.
param(
    [Parameter(Mandatory = $true)]
    [string]$BootImg,
    [string]$Fastboot = "D:\Android\platform-tools\fastboot.exe",
    [switch]$Go
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$BackupCandidates = @(
    "D:\Android\sirius-rollback-20260828-181841\boot.img"
    (Join-Path $Root "hardware\dump\20260828-181841-android-boot-backup\boot.img")
)
$ExpectedAndroid = "1792BD7C7DFD29FA4267C5FB0089823C253F4E83372F5C35400E9BA795BC4EB2"

if (-not (Test-Path $BootImg)) { throw "Linux boot image not found: $BootImg" }
if (-not (Test-Path $Fastboot)) {
    $found = Get-Command fastboot -ErrorAction SilentlyContinue
    if (-not $found) { throw "fastboot not found. Pass -Fastboot" }
    $Fastboot = $found.Source
}

$android = $BackupCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $android) { throw "Android boot backup missing. Will not flash Linux." }
$androidHash = (Get-FileHash $android -Algorithm SHA256).Hash
if ($androidHash -ne $ExpectedAndroid) {
    throw "Android backup hash mismatch. Will not flash Linux."
}

$linux = Get-Item $BootImg
$hdr = [IO.File]::ReadAllBytes($linux.FullName)[0..7]
$magic = [Text.Encoding]::ASCII.GetString($hdr)
if ($magic -ne "ANDROID!") { throw "Linux boot.img magic is '$magic', expected ANDROID!" }
if ($linux.Length -gt 67108864) {
    throw "Linux boot.img is $($linux.Length) bytes; boot partition is 67108864."
}

$fb = & $Fastboot devices
if ($fb -notmatch "fastboot") {
    Write-Host "No fastboot device. Power off, hold volume-down + power, plug USB."
    Write-Host "Then rerun with -Go."
    exit 2
}

Write-Host "fastboot:$fb"
Write-Host "Linux image: $($linux.FullName) ($($linux.Length) bytes)"
Write-Host "Rollback:   $android"
if (-not $Go) {
    Write-Host "Dry run. Pass -Go to flash the boot partition only."
    exit 0
}

& $Fastboot flash boot $linux.FullName
if ($LASTEXITCODE -ne 0) { throw "fastboot flash boot failed" }
& $Fastboot reboot
Write-Host "Flashed Linux boot. Wait ~30s. Do not flash any other partition."
Write-Host "If nothing enumerates: .\restore-android-boot.ps1 -Go"
