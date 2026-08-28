# Put this phone's Android boot partition back. Does not touch userdata.
param(
    [string]$Fastboot = "D:\Android\platform-tools\fastboot.exe",
    [string]$BackupDir = "",
    [switch]$Go
)

$ErrorActionPreference = "Stop"
$Expected = "1792BD7C7DFD29FA4267C5FB0089823C253F4E83372F5C35400E9BA795BC4EB2"
$Candidates = @(
    $BackupDir
    "D:\Android\sirius-rollback-20260828-181841"
    (Join-Path (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)) `
        "hardware\dump\20260828-181841-android-boot-backup")
) | Where-Object { $_ }

if (-not (Test-Path $Fastboot)) {
    $found = Get-Command fastboot -ErrorAction SilentlyContinue
    if (-not $found) { throw "fastboot not found. Pass -Fastboot" }
    $Fastboot = $found.Source
}

$use = $null
foreach ($dir in $Candidates) {
    if (Test-Path (Join-Path $dir "boot.img")) { $use = $dir; break }
}
if (-not $use) { throw "Android boot backup not found. Copy 20260828-181841 first." }

$boot = Join-Path $use "boot.img"
$hash = (Get-FileHash $boot -Algorithm SHA256).Hash
if ($hash -ne $Expected) {
    throw "Backup hash $hash does not match $Expected. Refusing to flash."
}
if ((Get-Item $boot).Length -ne 67108864) {
    throw "Backup boot.img size is not 67108864"
}

$fb = & $Fastboot devices
if ($fb -notmatch "fastboot") {
    Write-Host "No fastboot device. Hold volume-down + power, then rerun with -Go."
    Write-Host "Backup ready at $boot"
    exit 2
}

Write-Host "fastboot:$fb"
Write-Host "Would restore: $boot"
if (-not $Go) {
    Write-Host "Dry run. Pass -Go to flash the boot partition only."
    exit 0
}

& $Fastboot flash boot $boot
if ($LASTEXITCODE -ne 0) { throw "fastboot flash boot failed" }
& $Fastboot reboot
Write-Host "Restored Android boot and rebooted."
