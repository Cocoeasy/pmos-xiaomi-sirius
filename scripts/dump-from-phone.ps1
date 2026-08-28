# Phase 1: pull DT / props / logs / firmware names from a booted Android 8 SE.
# Blobs stay under hardware/dump (gitignored). Run from repo root.
param(
    [string]$Adb = "D:\Android\platform-tools\adb.exe"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if (-not (Test-Path $Adb)) {
    $found = Get-Command adb -ErrorAction SilentlyContinue
    if (-not $found) { throw "adb not found. Install platform-tools or pass -Adb" }
    $Adb = $found.Source
}

$serials = & $Adb devices | Select-String "\tdevice$"
if (-not $serials) {
    Write-Host "No authorized device. Plug in the Mi 8 SE, enable USB debugging, tap Allow."
    & $Adb devices -l
    exit 2
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$out = Join-Path $Root "hardware\dump\$stamp"
New-Item -ItemType Directory -Force -Path $out, "$out\firmware-copy" | Out-Null
Write-Host "Dumping to $out"

& $Adb shell getprop | Out-File -Encoding utf8 "$out\getprop.txt"
& $Adb shell getprop ro.product.device | Out-File -Encoding utf8 "$out\ro.product.device.txt"
& $Adb shell getprop ro.boot.hardware | Out-File -Encoding utf8 "$out\ro.boot.hardware.txt"
& $Adb shell cat /proc/cmdline | Out-File -Encoding utf8 "$out\cmdline.txt"

New-Item -ItemType Directory -Force -Path "$out\devicetree" | Out-Null
& $Adb pull /sys/firmware/devicetree/base "$out\devicetree" 2>&1 | Out-File -Encoding utf8 "$out\pull-dt.log"

& $Adb shell dmesg 2>&1 | Out-File -Encoding utf8 "$out\dmesg.txt"

$search = @("wlanmdsp", "bdwlan", "mba.mbn", "modem.mbn", "adsp.mbn", "cdsp.mbn", "a615_zap")
$findScript = 'for p in /vendor/firmware /vendor/firmware_mnt /firmware/image /vendor/firmware/wlan; do [ -d "$p" ] && find "$p" -type f 2>/dev/null; done'
& $Adb shell $findScript 2>&1 | Out-File -Encoding utf8 "$out\firmware-list.txt"

Get-Content "$out\firmware-list.txt" -ErrorAction SilentlyContinue |
    Where-Object { $line = $_; $search | Where-Object { $line -match $_ } } |
    ForEach-Object {
        $remote = $_.Trim()
        if ($remote -and $remote.StartsWith("/")) {
            $name = Split-Path $remote -Leaf
            Write-Host "pull $remote"
            & $Adb pull $remote (Join-Path "$out\firmware-copy" $name) 2>&1 | Out-Null
        }
    }

Write-Host "Done. Do not git add hardware/dump/"
Write-Host $out
