# Phase 1: pull DT / props / logs from a booted Android 8 SE.
# Windows cannot adb-pull /sys/firmware/devicetree (node names vs directories).
# Blobs stay under hardware/dump (gitignored).
param(
    [string]$Adb = "D:\Android\platform-tools\adb.exe"
)

$ErrorActionPreference = "Continue"
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
& $Adb shell getprop vendor.wlan.firmware.version | Out-File -Encoding utf8 "$out\wlan-fw.txt"
& $Adb shell "cat /proc/cmdline" 2>&1 | Out-File -Encoding utf8 "$out\cmdline-proc.txt"

& $Adb shell "tar czf /data/local/tmp/dt.tgz -C /sys/firmware/devicetree base"
& $Adb pull /data/local/tmp/dt.tgz "$out\devicetree.tar.gz"
& $Adb shell dmesg 2>&1 | Out-File -Encoding utf8 "$out\dmesg.txt"
& $Adb shell "ls -la /vendor/firmware /vendor/firmware/wlan/qca_cld /vendor/etc/wifi" 2>&1 | Out-File -Encoding utf8 "$out\firmware-ls.txt"
& $Adb pull /vendor/etc/wifi/WCNSS_qcom_cfg.ini "$out\firmware-copy\WCNSS_qcom_cfg.ini"

Write-Host "Done. Do not git add hardware/dump/"
Write-Host $out
